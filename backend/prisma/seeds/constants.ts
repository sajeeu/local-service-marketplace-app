import {
  CatalogStatus,
  IslandType,
  PrismaClient,
  ProfileStatus,
  ProfileVisibility,
  UserRole,
  UserStatus,
} from '@prisma/client';
import * as argon2 from 'argon2';

/** Deterministic seed password for all seeded users (development only). */
export const SEED_PASSWORD = 'SeedPassword123!';

export const SEED_IDS = {
  users: {
    admin: 'seed_user_admin',
    plumbing: 'seed_user_plumbing',
    cleaning: 'seed_user_cleaning',
    photography: 'seed_user_photography',
    emptyCoverage: 'seed_user_empty_coverage',
    customer: 'seed_user_customer',
  },
  providers: {
    plumbing: 'seed_provider_plumbing',
    cleaning: 'seed_provider_cleaning',
    photography: 'seed_provider_photography',
    emptyCoverage: 'seed_provider_empty',
  },
  customer: 'seed_customer_profile',
} as const;

/** Legacy tuition seed IDs — removed on each seed for idempotent cleanup. */
export const LEGACY_TUITION_SEED_IDS = {
  user: 'seed_user_tuition',
  provider: 'seed_provider_tuition',
} as const;

let cachedPasswordHash: string | null = null;

export async function seedPasswordHash(): Promise<string> {
  if (cachedPasswordHash !== null) {
    return cachedPasswordHash;
  }
  const hash = await argon2.hash(SEED_PASSWORD);
  cachedPasswordHash = hash;
  return hash;
}

export type SeedContext = {
  prisma: PrismaClient;
  passwordHash: string;
};

export {
  CatalogStatus,
  IslandType,
  ProfileStatus,
  ProfileVisibility,
  UserRole,
  UserStatus,
};
