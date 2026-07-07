import {
  BadRequestException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { ListingStatus, Prisma } from '@prisma/client';
import { writeFile, unlink } from 'fs/promises';
import { join, resolve } from 'path';
import { PaginatedResponse } from '../common/pagination/pagination.types';
import {
  buildPaginationMeta,
  getPaginationParams,
} from '../common/pagination/pagination.util';
import { PrismaService } from '../database/prisma.service';
import { CreateListingDto } from './dto/create-listing.dto';
import { ListListingsQueryDto } from './dto/list-listings-query.dto';
import { MyListingsQueryDto } from './dto/my-listings-query.dto';
import { UpdateListingDto } from './dto/update-listing.dto';
import {
  ensureUploadDir,
  generateSafeFileName,
} from './utils/file-upload.util';

const listingListSelect = {
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

const listingDetailSelect = {
  ...listingListSelect,
  updatedAt: true,
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
} satisfies Prisma.ListingSelect;

const createdListingSelect = {
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
} satisfies Prisma.ListingSelect;

const myListingSelect = {
  ...listingListSelect,
  updatedAt: true,
} satisfies Prisma.ListingSelect;

const archiveListingSelect = {
  id: true,
  status: true,
  title: true,
} satisfies Prisma.ListingSelect;

const listingImageSelect = {
  id: true,
  url: true,
  sortOrder: true,
  createdAt: true,
} satisfies Prisma.ListingImageSelect;

type ListingListItem = Prisma.ListingGetPayload<{
  select: typeof listingListSelect;
}>;

type ListingDetailItem = Prisma.ListingGetPayload<{
  select: typeof listingDetailSelect;
}>;

type CreatedListingItem = Prisma.ListingGetPayload<{
  select: typeof createdListingSelect;
}>;

type MyListingItem = Prisma.ListingGetPayload<{
  select: typeof myListingSelect;
}>;

type ArchivedListingItem = Prisma.ListingGetPayload<{
  select: typeof archiveListingSelect;
}>;

type ListingImageItem = Prisma.ListingImageGetPayload<{
  select: typeof listingImageSelect;
}>;

type SerializedListingListItem = Omit<ListingListItem, 'priceAmount'> & {
  priceAmount: string | null;
};

type SerializedListingDetailItem = Omit<ListingDetailItem, 'priceAmount'> & {
  priceAmount: string | null;
};

type SerializedCreatedListingItem = Omit<CreatedListingItem, 'priceAmount'> & {
  priceAmount: string | null;
};

type SerializedMyListingItem = Omit<MyListingItem, 'priceAmount'> & {
  priceAmount: string | null;
};

export interface ListingsListResponse
  extends PaginatedResponse<SerializedListingListItem> {}

export interface ListingDetailResponse {
  data: SerializedListingDetailItem;
}

export interface CreateListingResponse {
  data: SerializedCreatedListingItem;
}

export interface MyListingsResponse
  extends PaginatedResponse<SerializedMyListingItem> {}

export interface UpdateListingResponse {
  data: SerializedMyListingItem;
}

export interface ArchiveListingResponse {
  data: ArchivedListingItem;
}

export interface ListingImageUploadFile {
  originalName: string;
  mimeType: string;
  buffer: Buffer;
  size: number;
}

export interface UploadListingImageResponse {
  data: ListingImageItem;
}

@Injectable()
export class ListingsService {
  private readonly maxImagesPerListing = 5;

  constructor(private readonly prisma: PrismaService) {}

  async createListing(
    userId: string,
    dto: CreateListingDto,
  ): Promise<CreateListingResponse> {
    const user = await this.prisma.user.findUnique({
      where: {
        id: userId,
      },
      select: {
        id: true,
        phone: true,
        isActive: true,
      },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('Unauthorized');
    }

    const category = await this.prisma.category.findFirst({
      where: {
        id: dto.categoryId,
        isActive: true,
      },
      select: {
        id: true,
        type: true,
      },
    });

    if (!category) {
      throw new BadRequestException('Category not found');
    }

    if (category.type !== dto.type) {
      throw new BadRequestException('Category type does not match listing type');
    }

    if (dto.regionId) {
      const region = await this.prisma.region.findUnique({
        where: {
          id: dto.regionId,
        },
        select: {
          id: true,
        },
      });

      if (!region) {
        throw new BadRequestException('Region not found');
      }
    }

    const priceCurrency = dto.priceCurrency ?? 'UZS';

    if (priceCurrency !== 'UZS') {
      throw new BadRequestException('Only UZS currency is supported');
    }

    const listing = await this.prisma.listing.create({
      data: {
        ownerId: user.id,
        categoryId: dto.categoryId,
        regionId: dto.regionId,
        type: dto.type,
        status: ListingStatus.PENDING,
        title: dto.title,
        description: dto.description,
        priceAmount: dto.priceAmount
          ? new Prisma.Decimal(dto.priceAmount)
          : undefined,
        priceCurrency,
        unit: dto.unit,
        contactPhone: dto.contactPhone ?? user.phone,
        address: dto.address,
      },
      select: createdListingSelect,
    });

    return {
      data: this.serializeCreatedListingItem(listing),
    };
  }

  async getListings(
    query: ListListingsQueryDto,
  ): Promise<ListingsListResponse> {
    const pagination = getPaginationParams(query.page, query.limit);
    const where = this.buildPublicListingWhere(query);

    const [total, listings] = await this.prisma.$transaction([
      this.prisma.listing.count({ where }),
      this.prisma.listing.findMany({
        where,
        select: listingListSelect,
        orderBy: {
          createdAt: 'desc',
        },
        skip: pagination.skip,
        take: pagination.take,
      }),
    ]);

    return {
      data: listings.map((listing) => this.serializeListingListItem(listing)),
      meta: buildPaginationMeta(pagination.page, pagination.limit, total),
    };
  }

  async getMyListings(
    userId: string,
    query: MyListingsQueryDto,
  ): Promise<MyListingsResponse> {
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

    const pagination = getPaginationParams(query.page, query.limit);
    const where = this.buildMyListingWhere(user.id, query);

    const [total, listings] = await this.prisma.$transaction([
      this.prisma.listing.count({ where }),
      this.prisma.listing.findMany({
        where,
        select: myListingSelect,
        orderBy: {
          createdAt: 'desc',
        },
        skip: pagination.skip,
        take: pagination.take,
      }),
    ]);

    return {
      data: listings.map((listing) => this.serializeMyListingItem(listing)),
      meta: buildPaginationMeta(pagination.page, pagination.limit, total),
    };
  }

  async updateListing(
    userId: string,
    id: string,
    dto: UpdateListingDto,
  ): Promise<UpdateListingResponse> {
    await this.assertActiveUser(userId);

    const listing = await this.prisma.listing.findFirst({
      where: {
        id,
        ownerId: userId,
        deletedAt: null,
      },
      select: {
        id: true,
        type: true,
        categoryId: true,
        status: true,
      },
    });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }

    if (listing.status === ListingStatus.ARCHIVED) {
      throw new BadRequestException('Archived listing cannot be updated');
    }

    if (!this.hasUpdateFields(dto)) {
      throw new BadRequestException('At least one field must be provided');
    }

    const categoryChanged = dto.categoryId !== undefined || dto.type !== undefined;
    const effectiveType = dto.type ?? listing.type;
    const effectiveCategoryId = dto.categoryId ?? listing.categoryId;

    if (categoryChanged) {
      const category = await this.prisma.category.findFirst({
        where: {
          id: effectiveCategoryId,
          isActive: true,
        },
        select: {
          id: true,
          type: true,
        },
      });

      if (!category) {
        throw new BadRequestException('Category not found');
      }

      if (category.type !== effectiveType) {
        throw new BadRequestException('Category type does not match listing type');
      }
    }

    if (dto.regionId !== undefined) {
      const region = await this.prisma.region.findUnique({
        where: {
          id: dto.regionId,
        },
        select: {
          id: true,
        },
      });

      if (!region) {
        throw new BadRequestException('Region not found');
      }
    }

    if (dto.priceCurrency !== undefined && dto.priceCurrency !== 'UZS') {
      throw new BadRequestException('Only UZS currency is supported');
    }

    const updatedListing = await this.prisma.listing.update({
      where: {
        id: listing.id,
      },
      data: {
        status: ListingStatus.PENDING,
        ...(dto.type !== undefined ? { type: dto.type } : {}),
        ...(dto.categoryId !== undefined ? { categoryId: dto.categoryId } : {}),
        ...(dto.regionId !== undefined ? { regionId: dto.regionId } : {}),
        ...(dto.title !== undefined ? { title: dto.title } : {}),
        ...(dto.description !== undefined ? { description: dto.description } : {}),
        ...(dto.priceAmount !== undefined
          ? { priceAmount: new Prisma.Decimal(dto.priceAmount) }
          : {}),
        ...(dto.priceCurrency !== undefined
          ? { priceCurrency: dto.priceCurrency }
          : {}),
        ...(dto.unit !== undefined ? { unit: dto.unit } : {}),
        ...(dto.contactPhone !== undefined
          ? { contactPhone: dto.contactPhone }
          : {}),
        ...(dto.address !== undefined ? { address: dto.address } : {}),
      },
      select: myListingSelect,
    });

    return {
      data: this.serializeMyListingItem(updatedListing),
    };
  }

  async archiveListing(
    userId: string,
    id: string,
  ): Promise<ArchiveListingResponse> {
    await this.assertActiveUser(userId);

    const listing = await this.prisma.listing.findFirst({
      where: {
        id,
        ownerId: userId,
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
      throw new BadRequestException('Listing is already archived');
    }

    const archivedListing = await this.prisma.listing.update({
      where: {
        id: listing.id,
      },
      data: {
        status: ListingStatus.ARCHIVED,
      },
      select: archiveListingSelect,
    });

    return {
      data: archivedListing,
    };
  }

  async addListingImage(
    userId: string,
    listingId: string,
    fileInfo: ListingImageUploadFile,
  ): Promise<UploadListingImageResponse> {
    await this.assertActiveUser(userId);

    const listing = await this.prisma.listing.findFirst({
      where: {
        id: listingId,
        ownerId: userId,
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
      throw new BadRequestException('Archived listing cannot receive images');
    }

    const imageCount = await this.prisma.listingImage.count({
      where: {
        listingId: listing.id,
      },
    });

    if (imageCount >= this.maxImagesPerListing) {
      throw new BadRequestException('Maximum 5 images per listing are allowed');
    }

    const uploadDir = this.getListingsUploadDir();
    const filename = generateSafeFileName(
      fileInfo.originalName,
      fileInfo.mimeType,
    );
    const filePath = join(uploadDir, filename);
    const url = `${this.getPublicBaseUrl()}/uploads/listings/${filename}`;

    ensureUploadDir(uploadDir);
    await writeFile(filePath, fileInfo.buffer);

    try {
      const image = await this.prisma.listingImage.create({
        data: {
          listingId: listing.id,
          url,
          sortOrder: imageCount,
        },
        select: listingImageSelect,
      });

      return {
        data: image,
      };
    } catch (error) {
      await this.deleteFileIfExists(filePath);
      throw error;
    }
  }

  async getListingById(id: string): Promise<ListingDetailResponse> {
    const listing = await this.prisma.listing.findFirst({
      where: {
        id,
        status: ListingStatus.ACTIVE,
        deletedAt: null,
      },
      select: listingDetailSelect,
    });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }

    void this.incrementViewCount(id);

    return {
      data: this.serializeListingDetailItem({
        ...listing,
        viewCount: listing.viewCount + 1,
      }),
    };
  }

  private buildPublicListingWhere(
    query: ListListingsQueryDto,
  ): Prisma.ListingWhereInput {
    const where: Prisma.ListingWhereInput = {
      status: ListingStatus.ACTIVE,
      deletedAt: null,
    };

    if (query.type) {
      where.type = query.type;
    }

    if (query.categoryId) {
      where.categoryId = query.categoryId;
    }

    if (query.regionId) {
      where.regionId = query.regionId;
    }

    if (query.search) {
      where.OR = [
        {
          title: {
            contains: query.search,
            mode: 'insensitive',
          },
        },
        {
          description: {
            contains: query.search,
            mode: 'insensitive',
          },
        },
      ];
    }

    return where;
  }

  private buildMyListingWhere(
    userId: string,
    query: MyListingsQueryDto,
  ): Prisma.ListingWhereInput {
    const where: Prisma.ListingWhereInput = {
      ownerId: userId,
      deletedAt: null,
    };

    if (query.status) {
      where.status = query.status;
    }

    if (query.type) {
      where.type = query.type;
    }

    return where;
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

  private hasUpdateFields(dto: UpdateListingDto): boolean {
    return Object.values(dto).some((value) => value !== undefined);
  }

  private getListingsUploadDir(): string {
    return resolve(process.cwd(), process.env.UPLOAD_DIR ?? 'uploads', 'listings');
  }

  private getPublicBaseUrl(): string {
    return (process.env.PUBLIC_BASE_URL ?? 'http://localhost:3000').replace(
      /\/+$/,
      '',
    );
  }

  private async deleteFileIfExists(filePath: string): Promise<void> {
    try {
      await unlink(filePath);
    } catch {
      // Cleanup should not hide the original persistence error.
    }
  }

  private serializeListingListItem(
    listing: ListingListItem,
  ): SerializedListingListItem {
    return {
      ...listing,
      priceAmount: listing.priceAmount?.toString() ?? null,
    };
  }

  private serializeListingDetailItem(
    listing: ListingDetailItem,
  ): SerializedListingDetailItem {
    return {
      ...listing,
      priceAmount: listing.priceAmount?.toString() ?? null,
    };
  }

  private serializeCreatedListingItem(
    listing: CreatedListingItem,
  ): SerializedCreatedListingItem {
    return {
      ...listing,
      priceAmount: listing.priceAmount?.toString() ?? null,
    };
  }

  private serializeMyListingItem(
    listing: MyListingItem,
  ): SerializedMyListingItem {
    return {
      ...listing,
      priceAmount: listing.priceAmount?.toString() ?? null,
    };
  }

  private async incrementViewCount(id: string): Promise<void> {
    try {
      await this.prisma.listing.update({
        where: {
          id,
        },
        data: {
          viewCount: {
            increment: 1,
          },
        },
      });
    } catch {
      // Public detail response should not fail only because analytics failed.
    }
  }
}
