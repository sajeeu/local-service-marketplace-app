import { createHash, randomBytes } from 'crypto';
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { UserRole, UserStatus } from '@prisma/client';
import type { EnvConfig } from '../../../config/env.schema';

export type AccessTokenPayload = {
  sub: string;
  role: UserRole;
  status: UserStatus;
};

@Injectable()
export class TokenService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService<EnvConfig, true>,
  ) {}

  async signAccessToken(payload: AccessTokenPayload): Promise<{
    accessToken: string;
    expiresIn: number;
  }> {
    const ttl = this.configService.get('JWT_ACCESS_TTL', { infer: true });
    const expiresIn = ttlToSeconds(ttl);
    const accessToken = await this.jwtService.signAsync(payload, {
      secret: this.configService.get('JWT_ACCESS_SECRET', { infer: true }),
      expiresIn,
    });
    return { accessToken, expiresIn };
  }

  createRefreshToken(): {
    rawToken: string;
    tokenHash: string;
    expiresAt: Date;
  } {
    const rawToken = randomBytes(48).toString('base64url');
    const tokenHash = this.hashRefreshToken(rawToken);
    const ttl = this.configService.get('JWT_REFRESH_TTL', { infer: true });
    const expiresAt = new Date(Date.now() + ttlToSeconds(ttl) * 1000);
    return { rawToken, tokenHash, expiresAt };
  }

  hashRefreshToken(rawToken: string): string {
    const pepper = this.configService.get('JWT_REFRESH_SECRET', {
      infer: true,
    });
    return createHash('sha256').update(`${rawToken}.${pepper}`).digest('hex');
  }
}

export function ttlToSeconds(ttl: string): number {
  const match = /^(\d+)([smhd])$/i.exec(ttl.trim());
  if (!match) {
    return 900;
  }
  const value = Number(match[1]);
  const unit = match[2].toLowerCase();
  const multipliers: Record<string, number> = {
    s: 1,
    m: 60,
    h: 3600,
    d: 86400,
  };
  return value * (multipliers[unit] ?? 60);
}
