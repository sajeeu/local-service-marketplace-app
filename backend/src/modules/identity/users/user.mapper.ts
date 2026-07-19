import { User } from '@prisma/client';

export type PublicUser = {
  id: string;
  email: string;
  displayName: string | null;
  role: User['role'];
  status: User['status'];
  createdAt: string;
  updatedAt: string;
};

export function toPublicUser(user: User): PublicUser {
  return {
    id: user.id,
    email: user.email,
    displayName: user.displayName,
    role: user.role,
    status: user.status,
    createdAt: user.createdAt.toISOString(),
    updatedAt: user.updatedAt.toISOString(),
  };
}
