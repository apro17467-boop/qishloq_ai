import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { AiController } from './ai.controller';
import { AiService } from './ai.service';
import { AI_PROVIDER } from './providers/ai-provider.interface';
import { LocalAiProvider } from './providers/local-ai.provider';

@Module({
  imports: [AuthModule],
  controllers: [AiController],
  providers: [
    AiService,
    LocalAiProvider,
    {
      provide: AI_PROVIDER,
      useExisting: LocalAiProvider,
    },
  ],
})
export class AiModule {}
