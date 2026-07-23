import { CatalogStatus, type SeedContext } from './constants';

type CategorySeed = {
  slug: string;
  name: string;
  description: string;
  icon: string;
  displayOrder: number;
  status?: CatalogStatus;
  children?: Omit<CategorySeed, 'children'>[];
};

/** Removed education taxonomy — deleted on each seed for idempotent cleanup. */
const REMOVED_CATEGORY_SLUGS = [
  'tuition-classes',
  'language-classes',
  'computer-training',
  'music-lessons',
  'education',
] as const;

const CATEGORY_TREE: CategorySeed[] = [
  {
    slug: 'home-services',
    name: 'Home Services',
    description: 'Repairs and maintenance for homes and apartments.',
    icon: 'home',
    displayOrder: 10,
    children: [
      {
        slug: 'plumbing',
        name: 'Plumbing',
        description: 'Pipes, fixtures, and water systems.',
        icon: 'plumbing',
        displayOrder: 1,
      },
      {
        slug: 'electrical',
        name: 'Electrical',
        description: 'Wiring, outlets, and electrical repairs.',
        icon: 'electrical',
        displayOrder: 2,
      },
      {
        slug: 'air-conditioning-repair',
        name: 'Air Conditioning Repair',
        description: 'AC installation and servicing.',
        icon: 'ac',
        displayOrder: 3,
      },
      {
        slug: 'cleaning',
        name: 'Cleaning',
        description: 'Home and office cleaning.',
        icon: 'cleaning',
        displayOrder: 4,
      },
      {
        slug: 'painting',
        name: 'Painting',
        description: 'Interior and exterior painting.',
        icon: 'painting',
        displayOrder: 5,
      },
      {
        slug: 'carpentry',
        name: 'Carpentry',
        description: 'Furniture and woodwork.',
        icon: 'carpentry',
        displayOrder: 6,
      },
      {
        slug: 'appliance-repair',
        name: 'Appliance Repair',
        description: 'Household appliance servicing.',
        icon: 'appliance',
        displayOrder: 7,
      },
      {
        slug: 'gardening',
        name: 'Gardening',
        description: 'Garden care and plant maintenance.',
        icon: 'gardening',
        displayOrder: 8,
      },
      {
        slug: 'home-maintenance',
        name: 'Home Maintenance',
        description: 'General home upkeep and handyman work.',
        icon: 'maintenance',
        displayOrder: 9,
      },
      {
        slug: 'moving-services',
        name: 'Moving Services',
        description: 'Local moving and relocation help.',
        icon: 'moving',
        displayOrder: 10,
      },
      {
        slug: 'landscaping',
        name: 'Landscaping',
        description: 'Outdoor design and landscaping.',
        icon: 'landscaping',
        displayOrder: 11,
      },
    ],
  },
  {
    slug: 'auto-services',
    name: 'Auto Services',
    description: 'Vehicle repair, detailing, and roadside help.',
    icon: 'auto',
    displayOrder: 20,
    children: [
      {
        slug: 'vehicle-repair',
        name: 'Vehicle Repair',
        description: 'Car and motorcycle mechanical repairs.',
        icon: 'vehicle-repair',
        displayOrder: 1,
      },
      {
        slug: 'auto-detailing',
        name: 'Auto Detailing',
        description: 'Vehicle wash and detailing.',
        icon: 'auto-detailing',
        displayOrder: 2,
      },
      {
        slug: 'roadside-assistance',
        name: 'Roadside Assistance',
        description: 'Breakdown and roadside support.',
        icon: 'roadside',
        displayOrder: 3,
      },
    ],
  },
  {
    slug: 'personal-services',
    name: 'Personal Services',
    description: 'Beauty, fitness, and events.',
    icon: 'personal',
    displayOrder: 30,
    children: [
      {
        slug: 'beauty-services',
        name: 'Beauty Services',
        description: 'Hair, makeup, and grooming.',
        icon: 'beauty',
        displayOrder: 1,
      },
      {
        slug: 'fitness-training',
        name: 'Fitness Training',
        description: 'Personal training and coaching.',
        icon: 'fitness',
        displayOrder: 2,
      },
      {
        slug: 'photography',
        name: 'Photography',
        description: 'Portraits, events, and resorts.',
        icon: 'camera',
        displayOrder: 3,
      },
      {
        slug: 'event-services',
        name: 'Event Services',
        description: 'Event planning and support.',
        icon: 'event',
        displayOrder: 4,
      },
    ],
  },
  {
    slug: 'technology',
    name: 'Technology',
    description: 'Device repair and IT support.',
    icon: 'tech',
    displayOrder: 40,
    children: [
      {
        slug: 'computer-repair',
        name: 'Computer Repair',
        description: 'Laptop and desktop repair.',
        icon: 'pc-repair',
        displayOrder: 1,
      },
      {
        slug: 'phone-repair',
        name: 'Phone Repair',
        description: 'Mobile device repair.',
        icon: 'phone-repair',
        displayOrder: 2,
      },
      {
        slug: 'it-support',
        name: 'IT Support',
        description: 'Business and home IT help.',
        icon: 'it-support',
        displayOrder: 3,
      },
    ],
  },
  {
    slug: 'legacy-services',
    name: 'Legacy Services',
    description: 'Inactive category for filter testing.',
    icon: 'archive',
    displayOrder: 99,
    status: CatalogStatus.INACTIVE,
  },
];

async function upsertCategory(
  ctx: SeedContext,
  seed: CategorySeed,
  parentId: string | null,
) {
  const category = await ctx.prisma.category.upsert({
    where: { slug: seed.slug },
    create: {
      name: seed.name,
      slug: seed.slug,
      description: seed.description,
      icon: seed.icon,
      parentId,
      displayOrder: seed.displayOrder,
      status: seed.status ?? CatalogStatus.ACTIVE,
      metadata: {
        localeHints: { en: seed.name },
        seo: { title: seed.name },
      },
    },
    update: {
      name: seed.name,
      description: seed.description,
      icon: seed.icon,
      parentId,
      displayOrder: seed.displayOrder,
      status: seed.status ?? CatalogStatus.ACTIVE,
      metadata: {
        localeHints: { en: seed.name },
        seo: { title: seed.name },
      },
    },
  });

  for (const child of seed.children ?? []) {
    await upsertCategory(ctx, child, category.id);
  }
}

async function removeRetiredCategories(ctx: SeedContext) {
  for (const slug of REMOVED_CATEGORY_SLUGS) {
    await ctx.prisma.category.deleteMany({ where: { slug } });
  }
}

export async function seedCategories(ctx: SeedContext) {
  for (const root of CATEGORY_TREE) {
    await upsertCategory(ctx, root, null);
  }
  await removeRetiredCategories(ctx);
}
