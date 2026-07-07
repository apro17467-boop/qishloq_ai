import {
  BadRequestException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { ComplaintStatus, ListingStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma.service';
import { CreateComplaintDto } from './dto/create-complaint.dto';

const complaintSelect = {
  id: true,
  listingId: true,
  reason: true,
  message: true,
  status: true,
  createdAt: true,
} satisfies Prisma.ComplaintSelect;

type ComplaintItem = Prisma.ComplaintGetPayload<{
  select: typeof complaintSelect;
}>;

export interface CreateComplaintResponse {
  data: ComplaintItem;
}

@Injectable()
export class ComplaintsService {
  constructor(private readonly prisma: PrismaService) {}

  async createComplaint(
    userId: string,
    dto: CreateComplaintDto,
  ): Promise<CreateComplaintResponse> {
    await this.assertActiveUser(userId);

    const listing = await this.prisma.listing.findFirst({
      where: {
        id: dto.listingId,
        deletedAt: null,
      },
      select: {
        id: true,
        ownerId: true,
        status: true,
      },
    });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }

    if (listing.status === ListingStatus.ARCHIVED) {
      throw new BadRequestException('Archived listing cannot be reported');
    }

    if (listing.ownerId === userId) {
      throw new BadRequestException('Users cannot report their own listing');
    }

    const existingComplaint = await this.prisma.complaint.findFirst({
      where: {
        reporterId: userId,
        listingId: listing.id,
        status: {
          in: [ComplaintStatus.OPEN, ComplaintStatus.IN_REVIEW],
        },
      },
      select: {
        id: true,
      },
    });

    if (existingComplaint) {
      throw new BadRequestException(
        'An open complaint already exists for this listing',
      );
    }

    const complaint = await this.prisma.complaint.create({
      data: {
        reporterId: userId,
        listingId: listing.id,
        reason: dto.reason,
        message: dto.message,
        status: ComplaintStatus.OPEN,
      },
      select: complaintSelect,
    });

    return {
      data: complaint,
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
}
