import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, Matches } from 'class-validator';

export class RequestOtpDto {
  @ApiProperty({
    example: '+998900000002',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\+998\d{9}$/)
  phone: string;
}
