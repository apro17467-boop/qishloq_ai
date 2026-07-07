import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PaginatedResponse } from '../common/pagination/pagination.types';
import {
  buildPaginationMeta,
  getPaginationParams,
} from '../common/pagination/pagination.util';
import { PrismaService } from '../database/prisma.service';
import { AdminUsersQueryDto } from './dto/admin-users-query.dto';

const userProfileSelect = {
  fullName: true,
  avatarUrl: true,
  address: true,
  region: {
    select: {
      id: true,
      nameUz: true,
      type: true,
    },
  },
} satisfies Prisma.ProfileSelect;

const adminUserListSelect = {
  id: true,
  phone: true,
  role: true,
  isActive: true,
  isVerified: true,
  createdAt: true,
  updatedAt: true,
  profile: {
    select: userProfileSelect,
  },
  _count: {
    select: {
      listings: true,
      complaints: true,
      aiQuestions: true,
    },
  },
} satisfies Prisma.UserSelect;

const adminUserDetailSelect = {
  ...adminUserListSelect,
  listings: {
    select: {
      id: true,
      title: true,
      type: true,
      status: true,
      createdAt: true,
    },
    orderBy: {
      createdAt: 'desc',
    },
    take: 5,
  },
  complaints: {
    select: {
      id: true,
      reason: true,
      status: true,
      createdAt: true,
    },
    orderBy: {
      createdAt: 'desc',
    },
    take: 5,
  },
  aiQuestions: {
    select: {
      id: true,
      question: true,
      status: true,
      createdAt: true,
    },
    orderBy: {
      createdAt: 'desc',
    },
    take: 5,
  },
} satisfies Prisma.UserSelect;

type AdminUserListItem = Prisma.UserGetPayload<{
  select: typeof adminUserListSelect;
}>;

type AdminUserDetailItem = Prisma.UserGetPayload<{
  select: typeof adminUserDetailSelect;
}>;

type AdminUserStats = {
  listingsCount: number;
  complaintsCount: number;
  aiQuestionsCount: number;
};

type SerializedAdminUserListItem = Omit<AdminUserListItem, '_count'> & {
  stats: AdminUserStats;
};

type SerializedAdminUserDetailItem = Omit<
  AdminUserDetailItem,
  '_count' | 'listings' | 'complaints' | 'aiQuestions'
> & {
  stats: AdminUserStats;
  recentListings: AdminUserDetailItem['listings'];
  recentComplaints: AdminUserDetailItem['complaints'];
  recentAiQuestions: AdminUserDetailItem['aiQuestions'];
};

export interface AdminUsersResponse
  extends PaginatedResponse<SerializedAdminUserListItem> {}

export interface AdminUserDetailResponse {
  data: SerializedAdminUserDetailItem;
}

@Injectable()
export class AdminUsersService {
  constructor(private readonly prisma: PrismaService) {}

  async getUsers(query: AdminUsersQueryDto): Promise<AdminUsersResponse> {
    const pagination = getPaginationParams(query.page, query.limit);
    const where = this.buildUserWhere(query);

    const [total, users] = await this.prisma.$transaction([
      this.prisma.user.count({ where }),
      this.prisma.user.findMany({
        where,
        select: adminUserListSelect,
        orderBy: {
          createdAt: 'desc',
        },
        skip: pagination.skip,
        take: pagination.take,
      }),
    ]);

    return {
      data: users.map((user) => this.serializeUserListItem(user)),
      meta: buildPaginationMeta(pagination.page, pagination.limit, total),
    };
  }

  async getUserById(id: string): Promise<AdminUserDetailResponse> {
    const user = await this.prisma.user.findUnique({
      where: {
        id,
      },
      select: adminUserDetailSelect,
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      data: this.serializeUserDetailItem(user),
    };
  }

  private buildUserWhere(query: AdminUsersQueryDto): Prisma.UserWhereInput {
    const search = query.search?.trim();

    return {
      ...(query.role ? { role: query.role } : {}),
      ...(query.isActive !== undefined ? { isActive: query.isActive } : {}),
      ...(query.isVerified !== undefined
        ? { isVerified: query.isVerified }
        : {}),
      ...(search
        ? {
            OR: [
              {
                phone: {
                  contains: search,
                },
              },
              {
                profile: {
                  is: {
                    fullName: {
                      contains: search,
                      mode: 'insensitive',
                    },
                  },
                },
              },
            ],
          }
        : {}),
    };
  }

  private serializeUserListItem(
    user: AdminUserListItem,
  ): SerializedAdminUserListItem {
    const { _count, ...userData } = user;

    return {
      ...userData,
      stats: this.serializeStats(_count),
    };
  }

  private serializeUserDetailItem(
    user: AdminUserDetailItem,
  ): SerializedAdminUserDetailItem {
    const { _count, listings, complaints, aiQuestions, ...userData } = user;

    return {
      ...userData,
      stats: this.serializeStats(_count),
      recentListings: listings,
      recentComplaints: complaints,
      recentAiQuestions: aiQuestions,
    };
  }

  private serializeStats(count: AdminUserListItem['_count']): AdminUserStats {
    return {
      listingsCount: count.listings,
      complaintsCount: count.complaints,
      aiQuestionsCount: count.aiQuestions,
    };
  }
}
