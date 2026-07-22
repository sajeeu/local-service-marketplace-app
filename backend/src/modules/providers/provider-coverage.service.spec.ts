import { CatalogStatus, IslandType, ProfileStatus, ProfileVisibility } from '@prisma/client';
import { PinoLogger } from 'nestjs-pino';
import {
  NotFoundAppError,
  ValidationAppError,
} from '../../common/errors/app.error';
import { ProviderCoverageService } from './provider-coverage.service';

describe('ProviderCoverageService', () => {
  const prisma = {
    providerProfile: {
      findUnique: jest.fn(),
    },
    island: {
      findMany: jest.fn(),
    },
    atoll: {
      findUnique: jest.fn(),
    },
    providerIslandCoverage: {
      findMany: jest.fn(),
      deleteMany: jest.fn(),
      createMany: jest.fn(),
    },
    $transaction: jest.fn(),
  };

  const logger = {
    setContext: jest.fn(),
    info: jest.fn(),
  } as unknown as PinoLogger;

  const service = new ProviderCoverageService(prisma as never, logger);

  const now = new Date('2026-01-01T00:00:00.000Z');
  const profile = {
    id: 'pp_1',
    userId: 'user_1',
    displayName: 'Plumbing',
    businessName: null,
    description: null,
    contactEmail: null,
    contactPhone: null,
    websiteUrl: null,
    logoUrl: null,
    coverImageUrl: null,
    languages: [] as string[],
    businessSettings: {},
    visibility: ProfileVisibility.PRIVATE,
    status: ProfileStatus.ACTIVE,
    createdAt: now,
    updatedAt: now,
  };

  const maleIsland = {
    id: 'island_male',
    atollId: 'atoll_k',
    name: 'Malé',
    slug: 'male',
    type: IslandType.CAPITAL,
    displayOrder: 1,
    status: CatalogStatus.ACTIVE,
    createdAt: now,
    updatedAt: now,
    atoll: {
      id: 'atoll_k',
      name: 'Kaafu Atoll',
      code: 'K',
      description: null,
      displayOrder: 10,
      status: CatalogStatus.ACTIVE,
      createdAt: now,
      updatedAt: now,
    },
  };

  beforeEach(() => {
    jest.clearAllMocks();
    prisma.providerIslandCoverage.findMany.mockResolvedValue([]);
    prisma.$transaction.mockImplementation(
      async (fn: (tx: typeof prisma) => Promise<unknown>) => fn(prisma),
    );
  });

  it('requires a provider profile', async () => {
    prisma.providerProfile.findUnique.mockResolvedValue(null);
    await expect(service.getOwn('user_1')).rejects.toBeInstanceOf(
      NotFoundAppError,
    );
  });

  it('replaces coverage with active islands', async () => {
    prisma.providerProfile.findUnique.mockResolvedValue(profile);
    prisma.island.findMany.mockResolvedValue([{ id: 'island_male' }]);
    prisma.providerIslandCoverage.findMany.mockResolvedValue([
      { island: maleIsland },
    ]);

    const result = await service.replaceOwn('user_1', ['island_male']);

    expect(prisma.providerIslandCoverage.deleteMany).toHaveBeenCalled();
    expect(prisma.providerIslandCoverage.createMany).toHaveBeenCalled();
    expect(result.islands).toHaveLength(1);
    expect(result.atollSummaries[0]?.atollCode).toBe('K');
  });

  it('rejects inactive or missing islands', async () => {
    prisma.providerProfile.findUnique.mockResolvedValue(profile);
    prisma.island.findMany.mockResolvedValue([]);

    await expect(
      service.addIslands('user_1', ['missing']),
    ).rejects.toBeInstanceOf(ValidationAppError);
  });

  it('expands atoll to active islands', async () => {
    prisma.providerProfile.findUnique.mockResolvedValue(profile);
    prisma.atoll.findUnique.mockResolvedValue({
      id: 'atoll_k',
      status: CatalogStatus.ACTIVE,
    });
    prisma.island.findMany.mockResolvedValue([
      { id: 'island_male' },
      { id: 'island_hulhumale' },
    ]);
    prisma.providerIslandCoverage.findMany.mockResolvedValue([
      { island: maleIsland },
    ]);

    await service.addAtollIslands('user_1', 'atoll_k');

    expect(prisma.providerIslandCoverage.createMany).toHaveBeenCalledWith(
      expect.objectContaining({
        skipDuplicates: true,
        data: [
          { providerProfileId: 'pp_1', islandId: 'island_male' },
          { providerProfileId: 'pp_1', islandId: 'island_hulhumale' },
        ],
      }),
    );
  });

  it('allows empty coverage', async () => {
    prisma.providerProfile.findUnique.mockResolvedValue(profile);
    prisma.providerIslandCoverage.findMany.mockResolvedValue([]);

    const result = await service.replaceOwn('user_1', []);
    expect(result.islands).toEqual([]);
  });
});
