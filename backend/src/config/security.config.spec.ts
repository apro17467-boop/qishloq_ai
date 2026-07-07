import {
  getBodyLimit,
  getCorsOrigins,
  getRateLimitConfig,
} from './security.config';

describe('security config', () => {
  const originalEnv = { ...process.env };

  afterEach(() => {
    process.env = { ...originalEnv };
  });

  it('parses comma-separated CORS_ORIGIN into an array', () => {
    process.env.CORS_ORIGIN =
      'http://localhost:3000, http://localhost:5173';

    expect(getCorsOrigins()).toEqual([
      'http://localhost:3000',
      'http://localhost:5173',
    ]);
  });

  it('returns default rate limit TTL when RATE_LIMIT_TTL is invalid', () => {
    process.env.RATE_LIMIT_TTL = 'invalid';
    process.env.RATE_LIMIT_MAX = '10';

    expect(getRateLimitConfig()).toEqual({
      ttl: 60000,
      limit: 10,
    });
  });

  it('returns default rate limit max when RATE_LIMIT_MAX is invalid', () => {
    process.env.RATE_LIMIT_TTL = '30';
    process.env.RATE_LIMIT_MAX = 'invalid';

    expect(getRateLimitConfig()).toEqual({
      ttl: 30000,
      limit: 100,
    });
  });

  it('returns default body limit when BODY_LIMIT is missing', () => {
    delete process.env.BODY_LIMIT;

    expect(getBodyLimit()).toBe('2mb');
  });
});
