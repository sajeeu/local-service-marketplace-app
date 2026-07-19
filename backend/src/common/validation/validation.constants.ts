/**
 * Shared ValidationPipe defaults for request DTOs.
 * Controllers should rely on class-validator decorators on DTO classes.
 */
export const VALIDATION_PIPE_OPTIONS = {
  whitelist: true,
  forbidNonWhitelisted: true,
  transform: true,
  transformOptions: {
    enableImplicitConversion: true,
  },
} as const;
