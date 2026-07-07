import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { ComplaintStatus, Prisma } from '@prisma/client';
import { PaginatedResponse } from '../common/pagination/pagination.types';
import {
  buildPaginationMeta,
  getPaginationParams,
} from '../common/pagination/pagination.util';
import { PrismaService } from '../database/prisma.service';
import { AdminComplaintsQueryDto } from './dto/admin-complaints-query.dto';
import { UpdateComplaintStatusDto } from './dto/update-complaint-status.dto';

const adminComplaintSelect = {
  id: true,
  reason: true,
  message: true,
  status: true,
  createdAt: true,
  updatedAt: true,
  reporter: {
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
  listing: {
    select: {
      id: true,
      type: true,
      status: true,
      title: true,
      contactPhone: true,
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
    },
  },
} satisfies Prisma.ComplaintSelect;

const updatedComplaintStatusSelect = {
  id: true,
  status: true,
  reason: true,
  updatedAt: true,
} satisfies Prisma.ComplaintSelect;

type AdminComplaintItem = Prisma.ComplaintGetPayload<{
  select: typeof adminComplaintSelect;
}>;

type UpdatedComplaintStatusItem = Prisma.ComplaintGetPayload<{
  select: typeof updatedComplaintStatusSelect;
}>;

export interface AdminComplaintsResponse
  extends PaginatedResponse<AdminComplaintItem> {}

export interface UpdateComplaintStatusResponse {
  data: UpdatedComplaintStatusItem;
}

@Injectable()
export class AdminComplaintsService {
  constructor(private readonly prisma: PrismaService) {}

  async getComplaints(
    query: AdminComplaintsQueryDto,
  ): Promise<AdminComplaintsResponse> {
    const pagination = getPaginationParams(query.page, query.limit);
    const where = this.buildComplaintWhere(query);

    const [total, complaints] = await this.prisma.$transaction([
      this.prisma.complaint.count({ where }),
      this.prisma.complaint.findMany({
        where,
        select: adminComplaintSelect,
        orderBy: {
          createdAt: 'desc',
        },
        skip: pagination.skip,
        take: pagination.take,
      }),
    ]);

    return {
      data: complaints,
      meta: buildPaginationMeta(pagination.page, pagination.limit, total),
    };
  }

  async updateComplaintStatus(
    id: string,
    dto: UpdateComplaintStatusDto,
  ): Promise<UpdateComplaintStatusResponse> {
    const complaint = await this.prisma.complaint.findUnique({
      where: {
        id,
      },
      select: {
        id: true,
        status: true,
      },
    });

    if (!complaint) {
      throw new NotFoundException('Complaint not found');
    }

    if (
      complaint.status === ComplaintStatus.RESOLVED ||
      complaint.status === ComplaintStatus.REJECTED
    ) {
      throw new BadRequestException('Finalized complaint cannot be updated');
    }

    const updatedComplaint = await this.prisma.complaint.update({
      where: {
        id: complaint.id,
      },
      data: {
        status: dto.status,
      },
      select: updatedComplaintStatusSelect,
    });

    return {
      data: updatedComplaint,
    };
  }

  private buildComplaintWhere(
    query: AdminComplaintsQueryDto,
  ): Prisma.ComplaintWhereInput {
    return {
      status: query.status ?? ComplaintStatus.OPEN,
      ...(query.listingId ? { listingId: query.listingId } : {}),
      ...(query.reporterId ? { reporterId: query.reporterId } : {}),
    };
  }
}
