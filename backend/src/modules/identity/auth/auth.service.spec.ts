import { UserRole, UserStatus } from '@prisma/client';
import { PinoLogger } from 'nestjs-pino';
import {
  ConflictAppError,
  UnauthorizedAppError,
} from '../../../common/errors/app.error';
import { PasswordService } from '../authorization/password.service';
import { TokenService } from '../authorization/token.service';
import { AuthService } from './auth.service';

describe('AuthService', () => {
  const prisma = {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
    },
    refreshToken: {
      create: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    $transaction: jest.fn(),
  };

  const passwordService = {
    hash: jest.fn().mockResolvedValue('hashed'),
    verify: jest.fn(),
  } as unknown as PasswordService;

  const tokenService = {
    signAccessToken: jest.fn().mockResolvedValue({
      accessToken: 'access',
      expiresIn: 900,
    }),
    createRefreshToken: jest.fn().mockReturnValue({
      rawToken: 'refresh-raw',
      tokenHash: 'refresh-hash',
      expiresAt: new Date(Date.now() + 60_000),
    }),
    hashRefreshToken: jest.fn().mockReturnValue('refresh-hash'),
  } as unknown as TokenService;

  const logger = {
    setContext: jest.fn(),
    info: jest.fn(),
    warn: jest.fn(),
  } as unknown as PinoLogger;

  const service = new AuthService(
    prisma as never,
    passwordService,
    tokenService,
    logger,
  );

  const activeUser = {
    id: 'user-1',
    email: 'test@example.com',
    passwordHash: 'hashed',
    displayName: 'Test',
    role: UserRole.CUSTOMER,
    status: UserStatus.ACTIVE,
    createdAt: new Date('2026-01-01T00:00:00.000Z'),
    updatedAt: new Date('2026-01-01T00:00:00.000Z'),
  };

  beforeEach(() => {
    jest.clearAllMocks();
    (tokenService.createRefreshToken as jest.Mock).mockReturnValue({
      rawToken: 'refresh-raw',
      tokenHash: 'refresh-hash',
      expiresAt: new Date(Date.now() + 60_000),
    });
    (tokenService.signAccessToken as jest.Mock).mockResolvedValue({
      accessToken: 'access',
      expiresIn: 900,
    });
    (tokenService.hashRefreshToken as jest.Mock).mockReturnValue(
      'refresh-hash',
    );
    prisma.refreshToken.create.mockResolvedValue({});
  });

  it('registers a new customer user', async () => {
    prisma.user.findUnique.mockResolvedValue(null);
    prisma.user.create.mockResolvedValue(activeUser);

    const result = await service.register({
      email: 'Test@Example.com',
      password: 'password123',
      displayName: 'Test',
    });

    const createMock = prisma.user.create;
    expect(createMock).toHaveBeenCalledTimes(1);
    const createCalls = createMock.mock.calls as Array<
      [{ data: { email: string; role: UserRole; status: UserStatus } }]
    >;
    const createArg = createCalls[0][0];
    expect(createArg.data.email).toBe('test@example.com');
    expect(createArg.data.role).toBe(UserRole.CUSTOMER);
    expect(createArg.data.status).toBe(UserStatus.ACTIVE);
    expect(result.accessToken).toBe('access');
    expect(result.refreshToken).toBe('refresh-raw');
    expect(result.user).not.toHaveProperty('passwordHash');
  });

  it('rejects duplicate email registration', async () => {
    prisma.user.findUnique.mockResolvedValue(activeUser);
    await expect(
      service.register({ email: 'test@example.com', password: 'password123' }),
    ).rejects.toBeInstanceOf(ConflictAppError);
  });

  it('logs in with valid credentials', async () => {
    prisma.user.findUnique.mockResolvedValue(activeUser);
    (passwordService.verify as jest.Mock).mockResolvedValue(true);

    const result = await service.login({
      email: 'test@example.com',
      password: 'password123',
    });
    expect(result.user.id).toBe('user-1');
  });

  it('rejects invalid credentials', async () => {
    prisma.user.findUnique.mockResolvedValue(activeUser);
    (passwordService.verify as jest.Mock).mockResolvedValue(false);

    await expect(
      service.login({ email: 'test@example.com', password: 'wrong' }),
    ).rejects.toBeInstanceOf(UnauthorizedAppError);
  });

  it('rejects suspended users on login', async () => {
    prisma.user.findUnique.mockResolvedValue({
      ...activeUser,
      status: UserStatus.SUSPENDED,
    });

    await expect(
      service.login({ email: 'test@example.com', password: 'password123' }),
    ).rejects.toBeInstanceOf(UnauthorizedAppError);
  });
});
