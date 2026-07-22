/**
 * Permission constants for documentation and future policy checks.
 * Ownership for profile endpoints is enforced in domain services via userId.
 */
export const Permissions = {
  IDENTITY_READ_SELF: 'identity:read:self',
  IDENTITY_UPDATE_SELF: 'identity:update:self',
  PROVIDER_PROFILE_CREATE_SELF: 'provider_profile:create:self',
  PROVIDER_PROFILE_READ_SELF: 'provider_profile:read:self',
  PROVIDER_PROFILE_UPDATE_SELF: 'provider_profile:update:self',
  PROVIDER_PROFILE_DEACTIVATE_SELF: 'provider_profile:deactivate:self',
  PROVIDER_PROFILE_RESTORE_SELF: 'provider_profile:restore:self',
  PROVIDER_PROFILE_READ_PUBLIC: 'provider_profile:read:public',
  CUSTOMER_PROFILE_CREATE_SELF: 'customer_profile:create:self',
  CUSTOMER_PROFILE_READ_SELF: 'customer_profile:read:self',
  CUSTOMER_PROFILE_UPDATE_SELF: 'customer_profile:update:self',
  CUSTOMER_PROFILE_DEACTIVATE_SELF: 'customer_profile:deactivate:self',
  CUSTOMER_PROFILE_RESTORE_SELF: 'customer_profile:restore:self',
} as const;

export type Permission = (typeof Permissions)[keyof typeof Permissions];
