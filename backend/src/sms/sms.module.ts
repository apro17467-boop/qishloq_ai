import { Module } from '@nestjs/common';
import { SmsService } from './sms.service';
import { DevSmsProvider } from './providers/dev-sms.provider';
import { GenericHttpSmsProvider } from './providers/generic-http-sms.provider';

@Module({
  providers: [
    SmsService,
    DevSmsProvider,
    GenericHttpSmsProvider,
  ],
  exports: [SmsService],
})
export class SmsModule {}
