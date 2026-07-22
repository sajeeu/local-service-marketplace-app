import {
  ProfileStatus,
  ProfileVisibility,
  ProviderProfile,
  Prisma,
} from '@prisma/client';

export type ProfileCompletion = {
  status: 'INCOMPLETE' | 'COMPLETE';
  percent: number;
};

export type OwnerProviderProfile = {
  id: string;
  userId: string;
  displayName: string;
  businessName: string | null;
  description: string | null;
  contactEmail: string | null;
  contactPhone: string | null;
  websiteUrl: string | null;
  logoUrl: string | null;
  coverImageUrl: string | null;
  languages: string[];
  businessSettings: Prisma.JsonValue;
  visibility: ProfileVisibility;
  status: ProfileStatus;
  completion: ProfileCompletion;
  createdAt: string;
  updatedAt: string;
};

export type PublicProviderProfile = {
  id: string;
  displayName: string;
  businessName: string | null;
  description: string | null;
  websiteUrl: string | null;
  logoUrl: string | null;
  coverImageUrl: string | null;
  languages: string[];
};

const COMPLETION_FIELDS = [
  'displayName',
  'businessInfo',
  'contact',
  'logoUrl',
] as const;

export function computeProviderCompletion(
  profile: Pick<
    ProviderProfile,
    | 'displayName'
    | 'businessName'
    | 'description'
    | 'contactEmail'
    | 'contactPhone'
    | 'websiteUrl'
    | 'logoUrl'
  >,
): ProfileCompletion {
  const checks = {
    displayName: Boolean(profile.displayName?.trim()),
    businessInfo: Boolean(
      profile.businessName?.trim() || profile.description?.trim(),
    ),
    contact: Boolean(
      profile.contactEmail?.trim() ||
        profile.contactPhone?.trim() ||
        profile.websiteUrl?.trim(),
    ),
    logoUrl: Boolean(profile.logoUrl?.trim()),
  };

  const filled = COMPLETION_FIELDS.filter((key) => checks[key]).length;
  const percent = Math.round((filled / COMPLETION_FIELDS.length) * 100);
  // Complete when display name, business info, and contact are present (logo optional for "complete").
  const status =
    checks.displayName && checks.businessInfo && checks.contact
      ? 'COMPLETE'
      : 'INCOMPLETE';

  return { status, percent };
}

export function toOwnerProviderProfile(
  profile: ProviderProfile,
): OwnerProviderProfile {
  return {
    id: profile.id,
    userId: profile.userId,
    displayName: profile.displayName,
    businessName: profile.businessName,
    description: profile.description,
    contactEmail: profile.contactEmail,
    contactPhone: profile.contactPhone,
    websiteUrl: profile.websiteUrl,
    logoUrl: profile.logoUrl,
    coverImageUrl: profile.coverImageUrl,
    languages: profile.languages,
    businessSettings: profile.businessSettings,
    visibility: profile.visibility,
    status: profile.status,
    completion: computeProviderCompletion(profile),
    createdAt: profile.createdAt.toISOString(),
    updatedAt: profile.updatedAt.toISOString(),
  };
}

export function toPublicProviderProfile(
  profile: ProviderProfile,
): PublicProviderProfile {
  return {
    id: profile.id,
    displayName: profile.displayName,
    businessName: profile.businessName,
    description: profile.description,
    websiteUrl: profile.websiteUrl,
    logoUrl: profile.logoUrl,
    coverImageUrl: profile.coverImageUrl,
    languages: profile.languages,
  };
}
