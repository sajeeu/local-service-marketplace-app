import { Injectable } from '@nestjs/common';
import {
  CatalogStatus,
  Prisma,
  UserRole,
  type Category,
} from '@prisma/client';
import { PinoLogger } from 'nestjs-pino';
import {
  ConflictAppError,
  ForbiddenAppError,
  NotFoundAppError,
  ValidationAppError,
} from '../../common/errors/app.error';
import {
  buildPaginationMeta,
  normalizePagination,
  toPaginatedEnvelope,
  type PaginatedResult,
} from '../../common/pagination';
import { PrismaService } from '../../prisma/prisma.service';
import type { AuthenticatedUser } from '../identity/authorization/authenticated-user';
import {
  CreateCategoryDto,
  ListCategoriesQueryDto,
  UpdateCategoryDto,
  type CategoryResponseDto,
} from './dto/category.dto';
import {
  emptyToNull,
  toCategoryResponse,
  type CategoryJson,
} from './category.mapper';

@Injectable()
export class CategoriesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly logger: PinoLogger,
  ) {
    this.logger.setContext(CategoriesService.name);
  }

  async list(query: ListCategoriesQueryDto, user: AuthenticatedUser | null) {
    const { page, limit, skip } = normalizePagination(query);
    const isAdmin = user?.role === UserRole.ADMINISTRATOR;
    const where: Prisma.CategoryWhereInput = {};

    if (query.status) {
      if (query.status === CatalogStatus.INACTIVE && !isAdmin) {
        throw new ForbiddenAppError('Only administrators can list inactive categories');
      }
      where.status = query.status;
    } else {
      where.status = CatalogStatus.ACTIVE;
    }

    if (query.parentId !== undefined) {
      if (query.parentId === 'null' || query.parentId === '') {
        where.parentId = null;
      } else {
        where.parentId = query.parentId;
      }
    }

    if (query.search?.trim()) {
      const term = query.search.trim();
      where.OR = [
        { name: { contains: term, mode: 'insensitive' } },
        { slug: { contains: term, mode: 'insensitive' } },
      ];
    }

    const orderBy: Prisma.CategoryOrderByWithRelationInput[] =
      query.sort === 'name'
        ? [{ name: 'asc' }]
        : [{ displayOrder: 'asc' }, { name: 'asc' }];

    const [total, rows] = await Promise.all([
      this.prisma.category.count({ where }),
      this.prisma.category.findMany({
        where,
        orderBy,
        skip,
        take: limit,
      }),
    ]);

    const result: PaginatedResult<CategoryResponseDto> = {
      items: rows.map(toCategoryResponse),
      pagination: buildPaginationMeta(page, limit, total),
    };
    return toPaginatedEnvelope(result);
  }

  async getById(
    id: string,
    user: AuthenticatedUser | null,
  ): Promise<CategoryResponseDto> {
    const category = await this.prisma.category.findUnique({ where: { id } });
    if (!category) {
      throw new NotFoundAppError('Category not found');
    }
    const isAdmin = user?.role === UserRole.ADMINISTRATOR;
    if (category.status === CatalogStatus.INACTIVE && !isAdmin) {
      throw new NotFoundAppError('Category not found');
    }
    return toCategoryResponse(category);
  }

  async create(dto: CreateCategoryDto): Promise<CategoryResponseDto> {
    await this.ensureSlugAvailable(dto.slug);
    if (dto.parentId) {
      await this.ensureParentExists(dto.parentId);
    }

    const category = await this.prisma.category.create({
      data: {
        name: dto.name.trim(),
        slug: dto.slug.trim().toLowerCase(),
        description: emptyToNull(dto.description) ?? null,
        icon: emptyToNull(dto.icon) ?? null,
        parentId: dto.parentId ?? null,
        displayOrder: dto.displayOrder ?? 0,
        status: dto.status ?? CatalogStatus.ACTIVE,
        metadata: (dto.metadata ?? {}) as CategoryJson,
      },
    });

    this.logger.info({
      event: 'category.created',
      categoryId: category.id,
      slug: category.slug,
    });

    return toCategoryResponse(category);
  }

  async update(id: string, dto: UpdateCategoryDto): Promise<CategoryResponseDto> {
    const existing = await this.findOrThrow(id);

    if (dto.slug !== undefined && dto.slug !== existing.slug) {
      await this.ensureSlugAvailable(dto.slug, id);
    }

    if (dto.parentId !== undefined) {
      if (dto.parentId === null) {
        // root ok
      } else if (dto.parentId === id) {
        throw new ValidationAppError('Category cannot be its own parent');
      } else {
        await this.ensureParentExists(dto.parentId);
        await this.ensureNoCycle(id, dto.parentId);
      }
    }

    const data: Prisma.CategoryUpdateInput = {};
    if (dto.name !== undefined) {
      data.name = dto.name.trim();
    }
    if (dto.slug !== undefined) {
      data.slug = dto.slug.trim().toLowerCase();
    }
    if (dto.description !== undefined) {
      data.description = emptyToNull(dto.description) ?? null;
    }
    if (dto.icon !== undefined) {
      data.icon = emptyToNull(dto.icon) ?? null;
    }
    if (dto.parentId !== undefined) {
      data.parent =
        dto.parentId === null
          ? { disconnect: true }
          : { connect: { id: dto.parentId } };
    }
    if (dto.displayOrder !== undefined) {
      data.displayOrder = dto.displayOrder;
    }
    if (dto.status !== undefined) {
      data.status = dto.status;
    }
    if (dto.metadata !== undefined) {
      data.metadata = dto.metadata as CategoryJson;
    }

    const category = await this.prisma.category.update({
      where: { id },
      data,
    });

    this.logger.info({
      event: 'category.updated',
      categoryId: category.id,
    });

    return toCategoryResponse(category);
  }

  async remove(id: string): Promise<CategoryResponseDto> {
    const existing = await this.findOrThrow(id);
    const childCount = await this.prisma.category.count({
      where: { parentId: id },
    });
    if (childCount > 0) {
      throw new ConflictAppError(
        'Cannot delete category with child categories; deactivate or reassign children first',
      );
    }

    if (existing.status === CatalogStatus.INACTIVE) {
      await this.prisma.category.delete({ where: { id } });
      this.logger.info({
        event: 'category.deleted',
        categoryId: id,
      });
      return toCategoryResponse(existing);
    }

    const category = await this.prisma.category.update({
      where: { id },
      data: { status: CatalogStatus.INACTIVE },
    });

    this.logger.info({
      event: 'category.deactivated',
      categoryId: category.id,
    });

    return toCategoryResponse(category);
  }

  private async findOrThrow(id: string): Promise<Category> {
    const category = await this.prisma.category.findUnique({ where: { id } });
    if (!category) {
      throw new NotFoundAppError('Category not found');
    }
    return category;
  }

  private async ensureSlugAvailable(slug: string, excludeId?: string) {
    const normalized = slug.trim().toLowerCase();
    const existing = await this.prisma.category.findUnique({
      where: { slug: normalized },
    });
    if (existing && existing.id !== excludeId) {
      throw new ConflictAppError('Category slug already exists');
    }
  }

  private async ensureParentExists(parentId: string) {
    const parent = await this.prisma.category.findUnique({
      where: { id: parentId },
    });
    if (!parent) {
      throw new ValidationAppError('Parent category not found');
    }
  }

  private async ensureNoCycle(categoryId: string, newParentId: string) {
    let currentId: string | null = newParentId;
    const visited = new Set<string>();
    while (currentId) {
      if (currentId === categoryId) {
        throw new ValidationAppError(
          'Cannot set parent: would create a circular hierarchy',
        );
      }
      if (visited.has(currentId)) {
        break;
      }
      visited.add(currentId);
      const parent: { parentId: string | null } | null =
        await this.prisma.category.findUnique({
          where: { id: currentId },
          select: { parentId: true },
        });
      currentId = parent?.parentId ?? null;
    }
  }
}
