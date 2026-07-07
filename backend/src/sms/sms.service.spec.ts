import { Test, TestingModule } from '@nestjs/testing';
import { SmsService } from './sms.service';
import { DevSmsProvider } from './providers/dev-sms.provider';
import { GenericHttpSmsProvider } from './providers/generic-http-sms.provider';
import { InternalServerErrorException } from '@nestjs/common';

describe('SmsService', () => {
  let service: SmsService;
  let devProvider: DevSmsProvider;
  let genericProvider: GenericHttpSmsProvider;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SmsService,
        {
          provide: DevSmsProvider,
          useValue: {
            sendOtp: jest.fn(),
          },
        },
        {
          provide: GenericHttpSmsProvider,
          useValue: {
            sendOtp: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<SmsService>(SmsService);
    devProvider = module.get<DevSmsProvider>(DevSmsProvider);
    genericProvider = module.get<GenericHttpSmsProvider>(GenericHttpSmsProvider);
  });

  it('should call DevSmsProvider when SMS_PROVIDER is dev', async () => {
    process.env.SMS_PROVIDER = 'dev';
    await service.sendOtp('+998901234567', '123456');
    expect(devProvider.sendOtp).toHaveBeenCalledWith('+998901234567', '123456');
  });

  it('should call GenericHttpSmsProvider when SMS_PROVIDER is generic', async () => {
    process.env.SMS_PROVIDER = 'generic';
    await service.sendOtp('+998901234567', '123456');
    expect(genericProvider.sendOtp).toHaveBeenCalledWith('+998901234567', '123456');
  });

  it('should call GenericHttpSmsProvider when SMS_PROVIDER is eskiz', async () => {
    process.env.SMS_PROVIDER = 'eskiz';
    await service.sendOtp('+998901234567', '123456');
    expect(genericProvider.sendOtp).toHaveBeenCalledWith('+998901234567', '123456');
  });

  it('should throw error for unknown SMS_PROVIDER', async () => {
    process.env.SMS_PROVIDER = 'unknown_provider';
    await expect(service.sendOtp('+998901234567', '123456')).rejects.toThrow(
      InternalServerErrorException,
    );
  });
});
