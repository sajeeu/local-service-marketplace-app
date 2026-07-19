import type { ErrorCode } from './error-codes';

export interface ApiErrorBody {
  code: ErrorCode | string;
  message: string;
  details?: unknown;
}

export interface ApiMeta {
  [key: string]: unknown;
}

/**
 * Standard API response envelope.
 * Success: data set, error null.
 * Failure: data null, error set.
 */
export interface ApiEnvelope<T = unknown> {
  data: T | null;
  error: ApiErrorBody | null;
  meta?: ApiMeta;
}

export function successEnvelope<T>(
  data: T,
  meta?: ApiMeta,
): ApiEnvelope<T> {
  return {
    data,
    error: null,
    ...(meta !== undefined ? { meta } : {}),
  };
}

export function errorEnvelope(
  error: ApiErrorBody,
  meta?: ApiMeta,
): ApiEnvelope<null> {
  return {
    data: null,
    error,
    ...(meta !== undefined ? { meta } : {}),
  };
}
