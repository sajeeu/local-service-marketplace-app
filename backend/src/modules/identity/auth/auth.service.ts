import { Injectable } from '@nestjs/common';
import { UserRole, UserStatus } from '@prisma/client';
import { PinoLogger } from 'nestjs-pino';
import {
  ConflictAppError,
  UnauthorizedAppError,
} from '../../../common/errors/app.error';
import { PrismaService } from '../../../prisma/prisma.service';
import { PasswordService } from '../authorization/password.service';
import { TokenService } from '../authorization/token.service';
import { toPublicUser, type PublicUser } from '../users/user.mapper';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

export type AuthTokensResponse = {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  user: PublicUser;
};

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly passwordService: PasswordService,
    private readonly tokenService: TokenService,
    private readonly logger: PinoLogger,
  ) {
    this.logger.setContext(AuthService.name);
  }

  async register(dto: RegisterDto): Promise<AuthTokensResponse> {
    const email = normalizeEmail(dto.email);
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) {
      this.logger.warn({ event: 'auth.register.conflict', email });
      throw new ConflictAppError('Email already registered');
    }

    const passwordHash = await this.passwordService.hash(dto.password);
    const user = await this.prisma.user.create({
      data: {
        email,
        passwordHash,
        displayName: dto.displayName?.trim() || null,
        role: UserRole.CUSTOMER,
        status: UserStatus.ACTIVE,
      },
    });

    this.logger.info({ event: 'auth.register.success', userId: user.id });
    return this.issueTokensForUser(user);
  }

  async login(dto: LoginDto): Promise<AuthTokensResponse> {
    const email = normalizeEmail(dto.email);
    const user = await this.prisma.user.findUnique({ where: { email } });

    if (!user || user.status !== UserStatus.ACTIVE) {
      this.logger.warn({
        event: 'auth.login.failure',
        reason: 'invalid_or_inactive',
      });
      throw new UnauthorizedAppError('Invalid credentials');
    }

    const passwordValid = await this.passwordService.verify(
      user.passwordHash,
      dto.password,
    );
    if (!passwordValid) {
      this.logger.warn({
        event: 'auth.login.failure',
        reason: 'bad_password',
        userId: user.id,
      });
      throw new UnauthorizedAppError('Invalid credentials');
    }

    this.logger.info({ event: 'auth.login.success', userId: user.id });
    return this.issueTokensForUser(user);
  }

  async refresh(rawRefreshToken: string): Promise<AuthTokensResponse> {
    const tokenHash = this.tokenService.hashRefreshToken(rawRefreshToken);
    const stored = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: { user: true },
    });

    if (
      !stored ||
      stored.revokedAt ||
      stored.expiresAt.getTime() <= Date.now() ||
      stored.user.status !== UserStatus.ACTIVE
    ) {
      this.logger.warn({ event: 'auth.refresh.failure' });
      throw new UnauthorizedAppError('Invalid refresh token');
    }

    const next = this.tokenService.createRefreshToken();
    const { accessToken, expiresIn } = await this.tokenService.signAccessToken({
      sub: stored.user.id,
      role: stored.user.role,
      status: stored.user.status,
    });

    await this.prisma.$transaction(async (tx) => {
      const created = await tx.refreshToken.create({
        data: {
          userId: stored.user.id,
          tokenHash: next.tokenHash,
          expiresAt: next.expiresAt,
        },
      });
      await tx.refreshToken.update({
        where: { id: stored.id },
        data: {
          revokedAt: new Date(),
          replacedByTokenId: created.id,
        },
      });
    });

    this.logger.info({ event: 'auth.refresh.success', userId: stored.user.id });
    return {
      accessToken,
      refreshToken: next.rawToken,
      expiresIn,
      user: toPublicUser(stored.user),
    };
  }

  async logout(
    userId: string,
    rawRefreshToken: string,
  ): Promise<{ success: true }> {
    const tokenHash = this.tokenService.hashRefreshToken(rawRefreshToken);
    const stored = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
    });

    if (stored && stored.userId === userId && !stored.revokedAt) {
      await this.prisma.refreshToken.update({
        where: { id: stored.id },
        data: { revokedAt: new Date() },
      });
      this.logger.info({ event: 'auth.logout.success', userId });
    } else {
      this.logger.info({ event: 'auth.logout.noop', userId });
    }

    return { success: true };
  }

  private async issueTokensForUser(
    user: Parameters<typeof toPublicUser>[0],
  ): Promise<AuthTokensResponse> {
    const { accessToken, expiresIn } = await this.tokenService.signAccessToken({
      sub: user.id,
      role: user.role,
      status: user.status,
    });
    const refresh = this.tokenService.createRefreshToken();

    await this.prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash: refresh.tokenHash,
        expiresAt: refresh.expiresAt,
      },
    });

    return {
      accessToken,
      refreshToken: refresh.rawToken,
      expiresIn,
      user: toPublicUser(user),
    };
  }
}

function normalizeEmail(email: string): string {
  return email.trim().toLowerCase();
}
