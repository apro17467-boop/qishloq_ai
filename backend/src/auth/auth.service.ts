import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Profile, User, UserRole } from '@prisma/client';
import { PrismaService } from '../database/prisma.service';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { generateOtpCode, hashOtpCode, isUzbekPhone } from './utils/otp.util';
import { SmsService } from '../sms/sms.service';

export interface RequestOtpResponse {
  message: 'OTP code generated';
  expiresInMinutes: number;
  devCode?: string;
  devOtp?: string;
}

interface JwtPayload {
  sub: string;
  phone: string;
  role: UserRole;
}

type AuthUser = User & {
  profile: Pick<Profile, 'fullName' | 'regionId' | 'address'> | null;
};

type MeUser = User & {
  profile: Pick<Profile, 'fullName' | 'avatarUrl' | 'regionId' | 'address'> | null;
};

export interface VerifyOtpResponse {
  accessToken: string;
  user: {
    id: string;
    phone: string;
    role: UserRole;
    isVerified: boolean;
    profile: {
      fullName: string;
      regionId: string | null;
      address: string | null;
    } | null;
  };
}

export interface MeResponse {
  user: {
    id: string;
    phone: string;
    role: UserRole;
    isVerified: boolean;
    isActive: boolean;
    profile: {
      fullName: string;
      avatarUrl: string | null;
      regionId: string | null;
      address: string | null;
    } | null;
  };
}

@Injectable()
export class AuthService {
  private readonly maxOtpAttempts = 5;

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly smsService: SmsService,
  ) {}

  async requestOtp(dto: RequestOtpDto): Promise<RequestOtpResponse> {
    this.assertUzbekPhone(dto.phone);

    const expiresInMinutes = this.getOtpExpiresMinutes();
    const code = this.getOtpCodeForProvider();
    const codeHash = hashOtpCode(code, this.getOtpSecret());
    const expiresAt = new Date(Date.now() + expiresInMinutes * 60 * 1000);

    await this.prisma.otpCode.create({
      data: {
        phone: dto.phone,
        codeHash,
        expiresAt,
      },
    });

    await this.smsService.sendOtp(dto.phone, code);

    const providerName = (process.env.SMS_PROVIDER ?? 'dev').toLowerCase();
    const isDevProvider = providerName === 'dev';

    return {
      message: 'OTP code generated',
      expiresInMinutes,
      ...(isDevProvider ? { devCode: code, devOtp: code } : {}),
    };
  }

  private getOtpCodeForProvider(): string {
    const provider = (process.env.SMS_PROVIDER ?? 'dev').toLowerCase();
    if (provider === 'dev') {
      return process.env.SMS_DEV_CODE ?? process.env.DEV_OTP_CODE ?? '111111';
    }
    return generateOtpCode();
  }

  async verifyOtp(dto: VerifyOtpDto): Promise<VerifyOtpResponse> {
    this.assertUzbekPhone(dto.phone);
    this.assertAdminRoleAllowed(dto.role);

    if (dto.regionId) {
      await this.assertRegionExists(dto.regionId);
    }

    const now = new Date();
    const otp = await this.prisma.otpCode.findFirst({
      where: {
        phone: dto.phone,
        consumedAt: null,
        expiresAt: {
          gt: now,
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    if (!otp) {
      throw new BadRequestException('OTP code is invalid or expired');
    }

    if (otp.attempts >= this.maxOtpAttempts) {
      throw new HttpException(
        'Too many OTP attempts',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    const codeHash = hashOtpCode(dto.code, this.getOtpSecret());

    if (codeHash !== otp.codeHash) {
      await this.prisma.otpCode.update({
        where: {
          id: otp.id,
        },
        data: {
          attempts: {
            increment: 1,
          },
        },
      });

      throw new BadRequestException('OTP code is invalid or expired');
    }

    const user = await this.prisma.$transaction(async (tx) => {
      await tx.otpCode.update({
        where: {
          id: otp.id,
        },
        data: {
          consumedAt: new Date(),
        },
      });

      const existingUser = await tx.user.findUnique({
        where: {
          phone: dto.phone,
        },
        include: {
          profile: {
            select: {
              fullName: true,
              regionId: true,
              address: true,
            },
          },
        },
      });

      if (!existingUser) {
        const createdUser = await tx.user.create({
          data: {
            phone: dto.phone,
            role: dto.role,
            isVerified: true,
            isActive: true,
            profile: {
              create: {
                fullName: dto.fullName,
                regionId: dto.regionId,
                address: dto.address,
              },
            },
          },
          include: {
            profile: {
              select: {
                fullName: true,
                regionId: true,
                address: true,
              },
            },
          },
        });

        return createdUser;
      }

      const updatedUser = await tx.user.update({
        where: {
          id: existingUser.id,
        },
        data: {
          isVerified: true,
          profile: existingUser.profile
            ? {
                update: {
                  fullName: dto.fullName,
                  ...(dto.regionId !== undefined ? { regionId: dto.regionId } : {}),
                  ...(dto.address !== undefined ? { address: dto.address } : {}),
                },
              }
            : {
                create: {
                  fullName: dto.fullName,
                  regionId: dto.regionId,
                  address: dto.address,
                },
              },
        },
        include: {
          profile: {
            select: {
              fullName: true,
              regionId: true,
              address: true,
            },
          },
        },
      });

      return updatedUser;
    });

    const payload: JwtPayload = {
      sub: user.id,
      phone: user.phone,
      role: user.role,
    };

    return {
      accessToken: await this.jwtService.signAsync(payload),
      user: this.toAuthUserResponse(user),
    };
  }

  async getMe(userId: string): Promise<MeResponse> {
    const user = await this.prisma.user.findUnique({
      where: {
        id: userId,
      },
      include: {
        profile: {
          select: {
            fullName: true,
            avatarUrl: true,
            regionId: true,
            address: true,
          },
        },
      },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('Unauthorized');
    }

    return {
      user: this.toMeUserResponse(user),
    };
  }

  private getOtpSecret(): string {
    return process.env.OTP_SECRET ?? 'change_me_for_otp_hashing';
  }

  private getOtpExpiresMinutes(): number {
    const expiresInMinutes = Number(process.env.OTP_EXPIRES_MINUTES ?? 5);

    return Number.isFinite(expiresInMinutes) && expiresInMinutes > 0
      ? expiresInMinutes
      : 5;
  }

  private isDevelopment(): boolean {
    return process.env.NODE_ENV === 'development';
  }

  private assertUzbekPhone(phone: string): void {
    if (!isUzbekPhone(phone)) {
      throw new BadRequestException('Phone must be in +998XXXXXXXXX format');
    }
  }

  private assertAdminRoleAllowed(role: UserRole): void {
    if (role !== UserRole.ADMIN || this.isDevelopment()) {
      return;
    }

    // TODO: Productionda adminlar alohida seed yoki internal tool orqali yaratiladi.
    throw new BadRequestException('ADMIN role cannot be requested here');
  }

  private async assertRegionExists(regionId: string): Promise<void> {
    const region = await this.prisma.region.findUnique({
      where: {
        id: regionId,
      },
    });

    if (!region) {
      throw new BadRequestException('Region not found');
    }
  }

  private toAuthUserResponse(user: AuthUser): VerifyOtpResponse['user'] {
    return {
      id: user.id,
      phone: user.phone,
      role: user.role,
      isVerified: user.isVerified,
      profile: user.profile
        ? {
            fullName: user.profile.fullName,
            regionId: user.profile.regionId,
            address: user.profile.address,
          }
        : null,
    };
  }

  private toMeUserResponse(user: MeUser): MeResponse['user'] {
    return {
      id: user.id,
      phone: user.phone,
      role: user.role,
      isVerified: user.isVerified,
      isActive: user.isActive,
      profile: user.profile
        ? {
            fullName: user.profile.fullName,
            avatarUrl: user.profile.avatarUrl,
            regionId: user.profile.regionId,
            address: user.profile.address,
          }
        : null,
    };
  }
}
