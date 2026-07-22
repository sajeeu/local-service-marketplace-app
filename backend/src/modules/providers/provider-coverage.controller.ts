import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  Post,
  Put,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import type { AuthenticatedUser } from '../identity/authorization/authenticated-user';
import { CurrentUser } from '../identity/authorization/current-user.decorator';
import { IslandIdsDto } from './dto/provider-coverage.dto';
import { ProviderCoverageService } from './provider-coverage.service';

@ApiTags('provider-coverage')
@ApiBearerAuth()
@Controller({ path: 'provider-profiles/me/coverage', version: '1' })
export class ProviderCoverageController {
  constructor(
    private readonly providerCoverageService: ProviderCoverageService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'Get own provider service coverage' })
  getOwn(@CurrentUser() user: AuthenticatedUser) {
    return this.providerCoverageService.getOwn(user.id);
  }

  @Put()
  @ApiOperation({ summary: 'Replace own provider service coverage' })
  replaceOwn(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: IslandIdsDto,
  ) {
    return this.providerCoverageService.replaceOwn(user.id, dto.islandIds);
  }

  @Post('islands')
  @ApiOperation({ summary: 'Add islands to own coverage' })
  addIslands(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: IslandIdsDto,
  ) {
    return this.providerCoverageService.addIslands(user.id, dto.islandIds);
  }

  @Delete('islands')
  @HttpCode(200)
  @ApiOperation({ summary: 'Remove islands from own coverage' })
  removeIslands(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: IslandIdsDto,
  ) {
    return this.providerCoverageService.removeIslands(user.id, dto.islandIds);
  }

  @Post('atolls/:atollId')
  @ApiOperation({
    summary: 'Add all active islands in an atoll to own coverage',
  })
  addAtoll(
    @CurrentUser() user: AuthenticatedUser,
    @Param('atollId') atollId: string,
  ) {
    return this.providerCoverageService.addAtollIslands(user.id, atollId);
  }
}
