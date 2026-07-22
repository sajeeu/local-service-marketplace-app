import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Public } from '../identity/authorization/public.decorator';
import {
  ListAtollsQueryDto,
  ListIslandsByAtollQueryDto,
  ListIslandsQueryDto,
} from './dto/geography.dto';
import { GeographyService } from './geography.service';

@ApiTags('geography')
@Controller({ version: '1' })
export class GeographyController {
  constructor(private readonly geographyService: GeographyService) {}

  @Public()
  @Get('atolls')
  @ApiOperation({ summary: 'List Maldives atolls' })
  listAtolls(@Query() query: ListAtollsQueryDto) {
    return this.geographyService.listAtolls(query);
  }

  @Public()
  @Get('atolls/:id')
  @ApiOperation({ summary: 'Get an atoll by id' })
  getAtoll(@Param('id') id: string) {
    return this.geographyService.getAtoll(id);
  }

  @Public()
  @Get('atolls/:id/islands')
  @ApiOperation({ summary: 'List islands in an atoll' })
  listIslandsByAtoll(
    @Param('id') id: string,
    @Query() query: ListIslandsByAtollQueryDto,
  ) {
    return this.geographyService.listIslandsByAtoll(id, query);
  }

  @Public()
  @Get('islands')
  @ApiOperation({ summary: 'List Maldives islands' })
  listIslands(@Query() query: ListIslandsQueryDto) {
    return this.geographyService.listIslands(query);
  }

  @Public()
  @Get('islands/:id')
  @ApiOperation({ summary: 'Get an island by id' })
  getIsland(@Param('id') id: string) {
    return this.geographyService.getIsland(id);
  }
}
