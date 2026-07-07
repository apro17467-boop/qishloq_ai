import { ApiProperty } from '@nestjs/swagger';
import { ListingStatus } from '@prisma/client';
import { IsIn, IsNotEmpty } from 'class-validator';

export class ModerateListingDto {
  @ApiProperty({
    enum: [ListingStatus.ACTIVE, ListingStatus.REJECTED],
    example: ListingStatus.ACTIVE,
  })
  @IsNotEmpty()
  @IsIn([ListingStatus.ACTIVE, ListingStatus.REJECTED])
  status: ListingStatus;
}
