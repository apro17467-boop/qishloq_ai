import {
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { AiQuestionStatus, UserRole } from '@prisma/client';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import {
  AdminAiQuestionDetailResponse,
  AdminAiQuestionsResponse,
  AdminAiQuestionsService,
} from './admin-ai-questions.service';
import { AdminAiQuestionsQueryDto } from './dto/admin-ai-questions-query.dto';

@Controller('admin/ai-questions')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@ApiTags('Admin AI Questions')
@ApiBearerAuth()
export class AdminAiQuestionsController {
  constructor(
    private readonly adminAiQuestionsService: AdminAiQuestionsService,
  ) {}

  @Get()
  @ApiOperation({
    summary: 'List AI questions for admin monitoring',
  })
  @ApiQuery({
    name: 'page',
    required: false,
    type: Number,
    example: 1,
    description: 'Positive page number. Minimum: 1.',
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    example: 20,
    description: 'Page size. Minimum: 1, maximum: 100.',
  })
  @ApiQuery({ name: 'status', required: false, enum: AiQuestionStatus })
  @ApiQuery({
    name: 'userId',
    required: false,
    example: '00000000-0000-0000-0000-000000000000',
  })
  @ApiQuery({ name: 'search', required: false, example: 'pomidor' })
  getQuestions(
    @Query() query: AdminAiQuestionsQueryDto,
  ): Promise<AdminAiQuestionsResponse> {
    return this.adminAiQuestionsService.getQuestions(query);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get one AI question for admin monitoring',
  })
  getQuestionById(
    @Param('id', new ParseUUIDPipe()) id: string,
  ): Promise<AdminAiQuestionDetailResponse> {
    return this.adminAiQuestionsService.getQuestionById(id);
  }
}
