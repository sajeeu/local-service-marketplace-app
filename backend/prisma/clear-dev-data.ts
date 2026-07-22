/**
 * Development-only: clears marketplace domain tables while preserving migration history.
 * Prefer `npm run db:reset` for a full migrate + seed cycle.
 */
import { PrismaClient } from '@prisma/client';

async function assertNotProduction() {
  if (process.env.NODE_ENV === 'production') {
    throw new Error('Refusing to clear database: NODE_ENV=production');
  }
}

async function main() {
  await assertNotProduction();
  const prisma = new PrismaClient();
  try {
    console.log('Clearing development data...');
    await prisma.providerIslandCoverage.deleteMany();
    await prisma.island.deleteMany();
    await prisma.atoll.deleteMany();
    await prisma.category.deleteMany();
    await prisma.providerProfile.deleteMany();
    await prisma.customerProfile.deleteMany();
    await prisma.refreshToken.deleteMany();
    await prisma.user.deleteMany();
    console.log('Clear complete.');
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
