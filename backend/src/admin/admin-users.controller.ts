import {
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import {
  AdminUserDetailResponse,
  AdminUsersResponse,
  AdminUsersService,
} from './admin-users.service';
import { AdminUsersQueryDto } from './dto/admin-users-query.dto';

@Controller('admin/users')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@ApiTags('Admin Users')
@ApiBearerAuth()
export class AdminUsersController {
  constructor(private readonly adminUsersService: AdminUsersService) {}

  @Get()
  getUsers(@Query() query: AdminUsersQueryDto): Promise<AdminUsersResponse> {
    return this.adminUsersService.getUsers(query);
  }

  @Get(':id')
  getUserById(
    @Param('id', new ParseUUIDPipe()) id: string,
  ): Promise<AdminUserDetailResponse> {
    return this.adminUsersService.getUserById(id);
  }
}
