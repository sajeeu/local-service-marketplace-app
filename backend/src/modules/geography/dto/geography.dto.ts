import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { CatalogStatus, IslandType } from '@prisma/client';
import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';
import { PaginationQueryDto } from '../../../common/pagination';

export class ListAtollsQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({ enum: CatalogStatus })
  @IsOptional()
  @IsEnum(CatalogStatus)
  status?: CatalogStatus;

  @ApiPropertyOptional({ description: 'Search by name or code' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  search?: string;

  @ApiPropertyOptional({
    enum: ['displayOrder', 'name', 'code'],
    default: 'displayOrder',
  })
  @IsOptional()
  @IsString()
  sort?: 'displayOrder' | 'name' | 'code' = 'displayOrder';
}

export class ListIslandsQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  atollId?: string;

  @ApiPropertyOptional({ enum: CatalogStatus })
  @IsOptional()
  @IsEnum(CatalogStatus)
  status?: CatalogStatus;

  @ApiPropertyOptional({ enum: IslandType })
  @IsOptional()
  @IsEnum(IslandType)
  type?: IslandType;

  @ApiPropertyOptional({ description: 'Search by name or slug' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  search?: string;

  @ApiPropertyOptional({
    enum: ['displayOrder', 'name'],
    default: 'displayOrder',
  })
  @IsOptional()
  @IsString()
  sort?: 'displayOrder' | 'name' = 'displayOrder';
}

export class ListIslandsByAtollQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({ enum: CatalogStatus })
  @IsOptional()
  @IsEnum(CatalogStatus)
  status?: CatalogStatus;

  @ApiPropertyOptional({ enum: IslandType })
  @IsOptional()
  @IsEnum(IslandType)
  type?: IslandType;
}

export class AtollResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  name!: string;

  @ApiProperty()
  code!: string;

  @ApiPropertyOptional({ nullable: true })
  description!: string | null;

  @ApiProperty()
  displayOrder!: number;

  @ApiProperty({ enum: CatalogStatus })
  status!: CatalogStatus;

  @ApiProperty()
  createdAt!: string;

  @ApiProperty()
  updatedAt!: string;
}

export class IslandResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  atollId!: string;

  @ApiProperty()
  name!: string;

  @ApiProperty()
  slug!: string;

  @ApiProperty({ enum: IslandType })
  type!: IslandType;

  @ApiProperty()
  displayOrder!: number;

  @ApiProperty({ enum: CatalogStatus })
  status!: CatalogStatus;

  @ApiPropertyOptional({ type: () => AtollResponseDto })
  atoll?: AtollResponseDto;

  @ApiProperty()
  createdAt!: string;

  @ApiProperty()
  updatedAt!: string;
}
