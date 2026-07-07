import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../database/prisma.service';
import { SmsService } from '../sms/sms.service';
import { AuthService } from './auth.service';

describe('AuthService requestOtp', () => {
  const originalEnv = process.env;

  function createService() {
    const prisma = {
      otpCode: {
        create: jest.fn().mockResolvedValue({ id: 'otp-1' }),
      },
    };
    const jwtService = {
      signAsync: jest.fn(),
    };
    const smsService = {
      sendOtp: jest.fn().mockResolvedValue(undefined),
    };

    return {
      prisma,
      smsService,
      service: new AuthService(
        prisma as unknown as PrismaService,
        jwtService as unknown as JwtService,
        smsService as unknown as SmsService,
      ),
    };
  }

  beforeEach(() => {
    jest.resetModules();
    process.env = {
      ...originalEnv,
      OTP_SECRET: 'test-otp-secret',
      OTP_EXPIRES_MINUTES: '5',
    };
  });

  afterEach(() => {
    process.env = originalEnv;
  });

  it('returns devOtp and devCode in dev provider mode', async () => {
    process.env.SMS_PROVIDER = 'dev';
    process.env.SMS_DEV_CODE = '111111';
    const { prisma, smsService, service } = createService();

    await expect(
      service.requestOtp({ phone: '+998901234567' }),
    ).resolves.toMatchObject({
      message: 'OTP code generated',
      expiresInMinutes: 5,
      devCode: '111111',
      devOtp: '111111',
    });

    expect(prisma.otpCode.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          phone: '+998901234567',
          codeHash: expect.any(String),
          expiresAt: expect.any(Date),
        }),
      }),
    );
    expect(smsService.sendOtp).toHaveBeenCalledWith(
      '+998901234567',
      '111111',
    );
  });

  it('does not return OTP code in generic provider mode', async () => {
    process.env.SMS_PROVIDER = 'generic';
    const { smsService, service } = createService();

    const response = await service.requestOtp({ phone: '+998901234567' });

    expect(response).toEqual({
      message: 'OTP code generated',
      expiresInMinutes: 5,
    });
    expect(response.devCode).toBeUndefined();
    expect(response.devOtp).toBeUndefined();
    expect(smsService.sendOtp).toHaveBeenCalledWith(
      '+998901234567',
      expect.stringMatching(/^\d{6}$/),
    );
  });
});
