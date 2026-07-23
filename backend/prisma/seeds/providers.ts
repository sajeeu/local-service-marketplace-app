import {
  ProfileStatus,
  ProfileVisibility,
  SEED_IDS,
  type SeedContext,
} from './constants';

export async function seedProviders(ctx: SeedContext) {
  const { prisma } = ctx;

  const providers = [
    {
      id: SEED_IDS.providers.plumbing,
      userId: SEED_IDS.users.plumbing,
      displayName: 'Malé Plumbing Experts',
      businessName: 'Malé Plumbing Experts',
      description:
        'Licensed plumbing and pipe repair across Malé and Hulhumalé.',
      contactEmail: 'plumbing@seed.maldives.local',
      contactPhone: '+9607001001',
      languages: ['en', 'dv'],
      visibility: ProfileVisibility.PUBLIC,
    },
    {
      id: SEED_IDS.providers.cleaning,
      userId: SEED_IDS.users.cleaning,
      displayName: 'Hulhumalé Cleaning Experts',
      businessName: 'Hulhumalé Cleaning Experts',
      description:
        'Residential and office cleaning across Hulhumalé.',
      contactEmail: 'cleaning@seed.maldives.local',
      contactPhone: '+9607001002',
      languages: ['en', 'dv'],
      visibility: ProfileVisibility.PUBLIC,
    },
    {
      id: SEED_IDS.providers.photography,
      userId: SEED_IDS.users.photography,
      displayName: 'Atoll Photography Services',
      businessName: 'Atoll Photography Services',
      description:
        'Resort and event photography across Kaafu and nearby islands.',
      contactEmail: 'photography@seed.maldives.local',
      contactPhone: '+9607001003',
      languages: ['en'],
      visibility: ProfileVisibility.PUBLIC,
    },
    {
      id: SEED_IDS.providers.emptyCoverage,
      userId: SEED_IDS.users.emptyCoverage,
      displayName: 'New Island Services',
      businessName: 'New Island Services',
      description: 'Provider with no service coverage yet (empty-state demo).',
      contactEmail: 'nocoverage@seed.maldives.local',
      languages: ['en'],
      visibility: ProfileVisibility.PRIVATE,
    },
  ] as const;

  for (const provider of providers) {
    await prisma.providerProfile.upsert({
      where: { userId: provider.userId },
      create: {
        id: provider.id,
        userId: provider.userId,
        displayName: provider.displayName,
        businessName: provider.businessName,
        description: provider.description,
        contactEmail: provider.contactEmail,
        contactPhone: 'contactPhone' in provider ? provider.contactPhone : null,
        languages: [...provider.languages],
        visibility: provider.visibility,
        status: ProfileStatus.ACTIVE,
      },
      update: {
        displayName: provider.displayName,
        businessName: provider.businessName,
        description: provider.description,
        contactEmail: provider.contactEmail,
        contactPhone: 'contactPhone' in provider ? provider.contactPhone : null,
        languages: [...provider.languages],
        visibility: provider.visibility,
        status: ProfileStatus.ACTIVE,
      },
    });
  }
}
