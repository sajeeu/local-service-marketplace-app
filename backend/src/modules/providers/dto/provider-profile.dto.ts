import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ProfileVisibility } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsEmail,
  IsEnum,
  IsObject,
  IsOptional,
  IsString,
  IsUrl,
  MaxLength,
  MinLength,
} from 'class-validator';

export class CreateProviderProfileDto {
  @ApiProperty({ example: 'Acme Plumbing' })
  @IsString()
  @MinLength(1)
  @MaxLength(100)
  displayName!: string;

  @ApiPropertyOptional({ example: 'Acme Plumbing LLC' })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  businessName?: string;

  @ApiPropertyOptional({ example: 'Licensed local plumbing services.' })
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  description?: string;

  @ApiPropertyOptional({ example: 'business@acme.example' })
  @IsOptional()
  @IsEmail()
  @MaxLength(255)
  contactEmail?: string;

  @ApiPropertyOptional({ example: '+15551234567' })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  contactPhone?: string;

  @ApiPropertyOptional({ example: 'https://acme.example' })
  @IsOptional()
  @IsUrl({ require_protocol: true })
  @MaxLength(500)
  websiteUrl?: string;

  @ApiPropertyOptional({ example: 'https://cdn.example/logo.png' })
  @IsOptional()
  @IsUrl({ require_protocol: true })
  @MaxLength(500)
  logoUrl?: string;

  @ApiPropertyOptional({ example: 'https://cdn.example/cover.png' })
  @IsOptional()
  @IsUrl({ require_protocol: true })
  @MaxLength(500)
  coverImageUrl?: string;

  @ApiPropertyOptional({ type: [String], example: ['en', 'es'] })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(20)
  @IsString({ each: true })
  @MaxLength(30, { each: true })
  languages?: string[];

  @ApiPropertyOptional({ type: 'object', additionalProperties: true })
  @IsOptional()
  @IsObject()
  businessSettings?: Record<string, unknown>;

  @ApiPropertyOptional({ enum: ProfileVisibility, default: ProfileVisibility.PRIVATE })
  @IsOptional()
  @IsEnum(ProfileVisibility)
  visibility?: ProfileVisibility;
}

export class UpdateProviderProfileDto {
  @ApiPropertyOptional({ example: 'Acme Plumbing' })
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(100)
  displayName?: string;

  @ApiPropertyOptional({ example: 'Acme Plumbing LLC', nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  businessName?: string | null;

  @ApiPropertyOptional({ nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  description?: string | null;

  @ApiPropertyOptional({ nullable: true })
  @IsOptional()
  @IsEmail()
  @MaxLength(255)
  contactEmail?: string | null;

  @ApiPropertyOptional({ nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  contactPhone?: string | null;

  @ApiPropertyOptional({ nullable: true })
  @IsOptional()
  @IsUrl({ require_protocol: true })
  @MaxLength(500)
  websiteUrl?: string | null;

  @ApiPropertyOptional({ nullable: true })
  @IsOptional()
  @IsUrl({ require_protocol: true })
  @MaxLength(500)
  logoUrl?: string | null;

  @ApiPropertyOptional({ nullable: true })
  @IsOptional()
  @IsUrl({ require_protocol: true })
  @MaxLength(500)
  coverImageUrl?: string | null;

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(20)
  @IsString({ each: true })
  @MaxLength(30, { each: true })
  @Type(() => String)
  languages?: string[];

  @ApiPropertyOptional({ type: 'object', additionalProperties: true })
  @IsOptional()
  @IsObject()
  businessSettings?: Record<string, unknown>;

  @ApiPropertyOptional({ enum: ProfileVisibility })
  @IsOptional()
  @IsEnum(ProfileVisibility)
  visibility?: ProfileVisibility;
}
