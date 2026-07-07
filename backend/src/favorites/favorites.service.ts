import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { ListingStatus, Prisma } from '@prisma/client';
import { PaginatedResponse } from '../common/pagination/pagination.types';
import {
  buildPaginationMeta,
  getPaginationParams,
} from '../common/pagination/pagination.util';
import { PrismaService } from '../database/prisma.service';
import { FavoritesQueryDto } from './dto/favorites-query.dto';

const favoriteListingSelect = {
  id: true,
  type: true,
  status: true,
  title: true,
  description: true,
  priceAmount: true,
  priceCurrency: true,
  unit: true,
  contactPhone: true,
  address: true,
  viewCount: true,
  createdAt: true,
  category: {
    select: {
      id: true,
      nameUz: true,
      slug: true,
    },
  },
  region: {
    select: {
      id: true,
      nameUz: true,
      type: true,
    },
  },
  images: {
    select: {
      id: true,
      url: true,
      sortOrder: true,
    },
    orderBy: {
      sortOrder: 'asc',
    },
  },
} satisfies Prisma.ListingSelect;

type FavoriteListingItem = Prisma.ListingGetPayload<{
  select: typeof favoriteListingSelect;
}>;

type SerializedFavoriteListingItem = Omit<
  FavoriteListingItem,
  'priceAmount'
> & {
  priceAmount: string | null;
  isFavorite: boolean;
};

export interface FavoritesListResponse
  extends PaginatedResponse<SerializedFavoriteListingItem> {}

export interface FavoriteToggleResponse {
  success: true;
  message: string;
}

export interface FavoriteIdsResponse {
  data: string[];
}

@Injectable()
export class FavoritesService {
  constructor(private readonly prisma: PrismaService) {}

  async getFavorites(
    userId: string,
    query: FavoritesQueryDto,
  ): Promise<FavoritesListResponse> {
    await this.assertActiveUser(userId);

    const pagination = getPaginationParams(query.page, query.limit);
    const where: Prisma.FavoriteWhereInput = {
      userId,
      listing: {
        status: ListingStatus.ACTIVE,
        deletedAt: null,
      },
    };

    const [total, favorites] = await this.prisma.$transaction([
      this.prisma.favorite.count({ where }),
      this.prisma.favorite.findMany({
        where,
        orderBy: {
          createdAt: 'desc',
        },
        skip: pagination.skip,
        take: pagination.take,
        select: {
          listing: {
            select: favoriteListingSelect,
          },
        },
      }),
    ]);

    return {
      data: favorites.map((favorite) =>
        this.serializeFavoriteListingItem(favorite.listing),
      ),
      meta: buildPaginationMeta(pagination.page, pagination.limit, total),
    };
  }

  async addFavorite(
    userId: string,
    listingId: string,
  ): Promise<FavoriteToggleResponse> {
    await this.assertActiveUser(userId);
    await this.assertActiveListing(listingId);

    await this.prisma.favorite.upsert({
      where: {
        userId_listingId: {
          userId,
          listingId,
        },
      },
      update: {},
      create: {
        userId,
        listingId,
      },
    });

    return {
      success: true,
      message: 'E’lon sevimlilarga qo‘shildi',
    };
  }

  async removeFavorite(
    userId: string,
    listingId: string,
  ): Promise<FavoriteToggleResponse> {
    await this.assertActiveUser(userId);
    await this.assertExistingListing(listingId);

    await this.prisma.favorite.deleteMany({
      where: {
        userId,
        listingId,
      },
    });

    return {
      success: true,
      message: 'E’lon sevimlilardan olib tashlandi',
    };
  }

  async getFavoriteIds(userId: string): Promise<FavoriteIdsResponse> {
    await this.assertActiveUser(userId);

    const favorites = await this.prisma.favorite.findMany({
      where: {
        userId,
      },
      select: {
        listingId: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return {
      data: favorites.map((favorite) => favorite.listingId),
    };
  }

  private async assertActiveUser(userId: string): Promise<void> {
    const user = await this.prisma.user.findUnique({
      where: {
        id: userId,
      },
      select: {
        id: true,
        isActive: true,
      },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('Unauthorized');
    }
  }

  private async assertActiveListing(listingId: string): Promise<void> {
    const listing = await this.prisma.listing.findFirst({
      where: {
        id: listingId,
        status: ListingStatus.ACTIVE,
        deletedAt: null,
      },
      select: {
        id: true,
      },
    });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }
  }

  private async assertExistingListing(listingId: string): Promise<void> {
    const listing = await this.prisma.listing.findFirst({
      where: {
        id: listingId,
        deletedAt: null,
      },
      select: {
        id: true,
      },
    });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }
  }

  private serializeFavoriteListingItem(
    listing: FavoriteListingItem,
  ): SerializedFavoriteListingItem {
    return {
      ...listing,
      priceAmount: listing.priceAmount?.toString() ?? null,
      isFavorite: true,
    };
  }
}
