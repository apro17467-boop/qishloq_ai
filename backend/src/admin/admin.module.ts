import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { RolesGuard } from '../auth/guards/roles.guard';
import { AdminAiQuestionsController } from './admin-ai-questions.controller';
import { AdminAiQuestionsService } from './admin-ai-questions.service';
import { AdminComplaintsController } from './admin-complaints.controller';
import { AdminComplaintsService } from './admin-complaints.service';
import { AdminListingsController } from './admin-listings.controller';
import { AdminListingsService } from './admin-listings.service';
import { AdminUsersController } from './admin-users.controller';
import { AdminUsersService } from './admin-users.service';

@Module({
  imports: [AuthModule],
  controllers: [
    AdminListingsController,
    AdminComplaintsController,
    AdminUsersController,
    AdminAiQuestionsController,
  ],
  providers: [
    AdminListingsService,
    AdminComplaintsService,
    AdminUsersService,
    AdminAiQuestionsService,
    RolesGuard,
  ],
})
export class AdminModule {}
