import { Injectable } from '@nestjs/common';
import { CatalogStatus } from '@prisma/client';
import { PinoLogger } from 'nestjs-pino';
import {
  NotFoundAppError,
  ValidationAppError,
} from '../../common/errors/app.error';
import { PrismaService } from '../../prisma/prisma.service';
import type {
  CoverageAtollSummaryDto,
  CoverageIslandDto,
  ProviderCoverageResponseDto,
} from './dto/provider-coverage.dto';

@Injectable()
export class ProviderCoverageService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly logger: PinoLogger,
  ) {
    this.logger.setContext(ProviderCoverageService.name);
  }

  async getOwn(userId: string): Promise<ProviderCoverageResponseDto> {
    const profile = await this.findProfileOrThrow(userId);
    return this.buildCoverageResponse(profile.id);
  }

  async replaceOwn(
    userId: string,
    islandIds: string[],
  ): Promise<ProviderCoverageResponseDto> {
    const profile = await this.findProfileOrThrow(userId);
    const uniqueIds = [...new Set(islandIds)];
    await this.assertActiveIslands(uniqueIds);

    await this.prisma.$transaction(async (tx) => {
      await tx.providerIslandCoverage.deleteMany({
        where: { providerProfileId: profile.id },
      });
      if (uniqueIds.length > 0) {
        await tx.providerIslandCoverage.createMany({
          data: uniqueIds.map((islandId) => ({
            providerProfileId: profile.id,
            islandId,
          })),
        });
      }
    });

    this.logger.info({
      event: 'provider_coverage.replaced',
      userId,
      providerProfileId: profile.id,
      islandCount: uniqueIds.length,
    });

    return this.buildCoverageResponse(profile.id);
  }

  async addIslands(
    userId: string,
    islandIds: string[],
  ): Promise<ProviderCoverageResponseDto> {
    const profile = await this.findProfileOrThrow(userId);
    const uniqueIds = [...new Set(islandIds)];
    if (uniqueIds.length === 0) {
      return this.buildCoverageResponse(profile.id);
    }
    await this.assertActiveIslands(uniqueIds);

    await this.prisma.providerIslandCoverage.createMany({
      data: uniqueIds.map((islandId) => ({
        providerProfileId: profile.id,
        islandId,
      })),
      skipDuplicates: true,
    });

    this.logger.info({
      event: 'provider_coverage.islands_added',
      userId,
      providerProfileId: profile.id,
      islandCount: uniqueIds.length,
    });

    return this.buildCoverageResponse(profile.id);
  }

  async removeIslands(
    userId: string,
    islandIds: string[],
  ): Promise<ProviderCoverageResponseDto> {
    const profile = await this.findProfileOrThrow(userId);
    const uniqueIds = [...new Set(islandIds)];
    if (uniqueIds.length > 0) {
      await this.prisma.providerIslandCoverage.deleteMany({
        where: {
          providerProfileId: profile.id,
          islandId: { in: uniqueIds },
        },
      });
    }

    this.logger.info({
      event: 'provider_coverage.islands_removed',
      userId,
      providerProfileId: profile.id,
      islandCount: uniqueIds.length,
    });

    return this.buildCoverageResponse(profile.id);
  }

  async addAtollIslands(
    userId: string,
    atollId: string,
  ): Promise<ProviderCoverageResponseDto> {
    const profile = await this.findProfileOrThrow(userId);
    const atoll = await this.prisma.atoll.findUnique({ where: { id: atollId } });
    if (!atoll || atoll.status !== CatalogStatus.ACTIVE) {
      throw new NotFoundAppError('Atoll not found');
    }

    const islands = await this.prisma.island.findMany({
      where: { atollId, status: CatalogStatus.ACTIVE },
      select: { id: true },
    });
    const islandIds = islands.map((i) => i.id);

    if (islandIds.length > 0) {
      await this.prisma.providerIslandCoverage.createMany({
        data: islandIds.map((islandId) => ({
          providerProfileId: profile.id,
          islandId,
        })),
        skipDuplicates: true,
      });
    }

    this.logger.info({
      event: 'provider_coverage.atoll_expanded',
      userId,
      providerProfileId: profile.id,
      atollId,
      islandCount: islandIds.length,
    });

    return this.buildCoverageResponse(profile.id);
  }

  private async findProfileOrThrow(userId: string) {
    const profile = await this.prisma.providerProfile.findUnique({
      where: { userId },
    });
    if (!profile) {
      throw new NotFoundAppError('Provider profile not found');
    }
    return profile;
  }

  private async assertActiveIslands(islandIds: string[]) {
    if (islandIds.length === 0) {
      return;
    }
    const islands = await this.prisma.island.findMany({
      where: {
        id: { in: islandIds },
        status: CatalogStatus.ACTIVE,
      },
      select: { id: true },
    });
    if (islands.length !== islandIds.length) {
      const found = new Set(islands.map((i) => i.id));
      const missing = islandIds.filter((id) => !found.has(id));
      throw new ValidationAppError(
        'One or more islands are invalid or inactive',
        { islandIds: missing },
      );
    }
  }

  private async buildCoverageResponse(
    providerProfileId: string,
  ): Promise<ProviderCoverageResponseDto> {
    const rows = await this.prisma.providerIslandCoverage.findMany({
      where: { providerProfileId },
      include: {
        island: {
          include: { atoll: true },
        },
      },
      orderBy: [
        { island: { atoll: { displayOrder: 'asc' } } },
        { island: { displayOrder: 'asc' } },
        { island: { name: 'asc' } },
      ],
    });

    const islands: CoverageIslandDto[] = rows.map((row) => ({
      id: row.island.id,
      atollId: row.island.atollId,
      name: row.island.name,
      slug: row.island.slug,
      type: row.island.type,
      displayOrder: row.island.displayOrder,
      status: row.island.status,
      atollName: row.island.atoll.name,
      atollCode: row.island.atoll.code,
    }));

    const atollMap = new Map<string, CoverageAtollSummaryDto>();
    for (const island of islands) {
      const existing = atollMap.get(island.atollId);
      if (existing) {
        existing.islandCount += 1;
      } else {
        atollMap.set(island.atollId, {
          atollId: island.atollId,
          atollName: island.atollName ?? '',
          atollCode: island.atollCode ?? '',
          islandCount: 1,
        });
      }
    }

    return {
      providerProfileId,
      islands,
      atollSummaries: [...atollMap.values()],
    };
  }
}
