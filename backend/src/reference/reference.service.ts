import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma.service';

const categorySelect = {
  id: true,
  nameUz: true,
  nameRu: true,
  slug: true,
  type: true,
  parentId: true,
  sortOrder: true,
} satisfies Prisma.CategorySelect;

const regionSelect = {
  id: true,
  nameUz: true,
  nameRu: true,
  type: true,
  parentId: true,
} satisfies Prisma.RegionSelect;

export type CategoryReference = Prisma.CategoryGetPayload<{
  select: typeof categorySelect;
}>;

export type RegionReference = Prisma.RegionGetPayload<{
  select: typeof regionSelect;
}>;

export interface ReferenceResponse<T> {
  data: T[];
}

@Injectable()
export class ReferenceService {
  constructor(private readonly prisma: PrismaService) {}

  async getCategories(): Promise<ReferenceResponse<CategoryReference>> {
    const categories = await this.prisma.category.findMany({
      where: {
        isActive: true,
      },
      select: categorySelect,
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });

    return {
      data: categories,
    };
  }

  async getRegions(): Promise<ReferenceResponse<RegionReference>> {
    const regions = await this.prisma.region.findMany({
      select: regionSelect,
      orderBy: [{ type: 'asc' }, { nameUz: 'asc' }],
    });

    return {
      data: regions,
    };
  }
}
