import { HealthService } from './health.service';
import { ServiceUnavailableAppError } from '../common/errors/app.error';
import type { PrismaService } from '../prisma/prisma.service';

describe('HealthService', () => {
  const prisma = {
    isReady: jest.fn(),
  } as unknown as PrismaService;

  let service: HealthService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new HealthService(prisma);
  });

  it('returns liveness status', () => {
    const result = service.getLiveness();
    expect(result.status).toBe('ok');
    expect(result.service).toBe('local-service-marketplace-api');
    expect(result.timestamp).toBeDefined();
  });

  it('returns readiness when database is up', async () => {
    (prisma.isReady as jest.Mock).mockResolvedValue(true);

    const result = await service.getReadiness();

    expect(result).toEqual(
      expect.objectContaining({
        status: 'ready',
        database: 'up',
      }),
    );
  });

  it('throws ServiceUnavailableAppError when database is down', async () => {
    (prisma.isReady as jest.Mock).mockRejectedValue(
      new Error('connection refused'),
    );

    await expect(service.getReadiness()).rejects.toBeInstanceOf(
      ServiceUnavailableAppError,
    );
  });
});
