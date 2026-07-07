import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { AdminModule } from './admin/admin.module';
import { AiModule } from './ai/ai.module';
import { AuthModule } from './auth/auth.module';
import { ComplaintsModule } from './complaints/complaints.module';
import { getRateLimitConfig } from './config/security.config';
import { PrismaModule } from './database/prisma.module';
import { FavoritesModule } from './favorites/favorites.module';
import { HealthModule } from './health/health.module';
import { ListingsModule } from './listings/listings.module';
import { ReferenceModule } from './reference/reference.module';

@Module({
  imports: [
    ThrottlerModule.forRoot([getRateLimitConfig()]),
    PrismaModule,
    HealthModule,
    ReferenceModule,
    AuthModule,
    ListingsModule,
    AdminModule,
    ComplaintsModule,
    AiModule,
    FavoritesModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
