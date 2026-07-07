import { Inject, Injectable, UnauthorizedException } from '@nestjs/common';
import { AiQuestionStatus, Prisma } from '@prisma/client';
import { PaginatedResponse } from '../common/pagination/pagination.types';
import {
  buildPaginationMeta,
  getPaginationParams,
} from '../common/pagination/pagination.util';
import { PrismaService } from '../database/prisma.service';
import { CreateAiQuestionDto } from './dto/create-ai-question.dto';
import { MyAiQuestionsQueryDto } from './dto/my-ai-questions-query.dto';
import { AI_PROVIDER, AiProvider } from './providers/ai-provider.interface';

const createdAiQuestionSelect = {
  id: true,
  question: true,
  answer: true,
  status: true,
  disclaimerShown: true,
  createdAt: true,
  updatedAt: true,
} satisfies Prisma.AiQuestionSelect;

const myAiQuestionSelect = {
  id: true,
  question: true,
  answer: true,
  status: true,
  disclaimerShown: true,
  createdAt: true,
  updatedAt: true,
} satisfies Prisma.AiQuestionSelect;

type CreatedAiQuestionItem = Prisma.AiQuestionGetPayload<{
  select: typeof createdAiQuestionSelect;
}>;

type MyAiQuestionItem = Prisma.AiQuestionGetPayload<{
  select: typeof myAiQuestionSelect;
}>;

export interface CreateAiQuestionResponse {
  data: CreatedAiQuestionItem;
  message:
    | 'Question answered by local AI provider'
    | 'Question answer generation failed';
}

export interface MyAiQuestionsResponse
  extends PaginatedResponse<MyAiQuestionItem> {}

@Injectable()
export class AiService {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(AI_PROVIDER) private readonly aiProvider: AiProvider,
  ) {}

  async createQuestion(
    userId: string,
    dto: CreateAiQuestionDto,
  ): Promise<CreateAiQuestionResponse> {
    await this.assertActiveUser(userId);

    const question = await this.prisma.aiQuestion.create({
      data: {
        userId,
        question: dto.question,
        answer: null,
        status: AiQuestionStatus.PENDING,
        disclaimerShown: true,
      },
      select: createdAiQuestionSelect,
    });

    try {
      // TODO: replace LocalAiProvider with real AI provider integration in production.
      const answer = await this.aiProvider.generateAnswer(dto.question);
      const answeredQuestion = await this.prisma.aiQuestion.update({
        where: {
          id: question.id,
        },
        data: {
          answer,
          status: AiQuestionStatus.ANSWERED,
        },
        select: createdAiQuestionSelect,
      });

      return {
        data: answeredQuestion,
        message: 'Question answered by local AI provider',
      };
    } catch {
      const failedQuestion = await this.prisma.aiQuestion.update({
        where: {
          id: question.id,
        },
        data: {
          answer: null,
          status: AiQuestionStatus.FAILED,
        },
        select: createdAiQuestionSelect,
      });

      return {
        data: failedQuestion,
        message: 'Question answer generation failed',
      };
    }
  }

  async getMyQuestions(
    userId: string,
    query: MyAiQuestionsQueryDto,
  ): Promise<MyAiQuestionsResponse> {
    await this.assertActiveUser(userId);

    const pagination = getPaginationParams(query.page, query.limit);
    const where = this.buildMyQuestionsWhere(userId, query);

    const [total, questions] = await this.prisma.$transaction([
      this.prisma.aiQuestion.count({ where }),
      this.prisma.aiQuestion.findMany({
        where,
        select: myAiQuestionSelect,
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

  private buildMyQuestionsWhere(
    userId: string,
    query: MyAiQuestionsQueryDto,
  ): Prisma.AiQuestionWhereInput {
    return {
      userId,
      ...(query.status ? { status: query.status } : {}),
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
