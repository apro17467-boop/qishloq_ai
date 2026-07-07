import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ListingType } from '@prisma/client';
import {
  IsEnum,
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

export class CreateListingDto {
  @ApiProperty({
    enum: ListingType,
    example: ListingType.PRODUCT_SALE,
  })
  @IsEnum(ListingType)
  type: ListingType;

  @ApiProperty({
    format: 'uuid',
  })
  @IsUUID()
  categoryId: string;

  @ApiPropertyOptional({
    format: 'uuid',
    nullable: true,
  })
  @IsOptional()
  @IsUUID()
  regionId?: string;

  @ApiProperty({
    example: 'Samarqand pomidori',
    minLength: 3,
    maxLength: 120,
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  @MaxLength(120)
  title: string;

  @ApiPropertyOptional({
    example: 'Yangi uzilgan, ulgurji sotiladi',
    maxLength: 2000,
  })
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  description?: string;

  @ApiPropertyOptional({
    example: '4200',
  })
  @IsOptional()
  @IsString()
  @Matches(/^\d+(\.\d+)?$/)
  priceAmount?: string;

  @ApiPropertyOptional({
    example: 'UZS',
    enum: ['UZS'],
  })
  @IsOptional()
  @IsString()
  @IsIn(['UZS'])
  priceCurrency?: string;

  @ApiPropertyOptional({
    example: 'kg',
    maxLength: 30,
  })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  unit?: string;

  @ApiPropertyOptional({
    example: '+998900000002',
  })
  @IsOptional()
  @IsString()
  @Matches(/^\+998\d{9}$/)
  contactPhone?: string;

  @ApiPropertyOptional({
    example: 'Oqdaryo tumani',
    maxLength: 255,
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  address?: string;
}
