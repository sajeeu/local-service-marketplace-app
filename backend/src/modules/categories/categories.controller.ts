import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import type { AuthenticatedUser } from '../identity/authorization/authenticated-user';
import { CurrentUser } from '../identity/authorization/current-user.decorator';
import { Public } from '../identity/authorization/public.decorator';
import { Roles } from '../identity/authorization/roles.decorator';
import { CategoriesService } from './categories.service';
import {
  CreateCategoryDto,
  ListCategoriesQueryDto,
  UpdateCategoryDto,
} from './dto/category.dto';

@ApiTags('categories')
@Controller({ path: 'categories', version: '1' })
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Public()
  @Get()
  @ApiOperation({ summary: 'List service categories' })
  @ApiBearerAuth()
  list(
    @Query() query: ListCategoriesQueryDto,
    @CurrentUser() user: AuthenticatedUser | null,
  ) {
    return this.categoriesService.list(query, user ?? null);
  }

  @Public()
  @Get(':id')
  @ApiOperation({ summary: 'Get a category by id' })
  @ApiBearerAuth()
  getById(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser | null,
  ) {
    return this.categoriesService.getById(id, user ?? null);
  }

  @ApiBearerAuth()
  @Roles(UserRole.ADMINISTRATOR)
  @Post()
  @ApiOperation({ summary: 'Create a category (admin)' })
  create(@Body() dto: CreateCategoryDto) {
    return this.categoriesService.create(dto);
  }

  @ApiBearerAuth()
  @Roles(UserRole.ADMINISTRATOR)
  @Patch(':id')
  @ApiOperation({ summary: 'Update a category (admin)' })
  update(@Param('id') id: string, @Body() dto: UpdateCategoryDto) {
    return this.categoriesService.update(id, dto);
  }

  @ApiBearerAuth()
  @Roles(UserRole.ADMINISTRATOR)
  @Delete(':id')
  @ApiOperation({
    summary:
      'Deactivate a category, or hard-delete if already inactive and unused (admin)',
  })
  remove(@Param('id') id: string) {
    return this.categoriesService.remove(id);
  }
}
