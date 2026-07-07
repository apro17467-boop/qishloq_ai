import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user.type';
import {
  ComplaintsService,
  CreateComplaintResponse,
} from './complaints.service';
import { CreateComplaintDto } from './dto/create-complaint.dto';

@Controller('complaints')
@ApiTags('Complaints')
@ApiBearerAuth()
export class ComplaintsController {
  constructor(private readonly complaintsService: ComplaintsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  createComplaint(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateComplaintDto,
  ): Promise<CreateComplaintResponse> {
    return this.complaintsService.createComplaint(user.sub, dto);
  }
}
