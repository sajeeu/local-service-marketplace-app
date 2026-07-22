import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ArrayMaxSize, ArrayUnique, IsArray, IsString } from 'class-validator';

export class IslandIdsDto {
  @ApiProperty({ type: [String], example: ['clxisland1', 'clxisland2'] })
  @IsArray()
  @ArrayMaxSize(500)
  @ArrayUnique()
  @IsString({ each: true })
  islandIds!: string[];
}

export class CoverageAtollSummaryDto {
  @ApiProperty()
  atollId!: string;

  @ApiProperty()
  atollName!: string;

  @ApiProperty()
  atollCode!: string;

  @ApiProperty()
  islandCount!: number;
}

export class CoverageIslandDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  atollId!: string;

  @ApiProperty()
  name!: string;

  @ApiProperty()
  slug!: string;

  @ApiProperty()
  type!: string;

  @ApiProperty()
  displayOrder!: number;

  @ApiProperty()
  status!: string;

  @ApiPropertyOptional()
  atollName?: string;

  @ApiPropertyOptional()
  atollCode?: string;
}

export class ProviderCoverageResponseDto {
  @ApiProperty()
  providerProfileId!: string;

  @ApiProperty({ type: [CoverageIslandDto] })
  islands!: CoverageIslandDto[];

  @ApiProperty({ type: [CoverageAtollSummaryDto] })
  atollSummaries!: CoverageAtollSummaryDto[];
}
