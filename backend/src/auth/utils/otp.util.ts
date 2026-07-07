import { createHash, randomInt } from 'crypto';

export function generateOtpCode(): string {
  return randomInt(100000, 1000000).toString();
}

export function hashOtpCode(code: string, secret: string): string {
  return createHash('sha256').update(`${code}${secret}`).digest('hex');
}

export function isUzbekPhone(phone: string): boolean {
  return /^\+998\d{9}$/.test(phone);
}
