import { Injectable } from '@nestjs/common';
import { ServiceUnavailableAppError } from '../common/errors/app.error';
import { PrismaService } from '../prisma/prisma.service';

export interface HealthStatus {
  status: 'ok';
  service: string;
  timestamp: string;
}

export interface ReadinessStatus {
  status: 'ready';
  database: 'up';
  timestamp: string;
}

@Injectable()
export class HealthService {
  constructor(private readonly prisma: PrismaService) {}

  getLiveness(): HealthStatus {
    return {
      status: 'ok',
      service: 'local-service-marketplace-api',
      timestamp: new Date().toISOString(),
    };
  }

  async getReadiness(): Promise<ReadinessStatus> {
    try {
      await this.prisma.isReady();
      return {
        status: 'ready',
        database: 'up',
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      throw new ServiceUnavailableAppError('Database is not ready', {
        database: 'down',
        reason: error instanceof Error ? error.message : 'unknown',
      });
    }
  }
}
