-- Phase 3: Categories, Maldives Geography (Atoll/Island), Provider Island Coverage

CREATE TYPE "CatalogStatus" AS ENUM ('ACTIVE', 'INACTIVE');

CREATE TYPE "IslandType" AS ENUM ('CAPITAL', 'CITY', 'INHABITED', 'RESORT', 'AIRPORT', 'INDUSTRIAL', 'OTHER');

CREATE TABLE "Category" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "description" TEXT,
    "icon" TEXT,
    "parentId" TEXT,
    "displayOrder" INTEGER NOT NULL DEFAULT 0,
    "status" "CatalogStatus" NOT NULL DEFAULT 'ACTIVE',
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Category_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Atoll" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT,
    "displayOrder" INTEGER NOT NULL DEFAULT 0,
    "status" "CatalogStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Atoll_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Island" (
    "id" TEXT NOT NULL,
    "atollId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "type" "IslandType" NOT NULL DEFAULT 'INHABITED',
    "displayOrder" INTEGER NOT NULL DEFAULT 0,
    "status" "CatalogStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Island_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "ProviderIslandCoverage" (
    "id" TEXT NOT NULL,
    "providerProfileId" TEXT NOT NULL,
    "islandId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ProviderIslandCoverage_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "Category_slug_key" ON "Category"("slug");

CREATE INDEX "Category_parentId_idx" ON "Category"("parentId");

CREATE INDEX "Category_status_displayOrder_idx" ON "Category"("status", "displayOrder");

CREATE UNIQUE INDEX "Atoll_code_key" ON "Atoll"("code");

CREATE INDEX "Atoll_status_displayOrder_idx" ON "Atoll"("status", "displayOrder");

CREATE UNIQUE INDEX "Island_slug_key" ON "Island"("slug");

CREATE INDEX "Island_atollId_idx" ON "Island"("atollId");

CREATE INDEX "Island_status_displayOrder_idx" ON "Island"("status", "displayOrder");

CREATE UNIQUE INDEX "Island_atollId_name_key" ON "Island"("atollId", "name");

CREATE INDEX "ProviderIslandCoverage_providerProfileId_idx" ON "ProviderIslandCoverage"("providerProfileId");

CREATE INDEX "ProviderIslandCoverage_islandId_idx" ON "ProviderIslandCoverage"("islandId");

CREATE UNIQUE INDEX "ProviderIslandCoverage_providerProfileId_islandId_key" ON "ProviderIslandCoverage"("providerProfileId", "islandId");

ALTER TABLE "Category" ADD CONSTRAINT "Category_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "Category"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "Island" ADD CONSTRAINT "Island_atollId_fkey" FOREIGN KEY ("atollId") REFERENCES "Atoll"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "ProviderIslandCoverage" ADD CONSTRAINT "ProviderIslandCoverage_providerProfileId_fkey" FOREIGN KEY ("providerProfileId") REFERENCES "ProviderProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "ProviderIslandCoverage" ADD CONSTRAINT "ProviderIslandCoverage_islandId_fkey" FOREIGN KEY ("islandId") REFERENCES "Island"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
