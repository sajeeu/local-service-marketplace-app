import { ArgumentsHost, HttpException, HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ErrorCodes } from '@local-service-marketplace/shared';
import { PinoLogger } from 'nestjs-pino';
import { AllExceptionsFilter } from './all-exceptions.filter';
import { NotFoundAppError } from '../errors/app.error';

describe('AllExceptionsFilter', () => {
  const logger = {
    setContext: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
  } as unknown as PinoLogger;

  const configService = {
    get: jest.fn().mockReturnValue('development'),
  } as unknown as ConfigService;

  const filter = new AllExceptionsFilter(logger, configService as never);

  function createHost() {
    const json = jest.fn();
    const status = jest.fn().mockReturnValue({ json });
    const response = { status };
    const host = {
      switchToHttp: () => ({
        getResponse: () => response,
      }),
    } as unknown as ArgumentsHost;
    return { host, status, json };
  }

  it('maps AppError to envelope response', () => {
    const { host, status, json } = createHost();

    filter.catch(new NotFoundAppError('Listing missing'), host);

    expect(status).toHaveBeenCalledWith(HttpStatus.NOT_FOUND);
    const payload = firstJsonPayload(json);
    expect(payload.data).toBeNull();
    expect(payload.error.code).toBe(ErrorCodes.NOT_FOUND);
    expect(payload.error.message).toBe('Listing missing');
  });

  it('maps HttpException validation failures', () => {
    const { host, status, json } = createHost();

    filter.catch(
      new HttpException(
        { message: ['email must be an email'], error: 'Bad Request' },
        HttpStatus.BAD_REQUEST,
      ),
      host,
    );

    expect(status).toHaveBeenCalledWith(HttpStatus.BAD_REQUEST);
    const payload = firstJsonPayload(json);
    expect(payload.error.code).toBe(ErrorCodes.VALIDATION_ERROR);
    expect(payload.error.message).toBe('email must be an email');
  });

  it('hides internal details in production', () => {
    (configService.get as jest.Mock).mockReturnValue('production');
    const { host, status, json } = createHost();

    filter.catch(new Error('secret stack detail'), host);

    expect(status).toHaveBeenCalledWith(HttpStatus.INTERNAL_SERVER_ERROR);
    const payload = firstJsonPayload(json);
    expect(payload.error.code).toBe(ErrorCodes.INTERNAL_ERROR);
    expect(payload.error.message).toBe('An unexpected error occurred');
  });
});

function firstJsonPayload(json: jest.Mock): {
  data: null;
  error: { code: string; message: string };
} {
  const calls = json.mock.calls as Array<
    [{ data: null; error: { code: string; message: string } }]
  >;
  return calls[0][0];
}
