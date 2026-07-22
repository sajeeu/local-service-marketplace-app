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
    tuition: 'seed_user_tuition',
    photography: 'seed_user_photography',
    emptyCoverage: 'seed_user_empty_coverage',
    customer: 'seed_user_customer',
  },
  providers: {
    plumbing: 'seed_provider_plumbing',
    tuition: 'seed_provider_tuition',
    photography: 'seed_provider_photography',
    emptyCoverage: 'seed_provider_empty',
  },
  customer: 'seed_customer_profile',
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
