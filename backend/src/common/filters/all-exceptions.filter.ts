import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  ErrorCodes,
  errorEnvelope,
  type ApiEnvelope,
} from '@local-service-marketplace/shared';
import type { Response } from 'express';
import { PinoLogger } from 'nestjs-pino';
import { AppError } from '../errors/app.error';
import type { EnvConfig } from '../../config/env.schema';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  constructor(
    private readonly logger: PinoLogger,
    private readonly configService: ConfigService<EnvConfig, true>,
  ) {
    this.logger.setContext(AllExceptionsFilter.name);
  }

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const appEnv = this.configService.get('APP_ENV', { infer: true });
    const isProduction = appEnv === 'production';

    const { statusCode, body } = this.mapException(exception, isProduction);

    if (statusCode >= 500) {
      this.logger.error(
        { err: exception, statusCode },
        'Unhandled server error',
      );
    } else {
      this.logger.warn({ err: exception, statusCode }, 'Request failed');
    }

    response.status(statusCode).json(body);
  }

  private mapException(
    exception: unknown,
    isProduction: boolean,
  ): { statusCode: number; body: ApiEnvelope<null> } {
    if (exception instanceof AppError) {
      return {
        statusCode: exception.statusCode,
        body: errorEnvelope({
          code: exception.code,
          message: exception.message,
          details: exception.details,
        }),
      };
    }

    if (exception instanceof HttpException) {
      const statusCode = exception.getStatus();
      const exceptionResponse = exception.getResponse();
      const details =
        typeof exceptionResponse === 'object' ? exceptionResponse : undefined;
      const message =
        typeof exceptionResponse === 'string'
          ? exceptionResponse
          : ((exceptionResponse as { message?: string | string[] }).message ??
            exception.message);

      const normalizedMessage = Array.isArray(message)
        ? message.join('; ')
        : message;

      return {
        statusCode,
        body: errorEnvelope({
          code: this.codeForHttpStatus(statusCode),
          message: normalizedMessage,
          details: statusCode === 400 ? details : undefined,
        }),
      };
    }

    return {
      statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
      body: errorEnvelope({
        code: ErrorCodes.INTERNAL_ERROR,
        message: isProduction
          ? 'An unexpected error occurred'
          : exception instanceof Error
            ? exception.message
            : 'An unexpected error occurred',
      }),
    };
  }

  private codeForHttpStatus(status: number): string {
    switch (status) {
      case 400:
        return ErrorCodes.VALIDATION_ERROR;
      case 401:
        return ErrorCodes.UNAUTHORIZED;
      case 403:
        return ErrorCodes.FORBIDDEN;
      case 404:
        return ErrorCodes.NOT_FOUND;
      case 409:
        return ErrorCodes.CONFLICT;
      case 503:
        return ErrorCodes.SERVICE_UNAVAILABLE;
      default:
        return ErrorCodes.INTERNAL_ERROR;
    }
  }
}
