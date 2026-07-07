import { Injectable, Logger, InternalServerErrorException } from '@nestjs/common';
import { SmsProvider } from '../sms-provider.interface';

@Injectable()
export class GenericHttpSmsProvider implements SmsProvider {
  private readonly logger = new Logger(GenericHttpSmsProvider.name);

  async sendOtp(phone: string, code: string): Promise<void> {
    const baseUrl = process.env.SMS_API_BASE_URL;
    const token = process.env.SMS_API_TOKEN;
    const login = process.env.SMS_API_LOGIN;
    const password = process.env.SMS_API_PASSWORD;
    const from = process.env.SMS_FROM ?? 'QISHLOQAI';
    const timeoutMs = Number(process.env.SMS_TIMEOUT_MS ?? 10000);

    // Validate config before trying to send
    if (!baseUrl) {
      throw new InternalServerErrorException('SMS provider configuration error: SMS_API_BASE_URL is not set.');
    }

    if (!token && (!login || !password)) {
      throw new InternalServerErrorException(
        'SMS provider configuration error: Either SMS_API_TOKEN or both SMS_API_LOGIN and SMS_API_PASSWORD must be configured.',
      );
    }

    this.logger.log(`[GenericHttpSmsProvider] Initiating OTP send to ${phone} using provider at ${baseUrl}`);

    try {
      const controller = new AbortController();
      const id = setTimeout(() => controller.abort(), timeoutMs);

      // Example body format for sending SMS:
      const body = {
        mobile_phone: phone.replace('+', ''), // standard format e.g. 998901234567
        message: `QISHLOQ AI: Tasdiqlash kodi: ${code}`,
        from,
      };

      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
      };

      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      } else {
        headers['Authorization'] = `Basic ${Buffer.from(`${login}:${password}`).toString('base64')}`;
      }

      const response = await fetch(`${baseUrl.replace(/\/$/, '')}/send`, {
        method: 'POST',
        headers,
        body: JSON.stringify(body),
        signal: controller.signal,
      });

      clearTimeout(id);

      if (!response.ok) {
        const responseText = await response.text().catch(() => '');
        this.logger.error(`SMS send request failed with status ${response.status}: ${responseText}`);
        throw new InternalServerErrorException(`SMS delivery failed with status ${response.status}`);
      }

      this.logger.log(`[GenericHttpSmsProvider] Successfully sent SMS to ${phone}`);
    } catch (error: any) {
      this.logger.error(`[GenericHttpSmsProvider] Error sending SMS: ${error.message}`);
      throw new InternalServerErrorException(`SMS gateway communication error: ${error.message}`);
    }
  }
}
