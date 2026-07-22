import type { Atoll, Island } from '@prisma/client';
import type { AtollResponseDto, IslandResponseDto } from './dto/geography.dto';

export function toAtollResponse(atoll: Atoll): AtollResponseDto {
  return {
    id: atoll.id,
    name: atoll.name,
    code: atoll.code,
    description: atoll.description,
    displayOrder: atoll.displayOrder,
    status: atoll.status,
    createdAt: atoll.createdAt.toISOString(),
    updatedAt: atoll.updatedAt.toISOString(),
  };
}

export function toIslandResponse(
  island: Island & { atoll?: Atoll },
  includeAtoll = false,
): IslandResponseDto {
  return {
    id: island.id,
    atollId: island.atollId,
    name: island.name,
    slug: island.slug,
    type: island.type,
    displayOrder: island.displayOrder,
    status: island.status,
    ...(includeAtoll && island.atoll
      ? { atoll: toAtollResponse(island.atoll) }
      : {}),
    createdAt: island.createdAt.toISOString(),
    updatedAt: island.updatedAt.toISOString(),
  };
}
