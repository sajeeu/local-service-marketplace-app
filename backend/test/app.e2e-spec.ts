import {
  INestApplication,
  ValidationPipe,
  VersioningType,
} from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { VALIDATION_PIPE_OPTIONS } from '../src/common/validation/validation.constants';
import { PrismaService } from '../src/prisma/prisma.service';

describe('API foundation (e2e)', () => {
  let app: INestApplication<App>;

  const prismaMock = {
    onModuleInit: jest.fn(),
    onModuleDestroy: jest.fn(),
    $connect: jest.fn(),
    $disconnect: jest.fn(),
    isReady: jest.fn().mockResolvedValue(true),
    $queryRaw: jest.fn(),
  };

  beforeAll(async () => {
    process.env.DATABASE_URL ??=
      'postgresql://lsm:lsm_dev_password@localhost:5432/lsm_dev?schema=public';
    process.env.APP_ENV = 'test';
    process.env.NODE_ENV = 'test';
    process.env.CORS_ORIGINS = 'http://localhost:3000';
    process.env.LOG_LEVEL = 'silent';

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

  it('GET /api/v1/health returns liveness envelope', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/v1/health')
      .expect(200);

    const body = response.body as {
      data: { status: string; service: string };
      error: null;
    };
    expect(body.error).toBeNull();
    expect(body.data.status).toBe('ok');
    expect(body.data.service).toBe('local-service-marketplace-api');
  });

  it('GET /api/v1/health/ready returns readiness envelope', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/v1/health/ready')
      .expect(200);

    const body = response.body as {
      data: { status: string; database: string };
      error: null;
    };
    expect(body.error).toBeNull();
    expect(body.data.status).toBe('ready');
    expect(body.data.database).toBe('up');
  });
});
