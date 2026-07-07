import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { ListingStatus, Prisma } from '@prisma/client';
import { PaginatedResponse } from '../common/pagination/pagination.types';
import {
  buildPaginationMeta,
  getPaginationParams,
} from '../common/pagination/pagination.util';
import { PrismaService } from '../database/prisma.service';
import { AdminListingsQueryDto } from './dto/admin-listings-query.dto';
import { ModerateListingDto } from './dto/moderate-listing.dto';

const adminListingSelect = {
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
  createdAt: true,
  updatedAt: true,
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
  owner: {
    select: {
      id: true,
      phone: true,
      profile: {
        select: {
          fullName: true,
          avatarUrl: true,
        },
      },
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

const moderatedListingSelect = {
  id: true,
  status: true,
  title: true,
  updatedAt: true,
} satisfies Prisma.ListingSelect;

type AdminListingItem = Prisma.ListingGetPayload<{
  select: typeof adminListingSelect;
}>;

type ModeratedListingItem = Prisma.ListingGetPayload<{
  select: typeof moderatedListingSelect;
}>;

type SerializedAdminListingItem = Omit<AdminListingItem, 'priceAmount'> & {
  priceAmount: string | null;
};

export interface AdminListingsResponse
  extends PaginatedResponse<SerializedAdminListingItem> {}

export interface ModerateListingResponse {
  data: ModeratedListingItem;
}

@Injectable()
export class AdminListingsService {
  constructor(private readonly prisma: PrismaService) {}

  async getListings(
    query: AdminListingsQueryDto,
  ): Promise<AdminListingsResponse> {
    const pagination = getPaginationParams(query.page, query.limit);
    const where = this.buildListingWhere(query);

    const [total, listings] = await this.prisma.$transaction([
      this.prisma.listing.count({ where }),
      this.prisma.listing.findMany({
        where,
        select: adminListingSelect,
        orderBy: {
          createdAt: 'desc',
        },
        skip: pagination.skip,
        take: pagination.take,
      }),
    ]);

    return {
      data: listings.map((listing) => this.serializeListing(listing)),
      meta: buildPaginationMeta(pagination.page, pagination.limit, total),
    };
  }

  async moderateListing(
    id: string,
    dto: ModerateListingDto,
  ): Promise<ModerateListingResponse> {
    const listing = await this.prisma.listing.findFirst({
      where: {
        id,
        deletedAt: null,
      },
      select: {
        id: true,
        status: true,
      },
    });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }

    if (listing.status === ListingStatus.ARCHIVED) {
      throw new BadRequestException('Archived listing cannot be moderated');
    }

    const moderatedListing = await this.prisma.listing.update({
      where: {
        id: listing.id,
      },
      data: {
        status: dto.status,
      },
      select: moderatedListingSelect,
    });

    return {
      data: moderatedListing,
    };
  }

  private buildListingWhere(
    query: AdminListingsQueryDto,
  ): Prisma.ListingWhereInput {
    return {
      deletedAt: null,
      status: query.status ?? ListingStatus.PENDING,
      ...(query.type ? { type: query.type } : {}),
    };
  }

  private serializeListing(
    listing: AdminListingItem,
  ): SerializedAdminListingItem {
    return {
      ...listing,
      priceAmount: listing.priceAmount?.toString() ?? null,
    };
  }
}
