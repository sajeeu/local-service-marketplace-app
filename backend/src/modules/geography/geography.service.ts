import { Injectable } from '@nestjs/common';
import { CatalogStatus, Prisma } from '@prisma/client';
import { NotFoundAppError } from '../../common/errors/app.error';
import {
  buildPaginationMeta,
  normalizePagination,
  toPaginatedEnvelope,
  type PaginatedResult,
} from '../../common/pagination';
import { PrismaService } from '../../prisma/prisma.service';
import {
  ListAtollsQueryDto,
  ListIslandsByAtollQueryDto,
  ListIslandsQueryDto,
  type AtollResponseDto,
  type IslandResponseDto,
} from './dto/geography.dto';
import { toAtollResponse, toIslandResponse } from './geography.mapper';

@Injectable()
export class GeographyService {
  constructor(private readonly prisma: PrismaService) {}

  async listAtolls(query: ListAtollsQueryDto) {
    const { page, limit, skip } = normalizePagination(query);
    const where: Prisma.AtollWhereInput = {};

    if (query.status) {
      where.status = query.status;
    } else {
      where.status = CatalogStatus.ACTIVE;
    }

    if (query.search?.trim()) {
      const term = query.search.trim();
      where.OR = [
        { name: { contains: term, mode: 'insensitive' } },
        { code: { contains: term, mode: 'insensitive' } },
      ];
    }

    const orderBy = this.atollOrderBy(query.sort);

    const [total, rows] = await Promise.all([
      this.prisma.atoll.count({ where }),
      this.prisma.atoll.findMany({
        where,
        orderBy,
        skip,
        take: limit,
      }),
    ]);

    const result: PaginatedResult<AtollResponseDto> = {
      items: rows.map(toAtollResponse),
      pagination: buildPaginationMeta(page, limit, total),
    };
    return toPaginatedEnvelope(result);
  }

  async getAtoll(id: string): Promise<AtollResponseDto> {
    const atoll = await this.prisma.atoll.findUnique({ where: { id } });
    if (!atoll || atoll.status !== CatalogStatus.ACTIVE) {
      throw new NotFoundAppError('Atoll not found');
    }
    return toAtollResponse(atoll);
  }

  async listIslandsByAtoll(atollId: string, query: ListIslandsByAtollQueryDto) {
    const atoll = await this.prisma.atoll.findUnique({ where: { id: atollId } });
    if (!atoll || atoll.status !== CatalogStatus.ACTIVE) {
      throw new NotFoundAppError('Atoll not found');
    }

    const { page, limit, skip } = normalizePagination(query);
    const where: Prisma.IslandWhereInput = {
      atollId,
      status: query.status ?? CatalogStatus.ACTIVE,
    };
    if (query.type) {
      where.type = query.type;
    }

    const [total, rows] = await Promise.all([
      this.prisma.island.count({ where }),
      this.prisma.island.findMany({
        where,
        orderBy: [{ displayOrder: 'asc' }, { name: 'asc' }],
        skip,
        take: limit,
      }),
    ]);

    const result: PaginatedResult<IslandResponseDto> = {
      items: rows.map((row) => toIslandResponse(row)),
      pagination: buildPaginationMeta(page, limit, total),
    };
    return toPaginatedEnvelope(result);
  }

  async listIslands(query: ListIslandsQueryDto) {
    const { page, limit, skip } = normalizePagination(query);
    const where: Prisma.IslandWhereInput = {
      status: query.status ?? CatalogStatus.ACTIVE,
    };

    if (query.atollId) {
      where.atollId = query.atollId;
    }
    if (query.type) {
      where.type = query.type;
    }
    if (query.search?.trim()) {
      const term = query.search.trim();
      where.OR = [
        { name: { contains: term, mode: 'insensitive' } },
        { slug: { contains: term, mode: 'insensitive' } },
      ];
    }

    const orderBy: Prisma.IslandOrderByWithRelationInput[] =
      query.sort === 'name'
        ? [{ name: 'asc' }]
        : [{ displayOrder: 'asc' }, { name: 'asc' }];

    const [total, rows] = await Promise.all([
      this.prisma.island.count({ where }),
      this.prisma.island.findMany({
        where,
        include: { atoll: true },
        orderBy,
        skip,
        take: limit,
      }),
    ]);

    const result: PaginatedResult<IslandResponseDto> = {
      items: rows.map((row) => toIslandResponse(row, true)),
      pagination: buildPaginationMeta(page, limit, total),
    };
    return toPaginatedEnvelope(result);
  }

  async getIsland(id: string): Promise<IslandResponseDto> {
    const island = await this.prisma.island.findUnique({
      where: { id },
      include: { atoll: true },
    });
    if (!island || island.status !== CatalogStatus.ACTIVE) {
      throw new NotFoundAppError('Island not found');
    }
    return toIslandResponse(island, true);
  }

  private atollOrderBy(
    sort?: 'displayOrder' | 'name' | 'code',
  ): Prisma.AtollOrderByWithRelationInput[] {
    switch (sort) {
      case 'name':
        return [{ name: 'asc' }];
      case 'code':
        return [{ code: 'asc' }];
      default:
        return [{ displayOrder: 'asc' }, { name: 'asc' }];
    }
  }
}
