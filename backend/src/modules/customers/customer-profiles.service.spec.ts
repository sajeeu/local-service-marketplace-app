import {
  ProfileStatus,
  type CustomerProfile,
} from '@prisma/client';
import { PinoLogger } from 'nestjs-pino';
import {
  ConflictAppError,
  NotFoundAppError,
} from '../../common/errors/app.error';
import { CustomerProfilesService } from './customer-profiles.service';

describe('CustomerProfilesService', () => {
  const prisma = {
    customerProfile: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
  };

  const logger = {
    setContext: jest.fn(),
    info: jest.fn(),
  } as unknown as PinoLogger;

  const service = new CustomerProfilesService(prisma as never, logger);

  const baseProfile: CustomerProfile = {
    id: 'cp_1',
    userId: 'user_1',
    displayName: 'Jordan',
    avatarUrl: 'https://cdn.example/avatar.png',
    contactEmail: 'jordan@example.com',
    contactPhone: '+15559876543',
    preferences: { locale: 'en' },
    savedSettings: {},
    status: ProfileStatus.ACTIVE,
    createdAt: new Date('2026-01-01T00:00:00.000Z'),
    updatedAt: new Date('2026-01-01T00:00:00.000Z'),
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('creates a customer profile', async () => {
    prisma.customerProfile.findUnique.mockResolvedValue(null);
    prisma.customerProfile.create.mockResolvedValue(baseProfile);

    const result = await service.create('user_1', {
      displayName: 'Jordan',
      contactEmail: 'jordan@example.com',
      contactPhone: '+15559876543',
      avatarUrl: 'https://cdn.example/avatar.png',
      preferences: { locale: 'en' },
    });

    expect(result.id).toBe('cp_1');
    expect(result.completion.status).toBe('COMPLETE');
  });

  it('rejects duplicate customer profile', async () => {
    prisma.customerProfile.findUnique.mockResolvedValue(baseProfile);
    await expect(
      service.create('user_1', { displayName: 'Jordan' }),
    ).rejects.toBeInstanceOf(ConflictAppError);
  });

  it('throws when profile missing', async () => {
    prisma.customerProfile.findUnique.mockResolvedValue(null);
    await expect(service.getOwn('user_1')).rejects.toBeInstanceOf(
      NotFoundAppError,
    );
  });

  it('updates and soft-deletes/restores', async () => {
    prisma.customerProfile.findUnique.mockResolvedValue(baseProfile);
    prisma.customerProfile.update.mockResolvedValue({
      ...baseProfile,
      displayName: 'Updated',
    });

    const updated = await service.updateOwn('user_1', {
      displayName: 'Updated',
    });
    expect(updated.displayName).toBe('Updated');

    prisma.customerProfile.update.mockResolvedValue({
      ...baseProfile,
      status: ProfileStatus.DEACTIVATED,
    });
    const deactivated = await service.deactivateOwn('user_1');
    expect(deactivated.status).toBe(ProfileStatus.DEACTIVATED);

    prisma.customerProfile.findUnique.mockResolvedValue({
      ...baseProfile,
      status: ProfileStatus.DEACTIVATED,
    });
    prisma.customerProfile.update.mockResolvedValue(baseProfile);
    const restored = await service.restoreOwn('user_1');
    expect(restored.status).toBe(ProfileStatus.ACTIVE);
  });
});
