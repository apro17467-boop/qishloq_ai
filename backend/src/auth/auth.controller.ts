import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import {
  AuthService,
  MeResponse,
  RequestOtpResponse,
  VerifyOtpResponse,
} from './auth.service';
import { CurrentUser } from './decorators/current-user.decorator';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AuthenticatedUser } from './types/authenticated-user.type';

@Controller('auth')
@ApiTags('Auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('request-otp')
  // TODO: Add phone-based OTP rate limiting in production hardening.
  requestOtp(@Body() dto: RequestOtpDto): Promise<RequestOtpResponse> {
    return this.authService.requestOtp(dto);
  }

  @Post('verify-otp')
  verifyOtp(@Body() dto: VerifyOtpDto): Promise<VerifyOtpResponse> {
    return this.authService.verifyOtp(dto);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  getMe(@CurrentUser() user: AuthenticatedUser): Promise<MeResponse> {
    return this.authService.getMe(user.sub);
  }
}
