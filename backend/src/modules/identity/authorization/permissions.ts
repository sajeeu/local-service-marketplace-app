/**
 * Identity-level permission constants.
 * Marketplace-specific permissions are out of scope until later phases.
 */
export const Permissions = {
  IDENTITY_READ_SELF: 'identity:read:self',
  IDENTITY_UPDATE_SELF: 'identity:update:self',
} as const;

export type Permission = (typeof Permissions)[keyof typeof Permissions];
