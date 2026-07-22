import type { Category, Prisma } from '@prisma/client';
import type { CategoryResponseDto } from './dto/category.dto';

export function toCategoryResponse(category: Category): CategoryResponseDto {
  return {
    id: category.id,
    name: category.name,
    slug: category.slug,
    description: category.description,
    icon: category.icon,
    parentId: category.parentId,
    displayOrder: category.displayOrder,
    status: category.status,
    metadata: (category.metadata ?? {}) as Record<string, unknown>,
    createdAt: category.createdAt.toISOString(),
    updatedAt: category.updatedAt.toISOString(),
  };
}

export function emptyToNull(
  value: string | null | undefined,
): string | null | undefined {
  if (value === undefined) {
    return undefined;
  }
  if (value === null) {
    return null;
  }
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

export type CategoryJson = Prisma.InputJsonValue;
