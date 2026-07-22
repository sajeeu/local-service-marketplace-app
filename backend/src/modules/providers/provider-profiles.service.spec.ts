import {
  ProfileStatus,
  ProfileVisibility,
  type ProviderProfile,
} from '@prisma/client';
import { PinoLogger } from 'nestjs-pino';
import {
  ConflictAppError,
  NotFoundAppError,
} from '../../common/errors/app.error';
import { ProviderProfilesService } from './provider-profiles.service';

describe('ProviderProfilesService', () => {
  const prisma = {
    providerProfile: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
  };

  const logger = {
    setContext: jest.fn(),
    info: jest.fn(),
  } as unknown as PinoLogger;

  const service = new ProviderProfilesService(prisma as never, logger);

  const baseProfile: ProviderProfile = {
    id: 'pp_1',
    userId: 'user_1',
    displayName: 'Acme',
    businessName: 'Acme LLC',
    description: 'Plumbing',
    contactEmail: 'biz@acme.example',
    contactPhone: '+15551234567',
    websiteUrl: 'https://acme.example',
    logoUrl: 'https://cdn.example/logo.png',
    coverImageUrl: null,
    languages: ['en'],
    businessSettings: {},
    visibility: ProfileVisibility.PRIVATE,
    status: ProfileStatus.ACTIVE,
    createdAt: new Date('2026-01-01T00:00:00.000Z'),
    updatedAt: new Date('2026-01-01T00:00:00.000Z'),
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('creates a provider profile for a user', async () => {
    prisma.providerProfile.findUnique.mockResolvedValue(null);
    prisma.providerProfile.create.mockResolvedValue(baseProfile);

    const result = await service.create('user_1', {
      displayName: 'Acme',
      businessName: 'Acme LLC',
      description: 'Plumbing',
      contactEmail: 'biz@acme.example',
      contactPhone: '+15551234567',
      websiteUrl: 'https://acme.example',
      logoUrl: 'https://cdn.example/logo.png',
      languages: ['en'],
    });

    expect(result.id).toBe('pp_1');
    expect(result.completion.status).toBe('COMPLETE');
    expect(result.contactEmail).toBe('biz@acme.example');
    expect(prisma.providerProfile.create).toHaveBeenCalledTimes(1);
  });

  it('rejects duplicate provider profile creation', async () => {
    prisma.providerProfile.findUnique.mockResolvedValue(baseProfile);

    await expect(
      service.create('user_1', { displayName: 'Acme' }),
    ).rejects.toBeInstanceOf(ConflictAppError);
  });

  it('returns own profile including deactivated', async () => {
    prisma.providerProfile.findUnique.mockResolvedValue({
      ...baseProfile,
      status: ProfileStatus.DEACTIVATED,
    });

    const result = await service.getOwn('user_1');
    expect(result.status).toBe(ProfileStatus.DEACTIVATED);
  });

  it('throws when own profile is missing', async () => {
    prisma.providerProfile.findUnique.mockResolvedValue(null);
    await expect(service.getOwn('user_1')).rejects.toBeInstanceOf(
      NotFoundAppError,
    );
  });

  it('updates own profile fields', async () => {
    prisma.providerProfile.findUnique.mockResolvedValue(baseProfile);
    prisma.providerProfile.update.mockResolvedValue({
      ...baseProfile,
      displayName: 'Updated',
      visibility: ProfileVisibility.PUBLIC,
    });

    const result = await service.updateOwn('user_1', {
      displayName: 'Updated',
      visibility: ProfileVisibility.PUBLIC,
    });

    expect(result.displayName).toBe('Updated');
    expect(result.visibility).toBe(ProfileVisibility.PUBLIC);
  });

  it('deactivates and restores idempotently', async () => {
    prisma.providerProfile.findUnique.mockResolvedValue(baseProfile);
    prisma.providerProfile.update.mockResolvedValue({
      ...baseProfile,
      status: ProfileStatus.DEACTIVATED,
    });

    const deactivated = await service.deactivateOwn('user_1');
    expect(deactivated.status).toBe(ProfileStatus.DEACTIVATED);

    prisma.providerProfile.findUnique.mockResolvedValue({
      ...baseProfile,
      status: ProfileStatus.DEACTIVATED,
    });
    const already = await service.deactivateOwn('user_1');
    expect(already.status).toBe(ProfileStatus.DEACTIVATED);
    expect(prisma.providerProfile.update).toHaveBeenCalledTimes(1);

    prisma.providerProfile.update.mockResolvedValue(baseProfile);
    const restored = await service.restoreOwn('user_1');
    expect(restored.status).toBe(ProfileStatus.ACTIVE);
  });

  it('returns public profile only when ACTIVE and PUBLIC', async () => {
    prisma.providerProfile.findUnique.mockResolvedValue({
      ...baseProfile,
      visibility: ProfileVisibility.PUBLIC,
    });

    const publicProfile = await service.getPublic('pp_1');
    expect(publicProfile.id).toBe('pp_1');
    expect(publicProfile).not.toHaveProperty('contactEmail');
    expect(publicProfile).not.toHaveProperty('businessSettings');

    prisma.providerProfile.findUnique.mockResolvedValue(baseProfile);
    await expect(service.getPublic('pp_1')).rejects.toBeInstanceOf(
      NotFoundAppError,
    );
  });
});
