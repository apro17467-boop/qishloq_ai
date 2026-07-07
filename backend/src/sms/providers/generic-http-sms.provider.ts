import {
  Injectable,
  InternalServerErrorException,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import { SmsProvider } from '../sms-provider.interface';

interface GenericSmsConfig {
  apiUrl: string;
  token?: string;
  login?: string;
  password?: string;
  from: string;
  timeoutMs: number;
  messageTemplate: string;
}

@Injectable()
export class GenericHttpSmsProvider implements SmsProvider {
  private readonly logger = new Logger(GenericHttpSmsProvider.name);

  async sendOtp(phone: string, code: string): Promise<void> {
    const config = this.getConfig();
    const message = this.buildMessage(config.messageTemplate, code);
    let timeout: NodeJS.Timeout | undefined;

    try {
      const controller = new AbortController();
      timeout = setTimeout(() => controller.abort(), config.timeoutMs);

      const body = {
        to: phone,
        message,
        from: config.from,
      };

      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
      };

      if (config.token) {
        headers.Authorization = `Bearer ${config.token}`;
      } else {
        headers.Authorization = `Basic ${Buffer.from(
          `${config.login}:${config.password}`,
        ).toString('base64')}`;
      }

      const response = await fetch(config.apiUrl, {
        method: 'POST',
        headers,
        body: JSON.stringify(body),
        signal: controller.signal,
      });

      if (!response.ok) {
        this.logger.error(
          `SMS provider request failed with status ${response.status}`,
        );
        throw new InternalServerErrorException('SMS delivery failed');
      }

      this.logger.log(`OTP SMS sent to ${this.maskPhone(phone)}`);
    } catch (error) {
      if (
        error instanceof InternalServerErrorException &&
        error.message === 'SMS delivery failed'
      ) {
        throw error;
      }

      const isAbortError =
        error instanceof Error && error.name === 'AbortError';
      this.logger.error(
        isAbortError
          ? 'SMS provider request timed out'
          : 'SMS provider request failed',
      );
      throw new InternalServerErrorException('SMS delivery failed');
    } finally {
      if (timeout) {
        clearTimeout(timeout);
      }
    }
  }

  private getConfig(): GenericSmsConfig {
    const apiUrl = process.env.SMS_API_BASE_URL?.trim();
    const token = process.env.SMS_API_TOKEN?.trim();
    const login = process.env.SMS_API_LOGIN?.trim();
    const password = process.env.SMS_API_PASSWORD?.trim();
    const from = process.env.SMS_FROM?.trim();
    const timeoutMs = this.getTimeoutMs();
    const messageTemplate =
      process.env.SMS_MESSAGE_TEMPLATE?.trim() ??
      'QISHLOQ AI tasdiqlash kodi: {{code}}';

    if (!apiUrl || !from || (!token && (!login || !password))) {
      throw new ServiceUnavailableException('SMS provider is not configured');
    }

    return {
      apiUrl,
      token,
      login,
      password,
      from,
      timeoutMs,
      messageTemplate,
    };
  }

  private getTimeoutMs(): number {
    const timeoutMs = Number(process.env.SMS_TIMEOUT_MS ?? 10000);

    return Number.isFinite(timeoutMs) && timeoutMs > 0 ? timeoutMs : 10000;
  }

  private buildMessage(template: string, code: string): string {
    return template.includes('{{code}}')
      ? template.replace(/{{code}}/g, code)
      : `${template} ${code}`;
  }

  private maskPhone(phone: string): string {
    return phone.length > 4 ? `${phone.slice(0, 4)}***${phone.slice(-2)}` : '***';
  }
}
