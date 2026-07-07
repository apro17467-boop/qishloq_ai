import { Controller, Get, Param, ParseUUIDPipe, Query, UseGuards } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { OptionalJwtAuthGuard } from '../auth/guards/optional-jwt-auth.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user.type';
import { SellerListingsQueryDto } from './dto/seller-listings-query.dto';
import {
  SellerListingsResponse,
  SellerProfileResponse,
  SellersService,
} from './sellers.service';

@Controller('sellers')
@ApiTags('Sellers')
export class SellersController {
  constructor(private readonly sellersService: SellersService) {}

  @Get(':sellerId/listings')
  @UseGuards(OptionalJwtAuthGuard)
  getSellerListings(
    @Param('sellerId', new ParseUUIDPipe()) sellerId: string,
    @Query() query: SellerListingsQueryDto,
    @CurrentUser() user?: AuthenticatedUser,
  ): Promise<SellerListingsResponse> {
    return this.sellersService.getSellerListings(sellerId, query, user?.sub);
  }

  @Get(':sellerId')
  getSellerProfile(
    @Param('sellerId', new ParseUUIDPipe()) sellerId: string,
  ): Promise<SellerProfileResponse> {
    return this.sellersService.getSellerProfile(sellerId);
  }
}
