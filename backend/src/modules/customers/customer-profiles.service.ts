import { Injectable } from '@nestjs/common';
import {
  CustomerProfile,
  Prisma,
  ProfileStatus,
} from '@prisma/client';
import { PinoLogger } from 'nestjs-pino';
import {
  ConflictAppError,
  NotFoundAppError,
} from '../../common/errors/app.error';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreateCustomerProfileDto,
  UpdateCustomerProfileDto,
} from './dto/customer-profile.dto';
import {
  toOwnerCustomerProfile,
  type OwnerCustomerProfile,
} from './customer-profile.mapper';

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
export class CustomerProfilesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly logger: PinoLogger,
  ) {
    this.logger.setContext(CustomerProfilesService.name);
  }

  async create(
    userId: string,
    dto: CreateCustomerProfileDto,
  ): Promise<OwnerCustomerProfile> {
    const existing = await this.prisma.customerProfile.findUnique({
      where: { userId },
    });
    if (existing) {
      throw new ConflictAppError('Customer profile already exists');
    }

    const profile = await this.prisma.customerProfile.create({
      data: {
        userId,
        displayName: dto.displayName.trim(),
        avatarUrl: emptyToNull(dto.avatarUrl) ?? null,
        contactEmail: emptyToNull(dto.contactEmail) ?? null,
        contactPhone: emptyToNull(dto.contactPhone) ?? null,
        preferences: (dto.preferences ?? {}) as Prisma.InputJsonValue,
        savedSettings: (dto.savedSettings ?? {}) as Prisma.InputJsonValue,
        status: ProfileStatus.ACTIVE,
      },
    });

    this.logger.info({
      event: 'customer_profile.created',
      userId,
      profileId: profile.id,
    });

    return toOwnerCustomerProfile(profile);
  }

  async getOwn(userId: string): Promise<OwnerCustomerProfile> {
    const profile = await this.findOwnOrThrow(userId);
    return toOwnerCustomerProfile(profile);
  }

  async updateOwn(
    userId: string,
    dto: UpdateCustomerProfileDto,
  ): Promise<OwnerCustomerProfile> {
    await this.findOwnOrThrow(userId);

    const data: Prisma.CustomerProfileUpdateInput = {};

    if (dto.displayName !== undefined) {
      data.displayName = dto.displayName.trim();
    }
    if (dto.avatarUrl !== undefined) {
      data.avatarUrl = emptyToNull(dto.avatarUrl) ?? null;
    }
    if (dto.contactEmail !== undefined) {
      data.contactEmail = emptyToNull(dto.contactEmail) ?? null;
    }
    if (dto.contactPhone !== undefined) {
      data.contactPhone = emptyToNull(dto.contactPhone) ?? null;
    }
    if (dto.preferences !== undefined) {
      data.preferences = dto.preferences as Prisma.InputJsonValue;
    }
    if (dto.savedSettings !== undefined) {
      data.savedSettings = dto.savedSettings as Prisma.InputJsonValue;
    }

    const profile = await this.prisma.customerProfile.update({
      where: { userId },
      data,
    });

    this.logger.info({
      event: 'customer_profile.updated',
      userId,
      profileId: profile.id,
    });

    return toOwnerCustomerProfile(profile);
  }

  async deactivateOwn(userId: string): Promise<OwnerCustomerProfile> {
    const existing = await this.findOwnOrThrow(userId);
    if (existing.status === ProfileStatus.DEACTIVATED) {
      return toOwnerCustomerProfile(existing);
    }

    const profile = await this.prisma.customerProfile.update({
      where: { userId },
      data: { status: ProfileStatus.DEACTIVATED },
    });

    this.logger.info({
      event: 'customer_profile.deactivated',
      userId,
      profileId: profile.id,
    });

    return toOwnerCustomerProfile(profile);
  }

  async restoreOwn(userId: string): Promise<OwnerCustomerProfile> {
    const existing = await this.findOwnOrThrow(userId);
    if (existing.status === ProfileStatus.ACTIVE) {
      return toOwnerCustomerProfile(existing);
    }

    const profile = await this.prisma.customerProfile.update({
      where: { userId },
      data: { status: ProfileStatus.ACTIVE },
    });

    this.logger.info({
      event: 'customer_profile.restored',
      userId,
      profileId: profile.id,
    });

    return toOwnerCustomerProfile(profile);
  }

  private async findOwnOrThrow(userId: string): Promise<CustomerProfile> {
    const profile = await this.prisma.customerProfile.findUnique({
      where: { userId },
    });
    if (!profile) {
      throw new NotFoundAppError('Customer profile not found');
    }
    return profile;
  }
}
