import { HttpStatus } from '@nestjs/common';
import { ErrorCodes, type ErrorCode } from '@local-service-marketplace/shared';

export class AppError extends Error {
  readonly code: ErrorCode;
  readonly statusCode: number;
  readonly details?: unknown;
  readonly isOperational: boolean;

  constructor(params: {
    message: string;
    code: ErrorCode;
    statusCode: number;
    details?: unknown;
    isOperational?: boolean;
    cause?: unknown;
  }) {
    super(params.message, params.cause ? { cause: params.cause } : undefined);
    this.name = this.constructor.name;
    this.code = params.code;
    this.statusCode = params.statusCode;
    this.details = params.details;
    this.isOperational = params.isOperational ?? true;
  }
}

export class ValidationAppError extends AppError {
  constructor(message = 'Validation failed', details?: unknown) {
    super({
      message,
      code: ErrorCodes.VALIDATION_ERROR,
      statusCode: HttpStatus.BAD_REQUEST,
      details,
    });
  }
}

export class UnauthorizedAppError extends AppError {
  constructor(message = 'Authentication required') {
    super({
      message,
      code: ErrorCodes.UNAUTHORIZED,
      statusCode: HttpStatus.UNAUTHORIZED,
    });
  }
}

export class ForbiddenAppError extends AppError {
  constructor(message = 'Access denied') {
    super({
      message,
      code: ErrorCodes.FORBIDDEN,
      statusCode: HttpStatus.FORBIDDEN,
    });
  }
}

export class NotFoundAppError extends AppError {
  constructor(message = 'Resource not found') {
    super({
      message,
      code: ErrorCodes.NOT_FOUND,
      statusCode: HttpStatus.NOT_FOUND,
    });
  }
}

export class ConflictAppError extends AppError {
  constructor(message = 'Conflict', details?: unknown) {
    super({
      message,
      code: ErrorCodes.CONFLICT,
      statusCode: HttpStatus.CONFLICT,
      details,
    });
  }
}

export class InternalAppError extends AppError {
  constructor(message = 'Internal server error', cause?: unknown) {
    super({
      message,
      code: ErrorCodes.INTERNAL_ERROR,
      statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
      isOperational: false,
      cause,
    });
  }
}

export class ServiceUnavailableAppError extends AppError {
  constructor(message = 'Service unavailable', details?: unknown) {
    super({
      message,
      code: ErrorCodes.SERVICE_UNAVAILABLE,
      statusCode: HttpStatus.SERVICE_UNAVAILABLE,
      details,
    });
  }
}
