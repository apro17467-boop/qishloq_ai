import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PaginatedResponse } from '../common/pagination/pagination.types';
import {
  buildPaginationMeta,
  getPaginationParams,
} from '../common/pagination/pagination.util';
import { PrismaService } from '../database/prisma.service';
import { AdminAiQuestionsQueryDto } from './dto/admin-ai-questions-query.dto';

const adminAiQuestionSelect = {
  id: true,
  question: true,
  answer: true,
  status: true,
  disclaimerShown: true,
  createdAt: true,
  updatedAt: true,
  user: {
    select: {
      id: true,
      phone: true,
      role: true,
      profile: {
        select: {
          fullName: true,
          address: true,
        },
      },
    },
  },
} satisfies Prisma.AiQuestionSelect;

type AdminAiQuestionItem = Prisma.AiQuestionGetPayload<{
  select: typeof adminAiQuestionSelect;
}>;

export interface AdminAiQuestionsResponse
  extends PaginatedResponse<AdminAiQuestionItem> {}

export interface AdminAiQuestionDetailResponse {
  data: AdminAiQuestionItem;
}

@Injectable()
export class AdminAiQuestionsService {
  constructor(private readonly prisma: PrismaService) {}

  async getQuestions(
    query: AdminAiQuestionsQueryDto,
  ): Promise<AdminAiQuestionsResponse> {
    const pagination = getPaginationParams(query.page, query.limit, {
      maxLimit: 100,
    });
    const where = this.buildAiQuestionWhere(query);

    const [total, questions] = await this.prisma.$transaction([
      this.prisma.aiQuestion.count({ where }),
      this.prisma.aiQuestion.findMany({
        where,
        select: adminAiQuestionSelect,
        orderBy: {
          createdAt: 'desc',
        },
        skip: pagination.skip,
        take: pagination.take,
      }),
    ]);

    return {
      data: questions,
      meta: buildPaginationMeta(pagination.page, pagination.limit, total),
    };
  }

  async getQuestionById(id: string): Promise<AdminAiQuestionDetailResponse> {
    const question = await this.prisma.aiQuestion.findUnique({
      where: {
        id,
      },
      select: adminAiQuestionSelect,
    });

    if (!question) {
      throw new NotFoundException('AI question not found');
    }

    return {
      data: question,
    };
  }

  private buildAiQuestionWhere(
    query: AdminAiQuestionsQueryDto,
  ): Prisma.AiQuestionWhereInput {
    const search = query.search?.trim();

    return {
      ...(query.status ? { status: query.status } : {}),
      ...(query.userId ? { userId: query.userId } : {}),
      ...(search
        ? {
            OR: [
              {
                question: {
                  contains: search,
                  mode: 'insensitive',
                },
              },
              {
                answer: {
                  contains: search,
                  mode: 'insensitive',
                },
              },
            ],
          }
        : {}),
    };
  }
}
