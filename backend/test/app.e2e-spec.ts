import {
  Body,
  Controller,
  Get,
  INestApplication,
  Post,
  UseGuards,
  ValidationPipe,
} from '@nestjs/common';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { Test } from '@nestjs/testing';
import { UserRole } from '@prisma/client';
import request = require('supertest');
import { Roles } from '../src/auth/decorators/roles.decorator';
import { RequestOtpDto } from '../src/auth/dto/request-otp.dto';
import { JwtAuthGuard } from '../src/auth/guards/jwt-auth.guard';
import { RolesGuard } from '../src/auth/guards/roles.guard';
import { HttpExceptionFilter } from '../src/common/filters/http-exception.filter';
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

@Controller('admin/ai-questions')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
class TestAdminAiQuestionsController {
  @Get()
  getQuestions(): {
    data: [];
    meta: { page: number; limit: number; total: number; totalPages: number };
  } {
    return {
      data: [],
      meta: {
        page: 1,
        limit: 20,
        total: 0,
        totalPages: 0,
      },
    };
  }
}

describe('App e2e', () => {
  let app: INestApplication;
  let jwtService: JwtService;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [HealthModule, JwtModule.register({})],
      controllers: [TestAuthController, TestAdminAiQuestionsController],
      providers: [JwtAuthGuard, RolesGuard],
    }).compile();

    jwtService = moduleRef.get(JwtService);
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

  it('GET /admin/ai-questions returns 401 without token', async () => {
    const response = await request(app.getHttpServer())
      .get('/admin/ai-questions')
      .expect(401);

    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe('UNAUTHORIZED');
  });

  it('GET /admin/ai-questions returns 403 for non-admin token', async () => {
    const token = await signTestToken(UserRole.FARMER);

    const response = await request(app.getHttpServer())
      .get('/admin/ai-questions')
      .set('Authorization', `Bearer ${token}`)
      .expect(403);

    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe('FORBIDDEN');
  });

  it('GET /admin/ai-questions returns 200 for admin token', async () => {
    const token = await signTestToken(UserRole.ADMIN);

    await request(app.getHttpServer())
      .get('/admin/ai-questions')
      .set('Authorization', `Bearer ${token}`)
      .expect(200)
      .expect({
        data: [],
        meta: {
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 0,
        },
      });
  });

  function signTestToken(role: UserRole): Promise<string> {
    return jwtService.signAsync(
      {
        sub: '00000000-0000-0000-0000-000000000001',
        phone: '+998900000001',
        role,
      },
      {
        secret: process.env.JWT_SECRET ?? 'change_me_in_local_development',
      },
    );
  }
});
