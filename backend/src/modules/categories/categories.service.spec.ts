import { CatalogStatus, UserRole, UserStatus } from '@prisma/client';
import { PinoLogger } from 'nestjs-pino';
import {
  ConflictAppError,
  ForbiddenAppError,
  NotFoundAppError,
  ValidationAppError,
} from '../../common/errors/app.error';
import { CategoriesService } from './categories.service';

describe('CategoriesService', () => {
  const prisma = {
    category: {
      count: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
  };

  const logger = {
    setContext: jest.fn(),
    info: jest.fn(),
  } as unknown as PinoLogger;

  const service = new CategoriesService(prisma as never, logger);

  const now = new Date('2026-01-01T00:00:00.000Z');
  const baseCategory = {
    id: 'cat_1',
    name: 'Plumbing',
    slug: 'plumbing',
    description: 'Pipes',
    icon: 'plumbing',
    parentId: null as string | null,
    displayOrder: 1,
    status: CatalogStatus.ACTIVE,
    metadata: {},
    createdAt: now,
    updatedAt: now,
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('lists active categories for anonymous users', async () => {
    prisma.category.count.mockResolvedValue(1);
    prisma.category.findMany.mockResolvedValue([baseCategory]);

    const result = await service.list({}, null);

    expect(result.data).toHaveLength(1);
    expect(result.meta?.pagination).toMatchObject({
      page: 1,
      total: 1,
    });
    expect(prisma.category.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ status: CatalogStatus.ACTIVE }),
      }),
    );
  });

  it('forbids inactive listing for non-admins', async () => {
    await expect(
      service.list(
        { status: CatalogStatus.INACTIVE },
        {
          id: 'u1',
          email: 'a@b.c',
          role: UserRole.CUSTOMER,
          status: UserStatus.ACTIVE,
        },
      ),
    ).rejects.toBeInstanceOf(ForbiddenAppError);
  });

  it('creates a category', async () => {
    prisma.category.findUnique.mockResolvedValue(null);
    prisma.category.create.mockResolvedValue(baseCategory);

    const result = await service.create({
      name: 'Plumbing',
      slug: 'plumbing',
      description: 'Pipes',
    });

    expect(result.slug).toBe('plumbing');
  });

  it('rejects duplicate slug', async () => {
    prisma.category.findUnique.mockResolvedValue(baseCategory);

    await expect(
      service.create({ name: 'Other', slug: 'plumbing' }),
    ).rejects.toBeInstanceOf(ConflictAppError);
  });

  it('soft-deactivates active category on delete', async () => {
    prisma.category.findUnique.mockResolvedValue(baseCategory);
    prisma.category.count.mockResolvedValue(0);
    prisma.category.update.mockResolvedValue({
      ...baseCategory,
      status: CatalogStatus.INACTIVE,
    });

    const result = await service.remove('cat_1');
    expect(result.status).toBe(CatalogStatus.INACTIVE);
  });

  it('rejects delete when children exist', async () => {
    prisma.category.findUnique.mockResolvedValue(baseCategory);
    prisma.category.count.mockResolvedValue(2);

    await expect(service.remove('cat_1')).rejects.toBeInstanceOf(
      ConflictAppError,
    );
  });

  it('rejects circular parent assignment', async () => {
    prisma.category.findUnique
      .mockResolvedValueOnce({ ...baseCategory, id: 'child' })
      .mockResolvedValueOnce({ ...baseCategory, id: 'parent' })
      .mockResolvedValueOnce({
        ...baseCategory,
        id: 'parent',
        parentId: 'child',
      });

    await expect(
      service.update('child', { parentId: 'parent' }),
    ).rejects.toBeInstanceOf(ValidationAppError);
  });

  it('hides inactive category from non-admin get', async () => {
    prisma.category.findUnique.mockResolvedValue({
      ...baseCategory,
      status: CatalogStatus.INACTIVE,
    });

    await expect(service.getById('cat_1', null)).rejects.toBeInstanceOf(
      NotFoundAppError,
    );
  });
});
