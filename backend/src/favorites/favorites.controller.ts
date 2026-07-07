import {
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user.type';
import {
  FavoriteToggleResponse,
  FavoritesListResponse,
  FavoritesService,
  FavoriteIdsResponse,
} from './favorites.service';
import { FavoritesQueryDto } from './dto/favorites-query.dto';

@Controller('favorites')
@ApiTags('Favorites')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class FavoritesController {
  constructor(private readonly favoritesService: FavoritesService) {}

  @Get('my')
  getFavorites(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: FavoritesQueryDto,
  ): Promise<FavoritesListResponse> {
    return this.favoritesService.getFavorites(user.sub, query);
  }

  @Get('ids')
  getFavoriteIds(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<FavoriteIdsResponse> {
    return this.favoritesService.getFavoriteIds(user.sub);
  }

  @Post(':listingId')
  addFavorite(
    @CurrentUser() user: AuthenticatedUser,
    @Param('listingId', new ParseUUIDPipe()) listingId: string,
  ): Promise<FavoriteToggleResponse> {
    return this.favoritesService.addFavorite(user.sub, listingId);
  }

  @Delete(':listingId')
  removeFavorite(
    @CurrentUser() user: AuthenticatedUser,
    @Param('listingId', new ParseUUIDPipe()) listingId: string,
  ): Promise<FavoriteToggleResponse> {
    return this.favoritesService.removeFavorite(user.sub, listingId);
  }
}
