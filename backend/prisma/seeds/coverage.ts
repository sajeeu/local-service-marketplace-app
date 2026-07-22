import { CatalogStatus, SEED_IDS, type SeedContext } from './constants';

async function setCoverage(
  ctx: SeedContext,
  providerProfileId: string,
  islandSlugs: string[],
) {
  const islands = await ctx.prisma.island.findMany({
    where: {
      slug: { in: islandSlugs },
      status: CatalogStatus.ACTIVE,
    },
    select: { id: true, slug: true },
  });

  if (islands.length !== islandSlugs.length) {
    const found = new Set(islands.map((i) => i.slug));
    const missing = islandSlugs.filter((s) => !found.has(s));
    throw new Error(`Coverage seed missing islands: ${missing.join(', ')}`);
  }

  await ctx.prisma.providerIslandCoverage.deleteMany({
    where: { providerProfileId },
  });

  if (islands.length > 0) {
    await ctx.prisma.providerIslandCoverage.createMany({
      data: islands.map((island) => ({
        providerProfileId,
        islandId: island.id,
      })),
    });
  }
}

export async function seedCoverage(ctx: SeedContext) {
  const { prisma } = ctx;

  // Malé Plumbing Experts → Malé + Hulhumalé
  await setCoverage(ctx, SEED_IDS.providers.plumbing, ['male', 'hulhumale']);

  // Island Tuition Academy → Malé only
  await setCoverage(ctx, SEED_IDS.providers.tuition, ['male']);

  // Atoll Photography → all active Kaafu islands (atoll-wide snapshot)
  const kaafu = await prisma.atoll.findUnique({ where: { code: 'K' } });
  if (!kaafu) {
    throw new Error('Kaafu atoll missing; run geography seed first');
  }
  const kaafuIslands = await prisma.island.findMany({
    where: { atollId: kaafu.id, status: CatalogStatus.ACTIVE },
    select: { slug: true },
  });
  await setCoverage(
    ctx,
    SEED_IDS.providers.photography,
    kaafuIslands.map((i) => i.slug),
  );

  // Empty coverage provider — ensure none
  await setCoverage(ctx, SEED_IDS.providers.emptyCoverage, []);
}
