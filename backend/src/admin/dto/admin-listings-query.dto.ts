import { Transform } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, Max, Min } from 'class-validator';
import { ListingStatus, ListingType } from '@prisma/client';

export class AdminListingsQueryDto {
  @IsOptional()
  @Transform(({ value }) => Number(value))
  @IsInt()
  @Min(1)
  page = 1;

  @IsOptional()
  @Transform(({ value }) => Number(value))
  @IsInt()
  @Min(1)
  @Max(50)
  limit = 20;

  @IsOptional()
  @IsEnum(ListingStatus)
  status = ListingStatus.PENDING;

  @IsOptional()
  @IsEnum(ListingType)
  type?: ListingType;
}
