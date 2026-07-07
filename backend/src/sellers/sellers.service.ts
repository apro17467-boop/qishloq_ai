import { Injectable, NotFoundException } from '@nestjs/common';
import { ListingStatus, Prisma } from '@prisma/client';
import { PaginatedResponse } from '../common/pagination/pagination.types';
import {
  buildPaginationMeta,
  getPaginationParams,
} from '../common/pagination/pagination.util';
import { PrismaService } from '../database/prisma.service';
import { SellerListingsQueryDto } from './dto/seller-listings-query.dto';

const sellerProfileSelect = {
  id: true,
  role: true,
  isVerified: true,
  createdAt: true,
  profile: {
    select: {
      fullName: true,
      address: true,
      region: {
        select: {
          id: true,
          nameUz: true,
        },
      },
    },
  },
} satisfies Prisma.UserSelect;

const sellerListingSelect = {
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

type SellerProfileItem = Prisma.UserGetPayload<{
  select: typeof sellerProfileSelect;
}>;

type SellerListingItem = Prisma.ListingGetPayload<{
  select: typeof sellerListingSelect;
}>;

type PublicSellerProfile = {
  id: string;
  fullName: string | null;
  role: SellerProfileItem['role'];
  region: SellerProfileItem['profile'] extends null
    ? null
    : NonNullable<SellerProfileItem['profile']>['region'];
  address: string | null;
  isVerified: boolean;
  activeListingsCount: number;
  createdAt: Date;
};

type SerializedSellerListingItem = Omit<SellerListingItem, 'priceAmount'> & {
  priceAmount: string | null;
  isFavorite: boolean;
};

export interface SellerProfileResponse {
  data: PublicSellerProfile;
}

export interface SellerListingsResponse
  extends PaginatedResponse<SerializedSellerListingItem> {}

@Injectable()
export class SellersService {
  constructor(private readonly prisma: PrismaService) {}

  async getSellerProfile(sellerId: string): Promise<SellerProfileResponse> {
    const seller = await this.getActiveSeller(sellerId);

    const activeListingsCount = await this.prisma.listing.count({
      where: this.buildSellerListingsWhere(seller.id),
    });

    return {
      data: this.serializeSellerProfile(seller, activeListingsCount),
    };
  }

  async getSellerListings(
    sellerId: string,
    query: SellerListingsQueryDto,
    currentUserId?: string,
  ): Promise<SellerListingsResponse> {
    await this.getActiveSeller(sellerId);

    const pagination = getPaginationParams(query.page, query.limit);
    const where = this.buildSellerListingsWhere(sellerId);

    const [total, listings] = await this.prisma.$transaction([
      this.prisma.listing.count({ where }),
      this.prisma.listing.findMany({
        where,
        select: sellerListingSelect,
        orderBy: {
          createdAt: 'desc',
        },
        skip: pagination.skip,
        take: pagination.take,
      }),
    ]);

    const favoriteIds = await this.getFavoriteListingIds(
      currentUserId,
      listings.map((listing) => listing.id),
    );

    return {
      data: listings.map((listing) =>
        this.serializeSellerListingItem(
          listing,
          favoriteIds.has(listing.id),
        ),
      ),
      meta: buildPaginationMeta(pagination.page, pagination.limit, total),
    };
  }

  private async getActiveSeller(sellerId: string): Promise<SellerProfileItem> {
    const seller = await this.prisma.user.findFirst({
      where: {
        id: sellerId,
        isActive: true,
      },
      select: sellerProfileSelect,
    });

    if (!seller) {
      throw new NotFoundException('Seller not found');
    }

    return seller;
  }

  private buildSellerListingsWhere(sellerId: string): Prisma.ListingWhereInput {
    return {
      ownerId: sellerId,
      status: ListingStatus.ACTIVE,
      deletedAt: null,
    };
  }

  private async getFavoriteListingIds(
    userId: string | undefined,
    listingIds: string[],
  ): Promise<Set<string>> {
    if (!userId || listingIds.length === 0) {
      return new Set();
    }

    const favorites = await this.prisma.favorite.findMany({
      where: {
        userId,
        listingId: {
          in: listingIds,
        },
      },
      select: {
        listingId: true,
      },
    });

    return new Set(favorites.map((favorite) => favorite.listingId));
  }

  private serializeSellerProfile(
    seller: SellerProfileItem,
    activeListingsCount: number,
  ): PublicSellerProfile {
    return {
      id: seller.id,
      fullName: seller.profile?.fullName ?? null,
      role: seller.role,
      region: seller.profile?.region ?? null,
      address: seller.profile?.address ?? null,
      isVerified: seller.isVerified,
      activeListingsCount,
      createdAt: seller.createdAt,
    };
  }

  private serializeSellerListingItem(
    listing: SellerListingItem,
    isFavorite = false,
  ): SerializedSellerListingItem {
    return {
      ...listing,
      priceAmount: listing.priceAmount?.toString() ?? null,
      isFavorite,
    };
  }
}
