import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { UserRole, UserStatus } from '@prisma/client';
import { TokenService, ttlToSeconds } from './token.service';

describe('TokenService', () => {
  const jwtService = {
    signAsync: jest.fn().mockResolvedValue('access.jwt'),
  } as unknown as JwtService;

  const configService = {
    get: jest.fn((key: string) => {
      const values: Record<string, string> = {
        JWT_ACCESS_TTL: '15m',
        JWT_ACCESS_SECRET: 'test_access_secret_at_least_32_chars',
        JWT_REFRESH_TTL: '7d',
        JWT_REFRESH_SECRET: 'test_refresh_secret_at_least_32_chars',
      };
      return values[key];
    }),
  } as unknown as ConfigService;

  const service = new TokenService(jwtService, configService as never);

  it('parses TTL strings', () => {
    expect(ttlToSeconds('15m')).toBe(900);
    expect(ttlToSeconds('7d')).toBe(604800);
  });

  it('signs access tokens', async () => {
    const result = await service.signAccessToken({
      sub: 'user-1',
      role: UserRole.CUSTOMER,
      status: UserStatus.ACTIVE,
    });
    expect(result.accessToken).toBe('access.jwt');
    expect(result.expiresIn).toBe(900);
  });

  it('creates hashed refresh tokens', () => {
    const first = service.createRefreshToken();
    const second = service.createRefreshToken();
    expect(first.rawToken).not.toEqual(second.rawToken);
    expect(first.tokenHash).toEqual(service.hashRefreshToken(first.rawToken));
    expect(first.expiresAt.getTime()).toBeGreaterThan(Date.now());
  });
});
