import { Test, TestingModule } from '@nestjs/testing';
import { GenericHttpSmsProvider } from './generic-http-sms.provider';
import { InternalServerErrorException } from '@nestjs/common';

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
  });

  it('should throw exception if SMS_API_BASE_URL is not set', async () => {
    await expect(provider.sendOtp('+998901234567', '123456')).rejects.toThrow(
      InternalServerErrorException,
    );
  });

  it('should throw exception if no token or login credentials are set', async () => {
    process.env.SMS_API_BASE_URL = 'http://sms-gateway.example.com';
    await expect(provider.sendOtp('+998901234567', '123456')).rejects.toThrow(
      InternalServerErrorException,
    );
  });
});
