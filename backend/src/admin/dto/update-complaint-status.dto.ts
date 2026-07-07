import { ApiProperty } from '@nestjs/swagger';
import { ComplaintStatus } from '@prisma/client';
import { IsIn, IsNotEmpty } from 'class-validator';

export class UpdateComplaintStatusDto {
  @ApiProperty({
    enum: [
      ComplaintStatus.IN_REVIEW,
      ComplaintStatus.RESOLVED,
      ComplaintStatus.REJECTED,
    ],
    example: ComplaintStatus.IN_REVIEW,
  })
  @IsNotEmpty()
  @IsIn([
    ComplaintStatus.IN_REVIEW,
    ComplaintStatus.RESOLVED,
    ComplaintStatus.REJECTED,
  ])
  status: ComplaintStatus;
}
