import { Module } from '@nestjs/common';
import { ProviderCoverageController } from './provider-coverage.controller';
import { ProviderCoverageService } from './provider-coverage.service';
import { ProviderProfilesController } from './provider-profiles.controller';
import { ProviderProfilesService } from './provider-profiles.service';

@Module({
  controllers: [ProviderProfilesController, ProviderCoverageController],
  providers: [ProviderProfilesService, ProviderCoverageService],
  exports: [ProviderProfilesService, ProviderCoverageService],
})
export class ProvidersModule {}
