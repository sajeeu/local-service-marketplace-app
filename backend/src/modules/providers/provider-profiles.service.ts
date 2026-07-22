import { Injectable } from '@nestjs/common';
import {
  Prisma,
  ProfileStatus,
  ProfileVisibility,
  ProviderProfile,
} from '@prisma/client';
import { PinoLogger } from 'nestjs-pino';
import {
  ConflictAppError,
  NotFoundAppError,
} from '../../common/errors/app.error';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreateProviderProfileDto,
  UpdateProviderProfileDto,
} from './dto/provider-profile.dto';
import {
  toOwnerProviderProfile,
  toPublicProviderProfile,
  type OwnerProviderProfile,
  type PublicProviderProfile,
} from './provider-profile.mapper';

function emptyToNull(value: string | null | undefined): string | null | undefined {
  if (value === undefined) {
    return undefined;
  }
  if (value === null) {
    return null;
  }
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

@Injectable()
export class ProviderProfilesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly logger: PinoLogger,
  ) {
    this.logger.setContext(ProviderProfilesService.name);
  }

  async create(
    userId: string,
    dto: CreateProviderProfileDto,
  ): Promise<OwnerProviderProfile> {
    const existing = await this.prisma.providerProfile.findUnique({
      where: { userId },
    });
    if (existing) {
      throw new ConflictAppError('Provider profile already exists');
    }

    const profile = await this.prisma.providerProfile.create({
      data: {
        userId,
        displayName: dto.displayName.trim(),
        businessName: emptyToNull(dto.businessName) ?? null,
        description: emptyToNull(dto.description) ?? null,
        contactEmail: emptyToNull(dto.contactEmail) ?? null,
        contactPhone: emptyToNull(dto.contactPhone) ?? null,
        websiteUrl: emptyToNull(dto.websiteUrl) ?? null,
        logoUrl: emptyToNull(dto.logoUrl) ?? null,
        coverImageUrl: emptyToNull(dto.coverImageUrl) ?? null,
        languages: dto.languages?.map((lang) => lang.trim()).filter(Boolean) ?? [],
        businessSettings: (dto.businessSettings ?? {}) as Prisma.InputJsonValue,
        visibility: dto.visibility ?? ProfileVisibility.PRIVATE,
        status: ProfileStatus.ACTIVE,
      },
    });

    this.logger.info({
      event: 'provider_profile.created',
      userId,
      profileId: profile.id,
    });

    return toOwnerProviderProfile(profile);
  }

  async getOwn(userId: string): Promise<OwnerProviderProfile> {
    const profile = await this.findOwnOrThrow(userId);
    return toOwnerProviderProfile(profile);
  }

  async updateOwn(
    userId: string,
    dto: UpdateProviderProfileDto,
  ): Promise<OwnerProviderProfile> {
    await this.findOwnOrThrow(userId);

    const data: Prisma.ProviderProfileUpdateInput = {};

    if (dto.displayName !== undefined) {
      data.displayName = dto.displayName.trim();
    }
    if (dto.businessName !== undefined) {
      data.businessName = emptyToNull(dto.businessName) ?? null;
    }
    if (dto.description !== undefined) {
      data.description = emptyToNull(dto.description) ?? null;
    }
    if (dto.contactEmail !== undefined) {
      data.contactEmail = emptyToNull(dto.contactEmail) ?? null;
    }
    if (dto.contactPhone !== undefined) {
      data.contactPhone = emptyToNull(dto.contactPhone) ?? null;
    }
    if (dto.websiteUrl !== undefined) {
      data.websiteUrl = emptyToNull(dto.websiteUrl) ?? null;
    }
    if (dto.logoUrl !== undefined) {
      data.logoUrl = emptyToNull(dto.logoUrl) ?? null;
    }
    if (dto.coverImageUrl !== undefined) {
      data.coverImageUrl = emptyToNull(dto.coverImageUrl) ?? null;
    }
    if (dto.languages !== undefined) {
      data.languages = dto.languages.map((lang) => lang.trim()).filter(Boolean);
    }
    if (dto.businessSettings !== undefined) {
      data.businessSettings = dto.businessSettings as Prisma.InputJsonValue;
    }
    if (dto.visibility !== undefined) {
      data.visibility = dto.visibility;
    }

    const profile = await this.prisma.providerProfile.update({
      where: { userId },
      data,
    });

    this.logger.info({
      event: 'provider_profile.updated',
      userId,
      profileId: profile.id,
    });

    return toOwnerProviderProfile(profile);
  }

  async deactivateOwn(userId: string): Promise<OwnerProviderProfile> {
    const existing = await this.findOwnOrThrow(userId);
    if (existing.status === ProfileStatus.DEACTIVATED) {
      return toOwnerProviderProfile(existing);
    }

    const profile = await this.prisma.providerProfile.update({
      where: { userId },
      data: { status: ProfileStatus.DEACTIVATED },
    });

    this.logger.info({
      event: 'provider_profile.deactivated',
      userId,
      profileId: profile.id,
    });

    return toOwnerProviderProfile(profile);
  }

  async restoreOwn(userId: string): Promise<OwnerProviderProfile> {
    const existing = await this.findOwnOrThrow(userId);
    if (existing.status === ProfileStatus.ACTIVE) {
      return toOwnerProviderProfile(existing);
    }

    const profile = await this.prisma.providerProfile.update({
      where: { userId },
      data: { status: ProfileStatus.ACTIVE },
    });

    this.logger.info({
      event: 'provider_profile.restored',
      userId,
      profileId: profile.id,
    });

    return toOwnerProviderProfile(profile);
  }

  async getPublic(profileId: string): Promise<PublicProviderProfile> {
    const profile = await this.prisma.providerProfile.findUnique({
      where: { id: profileId },
    });

    if (
      !profile ||
      profile.status !== ProfileStatus.ACTIVE ||
      profile.visibility !== ProfileVisibility.PUBLIC
    ) {
      throw new NotFoundAppError('Provider profile not found');
    }

    return toPublicProviderProfile(profile);
  }

  private async findOwnOrThrow(userId: string): Promise<ProviderProfile> {
    const profile = await this.prisma.providerProfile.findUnique({
      where: { userId },
    });
    if (!profile) {
      throw new NotFoundAppError('Provider profile not found');
    }
    return profile;
  }
}
