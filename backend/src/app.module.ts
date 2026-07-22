import { Module } from '@nestjs/common';
import { APP_FILTER, APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { ConfigService } from '@nestjs/config';
import { LoggerModule } from 'nestjs-pino';
import { randomUUID } from 'crypto';
import { AppConfigModule } from './config/config.module';
import type { EnvConfig } from './config/env.schema';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { ResponseEnvelopeInterceptor } from './common/interceptors/response-envelope.interceptor';
import { REQUEST_ID_HEADER } from './common/middleware/request-id.middleware';
import { HealthModule } from './health/health.module';
import { JwtAuthGuard } from './modules/identity/authorization/jwt-auth.guard';
import { RolesGuard } from './modules/identity/authorization/roles.guard';
import { CategoriesModule } from './modules/categories/categories.module';
import { CustomersModule } from './modules/customers/customers.module';
import { GeographyModule } from './modules/geography/geography.module';
import { IdentityModule } from './modules/identity/identity.module';
import { ProvidersModule } from './modules/providers/providers.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [
    AppConfigModule,
    LoggerModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (configService: ConfigService<EnvConfig, true>) => {
        const appEnv = configService.get('APP_ENV', { infer: true });
        const isDev = appEnv === 'development';

        return {
          pinoHttp: {
            level: configService.get('LOG_LEVEL', { infer: true }),
            genReqId: (req, res) => {
              const existing = req.headers[REQUEST_ID_HEADER];
              if (typeof existing === 'string' && existing.length > 0) {
                return existing;
              }
              const id = randomUUID();
              res.setHeader(REQUEST_ID_HEADER, id);
              return id;
            },
            transport: isDev
              ? {
                  target: 'pino-pretty',
                  options: { singleLine: true, colorize: true },
                }
              : undefined,
            redact: {
              paths: [
                'req.headers.authorization',
                'req.headers.cookie',
                'req.body.password',
                'req.body.token',
                'req.body.refreshToken',
                'req.body.accessToken',
              ],
              remove: true,
            },
            customProps: () => ({
              context: 'HTTP',
            }),
            serializers: {
              req: (req: { id?: string; method?: string; url?: string }) => ({
                id: req.id,
                method: req.method,
                url: req.url,
              }),
              res: (res: { statusCode?: number }) => ({
                statusCode: res.statusCode,
              }),
            },
          },
        };
      },
    }),
    ThrottlerModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (configService: ConfigService<EnvConfig, true>) => [
        {
          ttl: configService.get('THROTTLE_TTL_MS', { infer: true }),
          limit: configService.get('THROTTLE_LIMIT', { infer: true }),
        },
      ],
    }),
    PrismaModule,
    HealthModule,
    IdentityModule,
    ProvidersModule,
    CustomersModule,
    CategoriesModule,
    GeographyModule,
  ],
  providers: [
    {
      provide: APP_FILTER,
      useClass: AllExceptionsFilter,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: ResponseEnvelopeInterceptor,
    },
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
    {
      provide: APP_GUARD,
      useClass: RolesGuard,
    },
  ],
})
export class AppModule {}
