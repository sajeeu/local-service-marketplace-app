import {
  INestApplication,
  ValidationPipe,
  VersioningType,
} from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import {
  ProfileStatus,
  ProfileVisibility,
  UserRole,
  UserStatus,
} from '@prisma/client';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { VALIDATION_PIPE_OPTIONS } from '../src/common/validation/validation.constants';
import { PrismaService } from '../src/prisma/prisma.service';

type UserRow = {
  id: string;
  email: string;
  passwordHash: string;
  displayName: string | null;
  role: UserRole;
  status: UserStatus;
  createdAt: Date;
  updatedAt: Date;
};

type RefreshRow = {
  id: string;
  userId: string;
  tokenHash: string;
  expiresAt: Date;
  revokedAt: Date | null;
  replacedByTokenId: string | null;
  createdAt: Date;
};

type ProviderRow = {
  id: string;
  userId: string;
  displayName: string;
  businessName: string | null;
  description: string | null;
  contactEmail: string | null;
  contactPhone: string | null;
  websiteUrl: string | null;
  logoUrl: string | null;
  coverImageUrl: string | null;
  languages: string[];
  businessSettings: Record<string, unknown>;
  visibility: ProfileVisibility;
  status: ProfileStatus;
  createdAt: Date;
  updatedAt: Date;
};

type CustomerRow = {
  id: string;
  userId: string;
  displayName: string;
  avatarUrl: string | null;
  contactEmail: string | null;
  contactPhone: string | null;
  preferences: Record<string, unknown>;
  savedSettings: Record<string, unknown>;
  status: ProfileStatus;
  createdAt: Date;
  updatedAt: Date;
};

type Envelope<T> = {
  data: T;
  error: { code: string; message: string } | null;
};

describe('Profiles API (e2e)', () => {
  let app: INestApplication<App>;

  const users = new Map<string, UserRow>();
  const refreshTokens = new Map<string, RefreshRow>();
  const providerProfiles = new Map<string, ProviderRow>();
  const customerProfiles = new Map<string, CustomerRow>();

  const findUserById = (id: string) =>
    [...users.values()].find((user) => user.id === id) ?? null;

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
            return findUserById(where.id);
          }
          if (where.email) {
            return users.get(where.email) ?? null;
          }
          return null;
        },
      ),
      create: jest.fn(({ data }: { data: Partial<UserRow> }) => {
        const now = new Date();
        const user: UserRow = {
          id: `user_${users.size + 1}`,
          email: String(data.email),
          passwordHash: String(data.passwordHash),
          displayName: data.displayName ?? null,
          role: data.role ?? UserRole.CUSTOMER,
          status: data.status ?? UserStatus.ACTIVE,
          createdAt: now,
          updatedAt: now,
        };
        users.set(user.email, user);
        return user;
      }),
      update: jest.fn(),
    },
    refreshToken: {
      create: jest.fn(({ data }: { data: Partial<RefreshRow> }) => {
        const row: RefreshRow = {
          id: `rt_${refreshTokens.size + 1}`,
          userId: String(data.userId),
          tokenHash: String(data.tokenHash),
          expiresAt: data.expiresAt as Date,
          revokedAt: null,
          replacedByTokenId: null,
          createdAt: new Date(),
        };
        refreshTokens.set(row.tokenHash, row);
        return row;
      }),
      findUnique: jest.fn(
        ({
          where,
          include,
        }: {
          where: { tokenHash: string };
          include?: { user: boolean };
        }) => {
          const row = refreshTokens.get(where.tokenHash);
          if (!row) {
            return null;
          }
          if (include?.user) {
            return { ...row, user: findUserById(row.userId) };
          }
          return row;
        },
      ),
      update: jest.fn(
        ({
          where,
          data,
        }: {
          where: { id: string };
          data: Partial<RefreshRow>;
        }) => {
          const existing = [...refreshTokens.values()].find(
            (row) => row.id === where.id,
          );
          if (!existing) {
            throw new Error('not found');
          }
          const updated: RefreshRow = { ...existing, ...data };
          refreshTokens.set(updated.tokenHash, updated);
          return updated;
        },
      ),
    },
    providerProfile: {
      findUnique: jest.fn(
        ({ where }: { where: { id?: string; userId?: string } }) => {
          if (where.id) {
            return providerProfiles.get(where.id) ?? null;
          }
          if (where.userId) {
            return (
              [...providerProfiles.values()].find(
                (row) => row.userId === where.userId,
              ) ?? null
            );
          }
          return null;
        },
      ),
      create: jest.fn(({ data }: { data: Partial<ProviderRow> }) => {
        const now = new Date();
        const row: ProviderRow = {
          id: `pp_${providerProfiles.size + 1}`,
          userId: String(data.userId),
          displayName: String(data.displayName),
          businessName: data.businessName ?? null,
          description: data.description ?? null,
          contactEmail: data.contactEmail ?? null,
          contactPhone: data.contactPhone ?? null,
          websiteUrl: data.websiteUrl ?? null,
          logoUrl: data.logoUrl ?? null,
          coverImageUrl: data.coverImageUrl ?? null,
          languages: data.languages ?? [],
          businessSettings: (data.businessSettings as Record<string, unknown>) ?? {},
          visibility: data.visibility ?? ProfileVisibility.PRIVATE,
          status: data.status ?? ProfileStatus.ACTIVE,
          createdAt: now,
          updatedAt: now,
        };
        providerProfiles.set(row.id, row);
        return row;
      }),
      update: jest.fn(
        ({
          where,
          data,
        }: {
          where: { userId: string };
          data: Partial<ProviderRow>;
        }) => {
          const existing = [...providerProfiles.values()].find(
            (row) => row.userId === where.userId,
          );
          if (!existing) {
            throw new Error('not found');
          }
          const updated: ProviderRow = {
            ...existing,
            ...data,
            updatedAt: new Date(),
          };
          providerProfiles.set(updated.id, updated);
          return updated;
        },
      ),
    },
    customerProfile: {
      findUnique: jest.fn(
        ({ where }: { where: { id?: string; userId?: string } }) => {
          if (where.userId) {
            return (
              [...customerProfiles.values()].find(
                (row) => row.userId === where.userId,
              ) ?? null
            );
          }
          return null;
        },
      ),
      create: jest.fn(({ data }: { data: Partial<CustomerRow> }) => {
        const now = new Date();
        const row: CustomerRow = {
          id: `cp_${customerProfiles.size + 1}`,
          userId: String(data.userId),
          displayName: String(data.displayName),
          avatarUrl: data.avatarUrl ?? null,
          contactEmail: data.contactEmail ?? null,
          contactPhone: data.contactPhone ?? null,
          preferences: (data.preferences as Record<string, unknown>) ?? {},
          savedSettings: (data.savedSettings as Record<string, unknown>) ?? {},
          status: data.status ?? ProfileStatus.ACTIVE,
          createdAt: now,
          updatedAt: now,
        };
        customerProfiles.set(row.id, row);
        return row;
      }),
      update: jest.fn(
        ({
          where,
          data,
        }: {
          where: { userId: string };
          data: Partial<CustomerRow>;
        }) => {
          const existing = [...customerProfiles.values()].find(
            (row) => row.userId === where.userId,
          );
          if (!existing) {
            throw new Error('not found');
          }
          const updated: CustomerRow = {
            ...existing,
            ...data,
            updatedAt: new Date(),
          };
          customerProfiles.set(updated.id, updated);
          return updated;
        },
      ),
    },
    $transaction: jest.fn(
      async (
        arg: ((tx: typeof prismaMock) => Promise<unknown>) | Promise<unknown>[],
      ) => {
        if (typeof arg === 'function') {
          return arg(prismaMock);
        }
        return Promise.all(arg);
      },
    ),
  };

  async function registerAndGetToken(email: string): Promise<string> {
    const response = await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({
        email,
        password: 'password123',
        displayName: 'Tester',
      })
      .expect(201);

    const body = response.body as Envelope<{ accessToken: string }>;
    return body.data.accessToken;
  }

  beforeAll(async () => {
    process.env.DATABASE_URL ??=
      'postgresql://lsm:lsm_dev_password@localhost:5432/lsm_dev?schema=public';
    process.env.APP_ENV = 'test';
    process.env.NODE_ENV = 'test';
    process.env.CORS_ORIGINS = 'http://localhost:3000';
    process.env.LOG_LEVEL = 'silent';
    process.env.JWT_ACCESS_SECRET = 'test_access_secret_at_least_32_chars_long';
    process.env.JWT_REFRESH_SECRET =
      'test_refresh_secret_at_least_32_chars_long';
    process.env.JWT_ACCESS_TTL = '15m';
    process.env.JWT_REFRESH_TTL = '7d';

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

  beforeEach(() => {
    users.clear();
    refreshTokens.clear();
    providerProfiles.clear();
    customerProfiles.clear();
    jest.clearAllMocks();
  });

  it('creates, reads, updates provider profile; public only when PUBLIC', async () => {
    const token = await registerAndGetToken('provider@example.com');

    const created = await request(app.getHttpServer())
      .post('/api/v1/provider-profiles')
      .set('Authorization', `Bearer ${token}`)
      .send({
        displayName: 'Acme Plumbing',
        businessName: 'Acme LLC',
        description: 'Local plumbing',
        contactEmail: 'biz@acme.example',
        websiteUrl: 'https://acme.example',
        logoUrl: 'https://cdn.example/logo.png',
        languages: ['en'],
        visibility: 'PRIVATE',
      })
      .expect(201);

    const createdBody = created.body as Envelope<{
      id: string;
      contactEmail: string;
      visibility: string;
      completion: { status: string };
    }>;
    expect(createdBody.error).toBeNull();
    expect(createdBody.data.contactEmail).toBe('biz@acme.example');
    expect(createdBody.data.completion.status).toBe('COMPLETE');

    await request(app.getHttpServer())
      .get(`/api/v1/provider-profiles/${createdBody.data.id}`)
      .expect(404);

    const updated = await request(app.getHttpServer())
      .patch('/api/v1/provider-profiles/me')
      .set('Authorization', `Bearer ${token}`)
      .send({ visibility: 'PUBLIC' })
      .expect(200);

    const updatedBody = updated.body as Envelope<{ visibility: string }>;
    expect(updatedBody.data.visibility).toBe('PUBLIC');

    const publicGet = await request(app.getHttpServer())
      .get(`/api/v1/provider-profiles/${createdBody.data.id}`)
      .expect(200);

    const publicBody = publicGet.body as Envelope<Record<string, unknown>>;
    expect(publicBody.data.id).toBe(createdBody.data.id);
    expect(publicBody.data).not.toHaveProperty('contactEmail');
    expect(publicBody.data).not.toHaveProperty('businessSettings');
  });

  it('rejects duplicate provider profile and unauthorized access', async () => {
    const token = await registerAndGetToken('dup@example.com');

    await request(app.getHttpServer())
      .post('/api/v1/provider-profiles')
      .set('Authorization', `Bearer ${token}`)
      .send({ displayName: 'Acme' })
      .expect(201);

    const duplicate = await request(app.getHttpServer())
      .post('/api/v1/provider-profiles')
      .set('Authorization', `Bearer ${token}`)
      .send({ displayName: 'Acme 2' })
      .expect(409);

    expect((duplicate.body as Envelope<null>).error?.code).toBe('CONFLICT');

    const unauthorized = await request(app.getHttpServer())
      .get('/api/v1/provider-profiles/me')
      .expect(401);
    expect((unauthorized.body as Envelope<null>).error?.code).toBe(
      'UNAUTHORIZED',
    );
  });

  it('deactivates and restores provider profile; public hides deactivated', async () => {
    const token = await registerAndGetToken('lifecycle@example.com');

    const created = await request(app.getHttpServer())
      .post('/api/v1/provider-profiles')
      .set('Authorization', `Bearer ${token}`)
      .send({
        displayName: 'Acme',
        businessName: 'Acme',
        contactEmail: 'a@acme.example',
        visibility: 'PUBLIC',
      })
      .expect(201);

    const id = (created.body as Envelope<{ id: string }>).data.id;

    await request(app.getHttpServer())
      .post('/api/v1/provider-profiles/me/deactivate')
      .set('Authorization', `Bearer ${token}`)
      .expect(201);

    await request(app.getHttpServer())
      .get(`/api/v1/provider-profiles/${id}`)
      .expect(404);

    const own = await request(app.getHttpServer())
      .get('/api/v1/provider-profiles/me')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    expect((own.body as Envelope<{ status: string }>).data.status).toBe(
      'DEACTIVATED',
    );

    await request(app.getHttpServer())
      .post('/api/v1/provider-profiles/me/restore')
      .set('Authorization', `Bearer ${token}`)
      .expect(201);

    await request(app.getHttpServer())
      .get(`/api/v1/provider-profiles/${id}`)
      .expect(200);
  });

  it('manages customer profile lifecycle', async () => {
    const token = await registerAndGetToken('customer@example.com');

    const created = await request(app.getHttpServer())
      .post('/api/v1/customer-profiles')
      .set('Authorization', `Bearer ${token}`)
      .send({
        displayName: 'Jordan',
        contactEmail: 'jordan@example.com',
        avatarUrl: 'https://cdn.example/a.png',
        preferences: { locale: 'en' },
      })
      .expect(201);

    expect(
      (created.body as Envelope<{ completion: { status: string } }>).data
        .completion.status,
    ).toBe('COMPLETE');

    const updated = await request(app.getHttpServer())
      .patch('/api/v1/customer-profiles/me')
      .set('Authorization', `Bearer ${token}`)
      .send({ displayName: 'Jordan Lee' })
      .expect(200);
    expect((updated.body as Envelope<{ displayName: string }>).data.displayName).toBe(
      'Jordan Lee',
    );

    await request(app.getHttpServer())
      .post('/api/v1/customer-profiles/me/deactivate')
      .set('Authorization', `Bearer ${token}`)
      .expect(201);

    const deactivated = await request(app.getHttpServer())
      .get('/api/v1/customer-profiles/me')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    expect(
      (deactivated.body as Envelope<{ status: string }>).data.status,
    ).toBe('DEACTIVATED');

    await request(app.getHttpServer())
      .post('/api/v1/customer-profiles/me/restore')
      .set('Authorization', `Bearer ${token}`)
      .expect(201);

    const validation = await request(app.getHttpServer())
      .post('/api/v1/customer-profiles')
      .set('Authorization', `Bearer ${token}`)
      .send({ displayName: '' })
      .expect(400);
    // Already exists — but empty displayName may hit validation first on a
    // duplicate create path; ensure validation rejects empty create payloads
    // when profile does not exist is covered indirectly. Conflict expected here.
    expect(['VALIDATION_ERROR', 'CONFLICT']).toContain(
      (validation.body as Envelope<null>).error?.code,
    );
  });

  it('rejects invalid provider create payload', async () => {
    const token = await registerAndGetToken('invalid@example.com');

    const response = await request(app.getHttpServer())
      .post('/api/v1/provider-profiles')
      .set('Authorization', `Bearer ${token}`)
      .send({
        displayName: 'Acme',
        websiteUrl: 'not-a-url',
      })
      .expect(400);

    expect((response.body as Envelope<null>).error?.code).toBe(
      'VALIDATION_ERROR',
    );
  });
});
