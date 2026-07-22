import { CustomerProfile, Prisma, ProfileStatus } from '@prisma/client';

export type ProfileCompletion = {
  status: 'INCOMPLETE' | 'COMPLETE';
  percent: number;
};

export type OwnerCustomerProfile = {
  id: string;
  userId: string;
  displayName: string;
  avatarUrl: string | null;
  contactEmail: string | null;
  contactPhone: string | null;
  preferences: Prisma.JsonValue;
  savedSettings: Prisma.JsonValue;
  status: ProfileStatus;
  completion: ProfileCompletion;
  createdAt: string;
  updatedAt: string;
};

const COMPLETION_FIELDS = ['displayName', 'contact', 'avatarUrl'] as const;

export function computeCustomerCompletion(
  profile: Pick<
    CustomerProfile,
    'displayName' | 'contactEmail' | 'contactPhone' | 'avatarUrl'
  >,
): ProfileCompletion {
  const checks = {
    displayName: Boolean(profile.displayName?.trim()),
    contact: Boolean(
      profile.contactEmail?.trim() || profile.contactPhone?.trim(),
    ),
    avatarUrl: Boolean(profile.avatarUrl?.trim()),
  };

  const filled = COMPLETION_FIELDS.filter((key) => checks[key]).length;
  const percent = Math.round((filled / COMPLETION_FIELDS.length) * 100);
  const status =
    checks.displayName && checks.contact ? 'COMPLETE' : 'INCOMPLETE';

  return { status, percent };
}

export function toOwnerCustomerProfile(
  profile: CustomerProfile,
): OwnerCustomerProfile {
  return {
    id: profile.id,
    userId: profile.userId,
    displayName: profile.displayName,
    avatarUrl: profile.avatarUrl,
    contactEmail: profile.contactEmail,
    contactPhone: profile.contactPhone,
    preferences: profile.preferences,
    savedSettings: profile.savedSettings,
    status: profile.status,
    completion: computeCustomerCompletion(profile),
    createdAt: profile.createdAt.toISOString(),
    updatedAt: profile.updatedAt.toISOString(),
  };
}
