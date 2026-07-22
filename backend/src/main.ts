import { ValidationPipe, VersioningType } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import { Logger } from 'nestjs-pino';
import { json, urlencoded } from 'express';
import { AppModule } from './app.module';
import type { EnvConfig } from './config/env.schema';
import { VALIDATION_PIPE_OPTIONS } from './common/validation/validation.constants';
import { requestIdMiddleware } from './common/middleware/request-id.middleware';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    bufferLogs: true,
  });

  const configService = app.get(ConfigService<EnvConfig, true>);
  const logger = app.get(Logger);
  app.useLogger(logger);

  if (configService.get('TRUST_PROXY', { infer: true })) {
    app.set('trust proxy', 1);
  }

  app.use(requestIdMiddleware);
  app.use(helmet());

  const bodyLimit = configService.get('BODY_LIMIT', { infer: true });
  app.use(json({ limit: bodyLimit }));
  app.use(urlencoded({ extended: true, limit: bodyLimit }));

  const corsOrigins = configService
    .get('CORS_ORIGINS', { infer: true })
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
  const appEnv = configService.get('APP_ENV', { infer: true });

  app.enableCors({
    origin: (
      origin: string | undefined,
      callback: (err: Error | null, allow?: boolean) => void,
    ) => {
      if (!origin) {
        callback(null, true);
        return;
      }
      if (corsOrigins.includes(origin)) {
        callback(null, true);
        return;
      }
      // Flutter web uses a random localhost port; allow in development only.
      if (
        appEnv === 'development' &&
        /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)
      ) {
        callback(null, true);
        return;
      }
      callback(new Error(`Origin ${origin} not allowed by CORS`), false);
    },
    credentials: true,
  });

  app.setGlobalPrefix('api');
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });

  app.useGlobalPipes(new ValidationPipe(VALIDATION_PIPE_OPTIONS));

  const swaggerConfig = new DocumentBuilder()
    .setTitle('Local Service Marketplace API')
    .setDescription(
      'REST API for the local service marketplace. Responses use the shared { data, error, meta } envelope.',
    )
    .setVersion('1')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('api/docs', app, document);

  const port = configService.get('PORT', { infer: true });
  await app.listen(port);
  logger.log(
    `API listening on port ${port} (env=${configService.get('APP_ENV', { infer: true })})`,
  );
  logger.log(`OpenAPI docs available at /api/docs`);
}

void bootstrap();
