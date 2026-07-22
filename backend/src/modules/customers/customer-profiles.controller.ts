import { Body, Controller, Get, Patch, Post } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import type { AuthenticatedUser } from '../identity/authorization/authenticated-user';
import { CurrentUser } from '../identity/authorization/current-user.decorator';
import {
  CreateCustomerProfileDto,
  UpdateCustomerProfileDto,
} from './dto/customer-profile.dto';
import { CustomerProfilesService } from './customer-profiles.service';

@ApiTags('customer-profiles')
@ApiBearerAuth()
@Controller({ path: 'customer-profiles', version: '1' })
export class CustomerProfilesController {
  constructor(
    private readonly customerProfilesService: CustomerProfilesService,
  ) {}

  @ApiOperation({ summary: 'Create the authenticated user customer profile' })
  @Post()
  create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateCustomerProfileDto,
  ) {
    return this.customerProfilesService.create(user.id, dto);
  }

  @ApiOperation({ summary: 'Get the authenticated user customer profile' })
  @Get('me')
  getMe(@CurrentUser() user: AuthenticatedUser) {
    return this.customerProfilesService.getOwn(user.id);
  }

  @ApiOperation({ summary: 'Update the authenticated user customer profile' })
  @Patch('me')
  updateMe(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateCustomerProfileDto,
  ) {
    return this.customerProfilesService.updateOwn(user.id, dto);
  }

  @ApiOperation({ summary: 'Deactivate the authenticated user customer profile' })
  @Post('me/deactivate')
  deactivate(@CurrentUser() user: AuthenticatedUser) {
    return this.customerProfilesService.deactivateOwn(user.id);
  }

  @ApiOperation({ summary: 'Restore the authenticated user customer profile' })
  @Post('me/restore')
  restore(@CurrentUser() user: AuthenticatedUser) {
    return this.customerProfilesService.restoreOwn(user.id);
  }
}
