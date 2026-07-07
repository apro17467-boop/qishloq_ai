import { ApiPropertyOptional } from '@nestjs/swagger';
import { AiQuestionStatus } from '@prisma/client';
import { Transform } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, IsString, IsUUID, Max, Min } from 'class-validator';

export class AdminAiQuestionsQueryDto {
  @ApiPropertyOptional({
    example: 1,
    minimum: 1,
    default: 1,
  })
  @IsOptional()
  @Transform(({ value }) => Number(value))
  @IsInt()
  @Min(1)
  page = 1;

  @ApiPropertyOptional({
    example: 20,
    minimum: 1,
    maximum: 100,
    default: 20,
  })
  @IsOptional()
  @Transform(({ value }) => Number(value))
  @IsInt()
  @Min(1)
  @Max(100)
  limit = 20;

  @ApiPropertyOptional({
    enum: AiQuestionStatus,
    example: AiQuestionStatus.ANSWERED,
  })
  @IsOptional()
  @IsEnum(AiQuestionStatus)
  status?: AiQuestionStatus;

  @ApiPropertyOptional({
    example: '00000000-0000-0000-0000-000000000000',
  })
  @IsOptional()
  @IsUUID()
  userId?: string;

  @ApiPropertyOptional({
    example: 'pomidor',
  })
  @IsOptional()
  @IsString()
  search?: string;
}
