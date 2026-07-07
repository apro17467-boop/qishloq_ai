import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { DevSmsProvider } from './providers/dev-sms.provider';
import { GenericHttpSmsProvider } from './providers/generic-http-sms.provider';

@Injectable()
export class SmsService {
  constructor(
    private readonly devSmsProvider: DevSmsProvider,
    private readonly genericHttpSmsProvider: GenericHttpSmsProvider,
  ) {}

  async sendOtp(phone: string, code: string): Promise<void> {
    const providerName = (process.env.SMS_PROVIDER ?? 'dev').toLowerCase();

    if (providerName === 'dev') {
      return this.devSmsProvider.sendOtp(phone, code);
    } else if (providerName === 'generic' || providerName === 'eskiz') {
      return this.genericHttpSmsProvider.sendOtp(phone, code);
    } else {
      throw new InternalServerErrorException(
        `Unknown SMS provider configuration: "${providerName}". Supported values are: dev, generic, eskiz.`,
      );
    }
  }
}
