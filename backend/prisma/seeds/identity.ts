import {
  ProfileStatus,
  SEED_IDS,
  UserRole,
  UserStatus,
  type SeedContext,
} from './constants';

export async function seedIdentity(ctx: SeedContext) {
  const { prisma, passwordHash } = ctx;

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
      id: SEED_IDS.users.tuition,
      email: 'tuition@seed.maldives.local',
      displayName: 'Fathimath Tutor',
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
