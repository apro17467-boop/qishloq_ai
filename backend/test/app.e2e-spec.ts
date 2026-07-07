import {
  Body,
  Controller,
  INestApplication,
  Post,
  ValidationPipe,
} from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request = require('supertest');
import { HttpExceptionFilter } from '../src/common/filters/http-exception.filter';
import { RequestOtpDto } from '../src/auth/dto/request-otp.dto';
import { HealthModule } from '../src/health/health.module';

@Controller('auth')
class TestAuthController {
  @Post('request-otp')
  requestOtp(@Body() _dto: RequestOtpDto): { message: string } {
    return {
      message: 'OTP code generated',
    };
  }
}

describe('App e2e', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [HealthModule],
      controllers: [TestAuthController],
    }).compile();

    app = moduleRef.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    app.useGlobalFilters(new HttpExceptionFilter());

    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /health returns service status', async () => {
    await request(app.getHttpServer())
      .get('/health')
      .expect(200)
      .expect({
        status: 'ok',
        service: 'qishloq-ai-backend',
      });
  });

  it('POST /auth/request-otp returns standardized validation error', async () => {
    const response = await request(app.getHttpServer())
      .post('/auth/request-otp')
      .send({
        phone: '123',
      })
      .expect(400);

    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
    expect(Array.isArray(response.body.error.details)).toBe(true);
  });
});
