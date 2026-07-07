import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import {
  AdminComplaintsResponse,
  AdminComplaintsService,
  UpdateComplaintStatusResponse,
} from './admin-complaints.service';
import { AdminComplaintsQueryDto } from './dto/admin-complaints-query.dto';
import { UpdateComplaintStatusDto } from './dto/update-complaint-status.dto';

@Controller('admin/complaints')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@ApiTags('Admin Complaints')
@ApiBearerAuth()
export class AdminComplaintsController {
  constructor(
    private readonly adminComplaintsService: AdminComplaintsService,
  ) {}

  @Get()
  getComplaints(
    @Query() query: AdminComplaintsQueryDto,
  ): Promise<AdminComplaintsResponse> {
    return this.adminComplaintsService.getComplaints(query);
  }

  @Patch(':id/status')
  updateComplaintStatus(
    @Param('id', new ParseUUIDPipe()) id: string,
    @Body() dto: UpdateComplaintStatusDto,
  ): Promise<UpdateComplaintStatusResponse> {
    return this.adminComplaintsService.updateComplaintStatus(id, dto);
  }
}
