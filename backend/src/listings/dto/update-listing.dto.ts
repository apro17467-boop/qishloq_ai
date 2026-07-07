import { ApiPropertyOptional } from '@nestjs/swagger';
import { ListingType } from '@prisma/client';
import {
  IsEnum,
  IsIn,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
  MinLength,
  ValidateIf,
} from 'class-validator';

export class UpdateListingDto {
  @ApiPropertyOptional({
    enum: ListingType,
    example: ListingType.PRODUCT_SALE,
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsEnum(ListingType)
  type?: ListingType;

  @ApiPropertyOptional({
    format: 'uuid',
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsUUID()
  categoryId?: string;

  @ApiPropertyOptional({
    format: 'uuid',
    nullable: true,
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsUUID()
  regionId?: string;

  @ApiPropertyOptional({
    example: 'Samarqand pomidori yangilandi',
    minLength: 3,
    maxLength: 120,
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @MinLength(3)
  @MaxLength(120)
  title?: string;

  @ApiPropertyOptional({
    example: 'Narxi va miqdori yangilandi',
    maxLength: 2000,
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @MaxLength(2000)
  description?: string;

  @ApiPropertyOptional({
    example: '4250',
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Matches(/^\d+(\.\d+)?$/)
  priceAmount?: string;

  @ApiPropertyOptional({
    example: 'UZS',
    enum: ['UZS'],
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @IsIn(['UZS'])
  priceCurrency?: string;

  @ApiPropertyOptional({
    example: 'kg',
    maxLength: 30,
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @MaxLength(30)
  unit?: string;

  @ApiPropertyOptional({
    example: '+998900000002',
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @Matches(/^\+998\d{9}$/)
  contactPhone?: string;

  @ApiPropertyOptional({
    example: 'Oqdaryo tumani',
    maxLength: 255,
  })
  @ValidateIf((_, value) => value !== undefined)
  @IsString()
  @MaxLength(255)
  address?: string;
}
