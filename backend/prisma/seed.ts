import { PrismaClient } from '@prisma/client';
import { SEED_PASSWORD, seedPasswordHash, type SeedContext } from './seeds/constants';
import { seedCategories } from './seeds/categories';
import { seedCoverage } from './seeds/coverage';
import { seedGeography } from './seeds/geography';
import { seedIdentity } from './seeds/identity';
import { seedProviders } from './seeds/providers';

async function assertNotProduction() {
  if (process.env.NODE_ENV === 'production') {
    throw new Error(
      'Refusing to run development seeds: NODE_ENV=production',
    );
  }
}

async function main() {
  await assertNotProduction();

  const prisma = new PrismaClient();
  try {
    const passwordHash = await seedPasswordHash();
    const ctx: SeedContext = { prisma, passwordHash };

    console.log('Seeding development database (Maldives marketplace)...');

    await seedIdentity(ctx);
    await seedProviders(ctx);
    await seedCategories(ctx);
    await seedGeography(ctx);
    await seedCoverage(ctx);

    console.log('Seed complete.');
    console.log(`Default password for seeded users: ${SEED_PASSWORD}`);
    console.log(
      'Accounts: admin@seed.maldives.local, plumbing@seed.maldives.local, cleaning@seed.maldives.local, photography@seed.maldives.local, nocoverage@seed.maldives.local, customer@seed.maldives.local',
    );
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
