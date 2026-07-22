import { CatalogStatus, IslandType } from '@prisma/client';
import { NotFoundAppError } from '../../common/errors/app.error';
import { GeographyService } from './geography.service';

describe('GeographyService', () => {
  const prisma = {
    atoll: {
      count: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
    },
    island: {
      count: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
    },
  };

  const service = new GeographyService(prisma as never);

  const now = new Date('2026-01-01T00:00:00.000Z');
  const atoll = {
    id: 'atoll_k',
    name: 'Kaafu Atoll',
    code: 'K',
    description: 'Kaafu',
    displayOrder: 10,
    status: CatalogStatus.ACTIVE,
    createdAt: now,
    updatedAt: now,
  };
  const island = {
    id: 'island_male',
    atollId: 'atoll_k',
    name: 'Malé',
    slug: 'male',
    type: IslandType.CAPITAL,
    displayOrder: 1,
    status: CatalogStatus.ACTIVE,
    createdAt: now,
    updatedAt: now,
    atoll,
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('lists atolls with pagination meta', async () => {
    prisma.atoll.count.mockResolvedValue(1);
    prisma.atoll.findMany.mockResolvedValue([atoll]);

    const result = await service.listAtolls({});
    expect(result.data?.[0]?.code).toBe('K');
    expect(result.meta?.pagination).toMatchObject({ total: 1, page: 1 });
  });

  it('gets an active atoll', async () => {
    prisma.atoll.findUnique.mockResolvedValue(atoll);
    const result = await service.getAtoll('atoll_k');
    expect(result.name).toBe('Kaafu Atoll');
  });

  it('404s inactive atoll', async () => {
    prisma.atoll.findUnique.mockResolvedValue({
      ...atoll,
      status: CatalogStatus.INACTIVE,
    });
    await expect(service.getAtoll('atoll_k')).rejects.toBeInstanceOf(
      NotFoundAppError,
    );
  });

  it('lists islands by atoll', async () => {
    prisma.atoll.findUnique.mockResolvedValue(atoll);
    prisma.island.count.mockResolvedValue(1);
    prisma.island.findMany.mockResolvedValue([island]);

    const result = await service.listIslandsByAtoll('atoll_k', {});
    expect(result.data).toHaveLength(1);
  });

  it('lists islands with atoll included', async () => {
    prisma.island.count.mockResolvedValue(1);
    prisma.island.findMany.mockResolvedValue([island]);

    const result = await service.listIslands({ search: 'mal' });
    expect(result.data?.[0]?.atoll?.code).toBe('K');
  });

  it('gets an island', async () => {
    prisma.island.findUnique.mockResolvedValue(island);
    const result = await service.getIsland('island_male');
    expect(result.slug).toBe('male');
  });
});
