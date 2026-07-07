import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsNotEmpty, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

export const complaintReasons = [
  'FRAUD',
  'WRONG_INFO',
  'SOLD_ALREADY',
  'SPAM',
  'PROHIBITED_ITEM',
  'OTHER',
] as const;

export type ComplaintReason = (typeof complaintReasons)[number];

export class CreateComplaintDto {
  @ApiProperty({
    format: 'uuid',
  })
  @IsUUID()
  listingId: string;

  @ApiProperty({
    enum: complaintReasons,
    example: 'WRONG_INFO',
  })
  @IsString()
  @IsNotEmpty()
  @IsIn(complaintReasons)
  reason: ComplaintReason;

  @ApiPropertyOptional({
    example: "E'lon ma'lumotlari noto'g'ri",
    maxLength: 1000,
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  message?: string;
}
