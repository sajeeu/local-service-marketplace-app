import { ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { UserRole, UserStatus } from '@prisma/client';
import { ForbiddenAppError } from '../../../common/errors/app.error';
import { RolesGuard } from './roles.guard';

describe('RolesGuard', () => {
  const reflector = {
    getAllAndOverride: jest.fn(),
  } as unknown as Reflector;
  const guard = new RolesGuard(reflector);

  function createContext(role?: UserRole): ExecutionContext {
    return {
      getHandler: () => ({}),
      getClass: () => ({}),
      switchToHttp: () => ({
        getRequest: () =>
          role
            ? {
                user: {
                  id: 'u1',
                  email: 'a@b.com',
                  role,
                  status: UserStatus.ACTIVE,
                },
              }
            : {},
      }),
    } as unknown as ExecutionContext;
  }

  it('allows when no roles are required', () => {
    (reflector.getAllAndOverride as jest.Mock).mockReturnValue(undefined);
    expect(guard.canActivate(createContext(UserRole.CUSTOMER))).toBe(true);
  });

  it('allows matching role', () => {
    (reflector.getAllAndOverride as jest.Mock).mockReturnValue([
      UserRole.ADMINISTRATOR,
    ]);
    expect(guard.canActivate(createContext(UserRole.ADMINISTRATOR))).toBe(true);
  });

  it('rejects mismatched role', () => {
    (reflector.getAllAndOverride as jest.Mock).mockReturnValue([
      UserRole.ADMINISTRATOR,
    ]);
    expect(() => guard.canActivate(createContext(UserRole.CUSTOMER))).toThrow(
      ForbiddenAppError,
    );
  });
});
