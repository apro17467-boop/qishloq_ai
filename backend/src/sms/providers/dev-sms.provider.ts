import { Injectable, Logger } from '@nestjs/common';
import { SmsProvider } from '../sms-provider.interface';

@Injectable()
export class DevSmsProvider implements SmsProvider {
  private readonly logger = new Logger(DevSmsProvider.name);

  async sendOtp(phone: string, code: string): Promise<void> {
    if (process.env.NODE_ENV !== 'production') {
      this.logger.log(`[DevSmsProvider] Sending OTP Code ${code} to ${phone}`);
    } else {
      this.logger.log(`[DevSmsProvider] Sending OTP to ${phone} (code hidden in production)`);
    }
  }
}
