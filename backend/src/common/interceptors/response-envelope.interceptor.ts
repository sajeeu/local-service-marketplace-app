import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import {
  successEnvelope,
  type ApiEnvelope,
} from '@local-service-marketplace/shared';
import { Observable, map } from 'rxjs';

@Injectable()
export class ResponseEnvelopeInterceptor implements NestInterceptor {
  intercept(
    _context: ExecutionContext,
    next: CallHandler,
  ): Observable<ApiEnvelope<unknown>> {
    return next.handle().pipe(
      map((data: unknown) => {
        if (this.isAlreadyEnvelope(data)) {
          return data;
        }
        return successEnvelope(data ?? null);
      }),
    );
  }

  private isAlreadyEnvelope(data: unknown): data is ApiEnvelope<unknown> {
    if (!data || typeof data !== 'object') {
      return false;
    }
    return 'data' in data && 'error' in data;
  }
}
