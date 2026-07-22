import {
  INestApplication,
  ValidationPipe,
  VersioningType,
} from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import {
  CatalogStatus,
  IslandType,
  UserRole,
  UserStatus,
} from '@prisma/client';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { VALIDATION_PIPE_OPTIONS } from '../src/common/validation/validation.constants';
import { PrismaService } from '../src/prisma/prisma.service';

describe('Phase 3 Catalog & Geography API (e2e)', () => {
  let app: INestApplication<App>;

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
  };
  const category = {
    id: 'cat_plumbing',
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

  const users = new Map<string, {
    id: string;
    email: string;
    passwordHash: string;
    displayName: string | null;
    role: UserRole;
    status: UserStatus;
    createdAt: Date;
    updatedAt: Date;
  }>();

  const prismaMock = {
    onModuleInit: jest.fn(),
    onModuleDestroy: jest.fn(),
    $connect: jest.fn(),
    $disconnect: jest.fn(),
    isReady: jest.fn().mockResolvedValue(true),
    $queryRaw: jest.fn(),
    user: {
      findUnique: jest.fn(
        ({ where }: { where: { id?: string; email?: string } }) => {
          if (where.id) {
            return [...users.values()].find((u) => u.id === where.id) ?? null;
          }
          if (where.email) {
            return [...users.values()].find((u) => u.email === where.email) ?? null;
          }
          return null;
        },
      ),
    },
    atoll: {
      count: jest.fn().mockResolvedValue(1),
      findMany: jest.fn().mockResolvedValue([atoll]),
      findUnique: jest.fn().mockResolvedValue(atoll),
    },
    island: {
      count: jest.fn().mockResolvedValue(1),
      findMany: jest.fn().mockResolvedValue([{ ...island, atoll }]),
      findUnique: jest.fn().mockResolvedValue({ ...island, atoll }),
    },
    category: {
      count: jest.fn().mockResolvedValue(1),
      findMany: jest.fn().mockResolvedValue([category]),
      findUnique: jest.fn().mockResolvedValue(category),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
    refreshToken: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
    },
    providerProfile: {
      findUnique: jest.fn(),
    },
    customerProfile: {
      findUnique: jest.fn(),
    },
  };

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(prismaMock)
      .compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.enableVersioning({
      type: VersioningType.URI,
      defaultVersion: '1',
    });
    app.useGlobalPipes(new ValidationPipe(VALIDATION_PIPE_OPTIONS));
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('lists atolls publicly', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/v1/atolls')
      .expect(200);

    expect(response.body.error).toBeNull();
    expect(response.body.data[0].code).toBe('K');
    expect(response.body.meta.pagination.total).toBe(1);
  });

  it('lists islands publicly', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/v1/islands')
      .expect(200);

    expect(response.body.data[0].slug).toBe('male');
  });

  it('lists categories publicly', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/v1/categories')
      .expect(200);

    expect(response.body.data[0].slug).toBe('plumbing');
  });

  it('rejects category create without auth', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/v1/categories')
      .send({ name: 'X', slug: 'x' })
      .expect(401);

    expect(response.body.error.code).toBe('UNAUTHORIZED');
  });
});
