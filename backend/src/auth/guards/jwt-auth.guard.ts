import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { AuthenticatedUser } from '../types/authenticated-user.type';

interface RequestWithUser {
  headers: {
    authorization?: string;
  };
  user?: AuthenticatedUser;
}

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<RequestWithUser>();
    const token = this.extractBearerToken(request.headers.authorization);

    if (!token) {
      throw new UnauthorizedException('Unauthorized');
    }

    try {
      const payload = await this.jwtService.verifyAsync<AuthenticatedUser>(
        token,
        {
          secret: process.env.JWT_SECRET ?? 'change_me_in_local_development',
        },
      );

      if (!payload.sub || !payload.phone || !payload.role) {
        throw new UnauthorizedException('Unauthorized');
      }

      request.user = {
        sub: payload.sub,
        phone: payload.phone,
        role: payload.role,
      };

      return true;
    } catch {
      throw new UnauthorizedException('Unauthorized');
    }
  }

  private extractBearerToken(authorization?: string): string | null {
    if (!authorization) {
      return null;
    }

    const [type, token] = authorization.split(' ');

    if (type !== 'Bearer' || !token) {
      return null;
    }

    return token;
  }
}
