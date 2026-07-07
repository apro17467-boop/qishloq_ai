import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import {
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  MinLength,
} from 'class-validator';

export class VerifyOtpDto {
  @ApiProperty({
    example: '+998900000002',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\+998\d{9}$/)
  phone: string;

  @ApiProperty({
    example: '111111',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\d{6}$/)
  code: string;

  @ApiProperty({
    enum: UserRole,
    example: UserRole.FARMER,
  })
  @IsEnum(UserRole)
  role: UserRole;

  @ApiProperty({
    example: 'Ali Valiyev',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  fullName: string;

  @ApiPropertyOptional({
    format: 'uuid',
    nullable: true,
  })
  @IsOptional()
  @IsUUID()
  regionId?: string;

  @ApiPropertyOptional({
    example: 'Oqdaryo tumani',
  })
  @IsOptional()
  @IsString()
  address?: string;
}
