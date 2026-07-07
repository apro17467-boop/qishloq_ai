import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import {
  AdminListingsResponse,
  AdminListingsService,
  ModerateListingResponse,
} from './admin-listings.service';
import { AdminListingsQueryDto } from './dto/admin-listings-query.dto';
import { ModerateListingDto } from './dto/moderate-listing.dto';

@Controller('admin/listings')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@ApiTags('Admin Listings')
@ApiBearerAuth()
export class AdminListingsController {
  constructor(private readonly adminListingsService: AdminListingsService) {}

  @Get()
  getListings(
    @Query() query: AdminListingsQueryDto,
  ): Promise<AdminListingsResponse> {
    return this.adminListingsService.getListings(query);
  }

  @Patch(':id/moderate')
  moderateListing(
    @Param('id', new ParseUUIDPipe()) id: string,
    @Body() dto: ModerateListingDto,
  ): Promise<ModerateListingResponse> {
    return this.adminListingsService.moderateListing(id, dto);
  }
}
