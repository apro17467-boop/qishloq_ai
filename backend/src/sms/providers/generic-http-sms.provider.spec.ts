import { Test, TestingModule } from '@nestjs/testing';
import { GenericHttpSmsProvider } from './generic-http-sms.provider';
import {
  InternalServerErrorException,
  ServiceUnavailableException,
} from '@nestjs/common';

describe('GenericHttpSmsProvider', () => {
  let provider: GenericHttpSmsProvider;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [GenericHttpSmsProvider],
    }).compile();

    provider = module.get<GenericHttpSmsProvider>(GenericHttpSmsProvider);
  });

  afterEach(() => {
    delete process.env.SMS_API_BASE_URL;
    delete process.env.SMS_API_TOKEN;
    delete process.env.SMS_API_LOGIN;
    delete process.env.SMS_API_PASSWORD;
    delete process.env.SMS_FROM;
    delete process.env.SMS_TIMEOUT_MS;
    delete process.env.SMS_MESSAGE_TEMPLATE;
    jest.restoreAllMocks();
  });

  it('should throw exception if SMS_API_BASE_URL is not set', async () => {
    process.env.SMS_FROM = 'QISHLOQAI';
    process.env.SMS_API_TOKEN = 'provider-token';

    await expect(provider.sendOtp('+998901234567', '123456')).rejects.toThrow(
      ServiceUnavailableException,
    );
  });

  it('should throw exception if no token or login credentials are set', async () => {
    process.env.SMS_API_BASE_URL = 'http://sms-gateway.example.com';
    process.env.SMS_FROM = 'QISHLOQAI';

    await expect(provider.sendOtp('+998901234567', '123456')).rejects.toThrow(
      'SMS provider is not configured',
    );
  });

  it('should replace code in message template and send exact configured URL', async () => {
    process.env.SMS_API_BASE_URL = 'https://sms-provider.example/api/send';
    process.env.SMS_API_TOKEN = 'provider-token';
    process.env.SMS_FROM = 'QISHLOQAI';
    process.env.SMS_TIMEOUT_MS = '15000';
    process.env.SMS_MESSAGE_TEMPLATE = 'QISHLOQ AI tasdiqlash kodi: {{code}}';

    const fetchMock = jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: true,
      status: 200,
    } as Response);

    await provider.sendOtp('+998901234567', '123456');

    expect(fetchMock).toHaveBeenCalledWith(
      'https://sms-provider.example/api/send',
      expect.objectContaining({
        method: 'POST',
        headers: expect.objectContaining({
          Authorization: 'Bearer provider-token',
          'Content-Type': 'application/json',
        }),
        body: JSON.stringify({
          to: '+998901234567',
          message: 'QISHLOQ AI tasdiqlash kodi: 123456',
          from: 'QISHLOQAI',
        }),
      }),
    );
  });

  it('should use basic auth when login and password are configured', async () => {
    process.env.SMS_API_BASE_URL = 'https://sms-provider.example/api/send';
    process.env.SMS_API_LOGIN = 'provider-login';
    process.env.SMS_API_PASSWORD = 'provider-password';
    process.env.SMS_FROM = 'QISHLOQAI';

    const fetchMock = jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: true,
      status: 200,
    } as Response);

    await provider.sendOtp('+998901234567', '123456');

    expect(fetchMock).toHaveBeenCalledWith(
      expect.any(String),
      expect.objectContaining({
        headers: expect.objectContaining({
          Authorization: `Basic ${Buffer.from(
            'provider-login:provider-password',
          ).toString('base64')}`,
        }),
      }),
    );
  });

  it('should throw safe error on non-2xx provider response', async () => {
    process.env.SMS_API_BASE_URL = 'https://sms-provider.example/api/send';
    process.env.SMS_API_TOKEN = 'provider-token';
    process.env.SMS_FROM = 'QISHLOQAI';

    jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: false,
      status: 500,
    } as Response);

    await expect(provider.sendOtp('+998901234567', '123456')).rejects.toThrow(
      'SMS delivery failed',
    );
  });
});
