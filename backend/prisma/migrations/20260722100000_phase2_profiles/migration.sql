-- Phase 2 Profiles: ProviderProfile + CustomerProfile

CREATE TYPE "ProfileStatus" AS ENUM ('ACTIVE', 'DEACTIVATED');

CREATE TYPE "ProfileVisibility" AS ENUM ('PUBLIC', 'PRIVATE');

CREATE TABLE "ProviderProfile" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "displayName" TEXT NOT NULL,
    "businessName" TEXT,
    "description" TEXT,
    "contactEmail" TEXT,
    "contactPhone" TEXT,
    "websiteUrl" TEXT,
    "logoUrl" TEXT,
    "coverImageUrl" TEXT,
    "languages" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "businessSettings" JSONB NOT NULL DEFAULT '{}',
    "visibility" "ProfileVisibility" NOT NULL DEFAULT 'PRIVATE',
    "status" "ProfileStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ProviderProfile_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "CustomerProfile" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "displayName" TEXT NOT NULL,
    "avatarUrl" TEXT,
    "contactEmail" TEXT,
    "contactPhone" TEXT,
    "preferences" JSONB NOT NULL DEFAULT '{}',
    "savedSettings" JSONB NOT NULL DEFAULT '{}',
    "status" "ProfileStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CustomerProfile_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "ProviderProfile_userId_key" ON "ProviderProfile"("userId");

CREATE INDEX "ProviderProfile_status_visibility_idx" ON "ProviderProfile"("status", "visibility");

CREATE UNIQUE INDEX "CustomerProfile_userId_key" ON "CustomerProfile"("userId");

CREATE INDEX "CustomerProfile_status_idx" ON "CustomerProfile"("status");

ALTER TABLE "ProviderProfile" ADD CONSTRAINT "ProviderProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "CustomerProfile" ADD CONSTRAINT "CustomerProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
