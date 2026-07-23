import {
  LEGACY_TUITION_SEED_IDS,
  ProfileStatus,
  SEED_IDS,
  UserRole,
  UserStatus,
  type SeedContext,
} from './constants';

async function removeLegacyTuitionAccount(ctx: SeedContext) {
  const { prisma } = ctx;
  const { user: legacyUserId, provider: legacyProviderId } =
    LEGACY_TUITION_SEED_IDS;

  await prisma.providerIslandCoverage.deleteMany({
    where: { providerProfileId: legacyProviderId },
  });
  await prisma.providerProfile.deleteMany({
    where: { id: legacyProviderId },
  });
  await prisma.refreshToken.deleteMany({
    where: { userId: legacyUserId },
  });
  await prisma.user.deleteMany({
    where: { id: legacyUserId },
  });
}

export async function seedIdentity(ctx: SeedContext) {
  const { prisma, passwordHash } = ctx;

  await removeLegacyTuitionAccount(ctx);

  const users = [
    {
      id: SEED_IDS.users.admin,
      email: 'admin@seed.maldives.local',
      displayName: 'Platform Admin',
      role: UserRole.ADMINISTRATOR,
    },
    {
      id: SEED_IDS.users.plumbing,
      email: 'plumbing@seed.maldives.local',
      displayName: 'Ahmed Plumbing',
      role: UserRole.CUSTOMER,
    },
    {
      id: SEED_IDS.users.cleaning,
      email: 'cleaning@seed.maldives.local',
      displayName: 'Mariyam Cleaning',
      role: UserRole.CUSTOMER,
    },
    {
      id: SEED_IDS.users.photography,
      email: 'photography@seed.maldives.local',
      displayName: 'Hassan Photographer',
      role: UserRole.CUSTOMER,
    },
    {
      id: SEED_IDS.users.emptyCoverage,
      email: 'nocoverage@seed.maldives.local',
      displayName: 'New Provider',
      role: UserRole.CUSTOMER,
    },
    {
      id: SEED_IDS.users.customer,
      email: 'customer@seed.maldives.local',
      displayName: 'Aisha Customer',
      role: UserRole.CUSTOMER,
    },
  ] as const;

  for (const user of users) {
    await prisma.user.upsert({
      where: { email: user.email },
      create: {
        id: user.id,
        email: user.email,
        passwordHash,
        displayName: user.displayName,
        role: user.role,
        status: UserStatus.ACTIVE,
      },
      update: {
        passwordHash,
        displayName: user.displayName,
        role: user.role,
        status: UserStatus.ACTIVE,
      },
    });
  }

  await prisma.customerProfile.upsert({
    where: { userId: SEED_IDS.users.customer },
    create: {
      id: SEED_IDS.customer,
      userId: SEED_IDS.users.customer,
      displayName: 'Aisha Customer',
      contactEmail: 'customer@seed.maldives.local',
      status: ProfileStatus.ACTIVE,
    },
    update: {
      displayName: 'Aisha Customer',
      status: ProfileStatus.ACTIVE,
    },
  });
}
