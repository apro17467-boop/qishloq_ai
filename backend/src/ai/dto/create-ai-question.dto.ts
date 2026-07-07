import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MaxLength, MinLength } from 'class-validator';

export class CreateAiQuestionDto {
  @ApiProperty({
    example: "Pomidor bargi sarg'aymoqda, nima qilish kerak?",
    minLength: 10,
    maxLength: 3000,
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(10)
  @MaxLength(3000)
  question: string;
}
