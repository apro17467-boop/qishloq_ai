import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user.type';
import {
  AiService,
  CreateAiQuestionResponse,
  MyAiQuestionsResponse,
} from './ai.service';
import { CreateAiQuestionDto } from './dto/create-ai-question.dto';
import { MyAiQuestionsQueryDto } from './dto/my-ai-questions-query.dto';

@Controller('ai/questions')
@UseGuards(JwtAuthGuard)
@ApiTags('AI')
@ApiBearerAuth()
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post()
  createQuestion(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateAiQuestionDto,
  ): Promise<CreateAiQuestionResponse> {
    return this.aiService.createQuestion(user.sub, dto);
  }

  @Get('my')
  getMyQuestions(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: MyAiQuestionsQueryDto,
  ): Promise<MyAiQuestionsResponse> {
    return this.aiService.getMyQuestions(user.sub, query);
  }
}
