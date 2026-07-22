import { CatalogStatus, IslandType, type SeedContext } from './constants';

type IslandSeed = {
  slug: string;
  name: string;
  type: IslandType;
  displayOrder: number;
  status?: CatalogStatus;
};

type AtollSeed = {
  code: string;
  name: string;
  description: string;
  displayOrder: number;
  status?: CatalogStatus;
  islands: IslandSeed[];
};

const ATOLLS: AtollSeed[] = [
  {
    code: 'K',
    name: 'Kaafu Atoll',
    description: 'Includes Malé, Hulhumalé, and nearby inhabited islands.',
    displayOrder: 10,
    islands: [
      {
        slug: 'male',
        name: 'Malé',
        type: IslandType.CAPITAL,
        displayOrder: 1,
      },
      {
        slug: 'hulhumale',
        name: 'Hulhumalé',
        type: IslandType.CITY,
        displayOrder: 2,
      },
      {
        slug: 'villingili-kaafu',
        name: 'Villingili',
        type: IslandType.INHABITED,
        displayOrder: 3,
      },
      {
        slug: 'maafushi',
        name: 'Maafushi',
        type: IslandType.INHABITED,
        displayOrder: 4,
      },
      {
        slug: 'thulusdhoo',
        name: 'Thulusdhoo',
        type: IslandType.INHABITED,
        displayOrder: 5,
      },
      {
        slug: 'guraidhoo-kaafu',
        name: 'Guraidhoo',
        type: IslandType.INHABITED,
        displayOrder: 6,
      },
      {
        slug: 'himmafushi',
        name: 'Himmafushi',
        type: IslandType.INHABITED,
        displayOrder: 7,
      },
      {
        slug: 'hulhule',
        name: 'Hulhulé',
        type: IslandType.AIRPORT,
        displayOrder: 8,
      },
      {
        slug: 'seed-inactive-island',
        name: 'Inactive Demo Island',
        type: IslandType.OTHER,
        displayOrder: 99,
        status: CatalogStatus.INACTIVE,
      },
    ],
  },
  {
    code: 'AA',
    name: 'Alifu Alifu Atoll',
    description: 'North Ari Atoll inhabited and resort islands.',
    displayOrder: 20,
    islands: [
      {
        slug: 'rasdhoo',
        name: 'Rasdhoo',
        type: IslandType.INHABITED,
        displayOrder: 1,
      },
      {
        slug: 'bodufolhudhoo',
        name: 'Bodufolhudhoo',
        type: IslandType.INHABITED,
        displayOrder: 2,
      },
      {
        slug: 'mathiveri',
        name: 'Mathiveri',
        type: IslandType.INHABITED,
        displayOrder: 3,
      },
    ],
  },
  {
    code: 'ADh',
    name: 'Alifu Dhaalu Atoll',
    description: 'South Ari Atoll.',
    displayOrder: 30,
    islands: [
      {
        slug: 'maamigili',
        name: 'Maamigili',
        type: IslandType.INHABITED,
        displayOrder: 1,
      },
      {
        slug: 'mahibadhoo',
        name: 'Mahibadhoo',
        type: IslandType.INHABITED,
        displayOrder: 2,
      },
      {
        slug: 'dhangethi',
        name: 'Dhangethi',
        type: IslandType.INHABITED,
        displayOrder: 3,
      },
    ],
  },
  {
    code: 'L',
    name: 'Laamu Atoll',
    description: 'Southern atoll with several inhabited islands.',
    displayOrder: 40,
    islands: [
      {
        slug: 'fonadhoo',
        name: 'Fonadhoo',
        type: IslandType.INHABITED,
        displayOrder: 1,
      },
      {
        slug: 'gan-laamu',
        name: 'Gan',
        type: IslandType.INHABITED,
        displayOrder: 2,
      },
      {
        slug: 'isdhoo',
        name: 'Isdhoo',
        type: IslandType.INHABITED,
        displayOrder: 3,
      },
    ],
  },
  {
    code: 'S',
    name: 'Addu City',
    description: 'Addu Atoll / Addu City administrative area.',
    displayOrder: 50,
    islands: [
      {
        slug: 'hithadhoo',
        name: 'Hithadhoo',
        type: IslandType.CITY,
        displayOrder: 1,
      },
      {
        slug: 'maradhoo',
        name: 'Maradhoo',
        type: IslandType.INHABITED,
        displayOrder: 2,
      },
      {
        slug: 'feydhoo-addu',
        name: 'Feydhoo',
        type: IslandType.INHABITED,
        displayOrder: 3,
      },
      {
        slug: 'hulhudhoo',
        name: 'Hulhudhoo',
        type: IslandType.INHABITED,
        displayOrder: 4,
      },
      {
        slug: 'meedhoo-addu',
        name: 'Meedhoo',
        type: IslandType.INHABITED,
        displayOrder: 5,
      },
    ],
  },
  {
    code: 'B',
    name: 'Baa Atoll',
    description: 'UNESCO biosphere reserve atoll.',
    displayOrder: 60,
    islands: [
      {
        slug: 'eydhafushi',
        name: 'Eydhafushi',
        type: IslandType.INHABITED,
        displayOrder: 1,
      },
      {
        slug: 'thulhaadhoo',
        name: 'Thulhaadhoo',
        type: IslandType.INHABITED,
        displayOrder: 2,
      },
      {
        slug: 'dharavandhoo',
        name: 'Dharavandhoo',
        type: IslandType.AIRPORT,
        displayOrder: 3,
      },
    ],
  },
  {
    code: 'HDh',
    name: 'Haa Dhaalu Atoll',
    description: 'Northern atoll.',
    displayOrder: 70,
    islands: [
      {
        slug: 'kulhudhuffushi',
        name: 'Kulhudhuffushi',
        type: IslandType.CITY,
        displayOrder: 1,
      },
      {
        slug: 'nolhivaranfaru',
        name: 'Nolhivaranfaru',
        type: IslandType.INHABITED,
        displayOrder: 2,
      },
    ],
  },
];

export async function seedGeography(ctx: SeedContext) {
  const { prisma } = ctx;

  for (const atollSeed of ATOLLS) {
    const atoll = await prisma.atoll.upsert({
      where: { code: atollSeed.code },
      create: {
        name: atollSeed.name,
        code: atollSeed.code,
        description: atollSeed.description,
        displayOrder: atollSeed.displayOrder,
        status: atollSeed.status ?? CatalogStatus.ACTIVE,
      },
      update: {
        name: atollSeed.name,
        description: atollSeed.description,
        displayOrder: atollSeed.displayOrder,
        status: atollSeed.status ?? CatalogStatus.ACTIVE,
      },
    });

    for (const islandSeed of atollSeed.islands) {
      await prisma.island.upsert({
        where: { slug: islandSeed.slug },
        create: {
          atollId: atoll.id,
          name: islandSeed.name,
          slug: islandSeed.slug,
          type: islandSeed.type,
          displayOrder: islandSeed.displayOrder,
          status: islandSeed.status ?? CatalogStatus.ACTIVE,
        },
        update: {
          atollId: atoll.id,
          name: islandSeed.name,
          type: islandSeed.type,
          displayOrder: islandSeed.displayOrder,
          status: islandSeed.status ?? CatalogStatus.ACTIVE,
        },
      });
    }
  }
}
