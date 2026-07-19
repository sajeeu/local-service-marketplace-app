import {
  INestApplication,
  ValidationPipe,
  VersioningType,
} from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { UserRole, UserStatus } from '@prisma/client';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { VALIDATION_PIPE_OPTIONS } from '../src/common/validation/validation.constants';
import { PasswordService } from '../src/modules/identity/authorization/password.service';
import { TokenService } from '../src/modules/identity/authorization/token.service';
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

type Envelope<T> = {
  data: T;
  error: { code: string; message: string } | null;
};

describe('Identity API (e2e)', () => {
  let app: INestApplication<App>;
  let tokenService: TokenService;
  let passwordService: PasswordService;

  const users = new Map<string, UserRow>();
  const refreshTokens = new Map<string, RefreshRow>();

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
            return (
              [...users.values()].find((user) => user.id === where.id) ?? null
            );
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
      update: jest.fn(
        ({
          where,
          data,
        }: {
          where: { id: string };
          data: Partial<UserRow>;
        }) => {
          const existing = [...users.values()].find(
            (user) => user.id === where.id,
          );
          if (!existing) {
            throw new Error('not found');
          }
          const updated: UserRow = {
            ...existing,
            ...data,
            updatedAt: new Date(),
          };
          users.set(updated.email, updated);
          return updated;
        },
      ),
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
            const user = [...users.values()].find(
              (entry) => entry.id === row.userId,
            );
            return { ...row, user };
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

    tokenService = app.get(TokenService);
    passwordService = app.get(PasswordService);
  });

  afterAll(async () => {
    await app.close();
  });

  beforeEach(() => {
    users.clear();
    refreshTokens.clear();
    jest.clearAllMocks();
  });

  it('registers, fetches me, and logs out', async () => {
    const register = await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({
        email: 'new@example.com',
        password: 'password123',
        displayName: 'New User',
      })
      .expect(201);

    const registerBody = register.body as Envelope<{
      accessToken: string;
      refreshToken: string;
      user: { email: string; role: string };
    }>;

    expect(registerBody.error).toBeNull();
    expect(registerBody.data.user.email).toBe('new@example.com');
    expect(registerBody.data.user.role).toBe(UserRole.CUSTOMER);
    expect(registerBody.data.accessToken).toBeTruthy();

    const me = await request(app.getHttpServer())
      .get('/api/v1/users/me')
      .set('Authorization', `Bearer ${registerBody.data.accessToken}`)
      .expect(200);

    const meBody = me.body as Envelope<{ email: string }>;
    expect(meBody.data.email).toBe('new@example.com');
    expect(meBody.data).not.toHaveProperty('passwordHash');

    await request(app.getHttpServer())
      .post('/api/v1/auth/logout')
      .set('Authorization', `Bearer ${registerBody.data.accessToken}`)
      .send({ refreshToken: registerBody.data.refreshToken })
      .expect(200);
  });

  it('rejects invalid login credentials', async () => {
    const hash = await passwordService.hash('password123');
    users.set('login@example.com', {
      id: 'user_login',
      email: 'login@example.com',
      passwordHash: hash,
      displayName: null,
      role: UserRole.CUSTOMER,
      status: UserStatus.ACTIVE,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    const response = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email: 'login@example.com', password: 'wrong-password' })
      .expect(401);

    const body = response.body as Envelope<null>;
    expect(body.error?.code).toBe('UNAUTHORIZED');
  });

  it('returns validation errors for weak registration', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({ email: 'not-an-email', password: 'short' })
      .expect(400);

    const body = response.body as Envelope<null>;
    expect(body.error?.code).toBe('VALIDATION_ERROR');
  });

  it('rejects unauthorized access to /users/me', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/v1/users/me')
      .expect(401);

    const body = response.body as Envelope<null>;
    expect(body.error?.code).toBe('UNAUTHORIZED');
  });

  it('rotates refresh tokens', async () => {
    const hash = await passwordService.hash('password123');
    const user: UserRow = {
      id: 'user_refresh',
      email: 'refresh@example.com',
      passwordHash: hash,
      displayName: null,
      role: UserRole.CUSTOMER,
      status: UserStatus.ACTIVE,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    users.set(user.email, user);

    const login = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email: 'refresh@example.com', password: 'password123' })
      .expect(200);

    const loginBody = login.body as Envelope<{
      refreshToken: string;
      accessToken: string;
    }>;
    const oldRefresh = loginBody.data.refreshToken;

    const refreshed = await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: oldRefresh })
      .expect(200);

    const refreshedBody = refreshed.body as Envelope<{
      refreshToken: string;
      accessToken: string;
    }>;

    expect(refreshedBody.data.refreshToken).toBeTruthy();
    expect(refreshedBody.data.refreshToken).not.toEqual(oldRefresh);
    expect(refreshedBody.data.accessToken).toBeTruthy();

    await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: oldRefresh })
      .expect(401);

    expect(tokenService.hashRefreshToken(oldRefresh)).toBeTruthy();
  });
});
