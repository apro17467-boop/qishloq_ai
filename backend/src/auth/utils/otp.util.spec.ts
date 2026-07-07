import { generateOtpCode, hashOtpCode, isUzbekPhone } from './otp.util';

describe('otp util', () => {
  describe('isUzbekPhone', () => {
    it('returns true for valid Uzbek phone', () => {
      expect(isUzbekPhone('+998901234567')).toBe(true);
    });

    it('returns false for invalid phone', () => {
      expect(isUzbekPhone('901234567')).toBe(false);
      expect(isUzbekPhone('+99890123456')).toBe(false);
      expect(isUzbekPhone('+997901234567')).toBe(false);
    });
  });

  describe('generateOtpCode', () => {
    it('returns a six digit string', () => {
      expect(generateOtpCode()).toMatch(/^\d{6}$/);
    });
  });

  describe('hashOtpCode', () => {
    it('returns the same hash for the same code and secret', () => {
      const firstHash = hashOtpCode('111111', 'secret');
      const secondHash = hashOtpCode('111111', 'secret');

      expect(firstHash).toBe(secondHash);
    });

    it('returns a different hash for a different secret', () => {
      const firstHash = hashOtpCode('111111', 'secret');
      const secondHash = hashOtpCode('111111', 'another-secret');

      expect(firstHash).not.toBe(secondHash);
    });
  });
});
