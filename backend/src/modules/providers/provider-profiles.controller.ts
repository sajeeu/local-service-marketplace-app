import { Body, Controller, Get, Param, Patch, Post } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import type { AuthenticatedUser } from '../identity/authorization/authenticated-user';
import { CurrentUser } from '../identity/authorization/current-user.decorator';
import { Public } from '../identity/authorization/public.decorator';
import {
  CreateProviderProfileDto,
  UpdateProviderProfileDto,
} from './dto/provider-profile.dto';
import { ProviderProfilesService } from './provider-profiles.service';

@ApiTags('provider-profiles')
@Controller({ path: 'provider-profiles', version: '1' })
export class ProviderProfilesController {
  constructor(
    private readonly providerProfilesService: ProviderProfilesService,
  ) {}

  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create the authenticated user provider profile' })
  @Post()
  create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateProviderProfileDto,
  ) {
    return this.providerProfilesService.create(user.id, dto);
  }

  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get the authenticated user provider profile' })
  @Get('me')
  getMe(@CurrentUser() user: AuthenticatedUser) {
    return this.providerProfilesService.getOwn(user.id);
  }

  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update the authenticated user provider profile' })
  @Patch('me')
  updateMe(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateProviderProfileDto,
  ) {
    return this.providerProfilesService.updateOwn(user.id, dto);
  }

  @ApiBearerAuth()
  @ApiOperation({ summary: 'Deactivate the authenticated user provider profile' })
  @Post('me/deactivate')
  deactivate(@CurrentUser() user: AuthenticatedUser) {
    return this.providerProfilesService.deactivateOwn(user.id);
  }

  @ApiBearerAuth()
  @ApiOperation({ summary: 'Restore the authenticated user provider profile' })
  @Post('me/restore')
  restore(@CurrentUser() user: AuthenticatedUser) {
    return this.providerProfilesService.restoreOwn(user.id);
  }

  @Public()
  @ApiOperation({
    summary: 'Get a public provider profile by id (ACTIVE + PUBLIC only)',
  })
  @Get(':id')
  getPublic(@Param('id') id: string) {
    return this.providerProfilesService.getPublic(id);
  }
}
