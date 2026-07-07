export interface RateLimitConfig {
  ttl: number;
  limit: number;
}

const defaultCorsOrigins = [
  'http://localhost:3000',
  'http://localhost:3001',
  'http://localhost:5173',
];
const defaultRateLimitTtlSeconds = 60;
const defaultRateLimitMax = 100;
const defaultBodyLimit = '2mb';

export function getCorsOrigins(): string[] | boolean {
  const rawOrigins = process.env.CORS_ORIGIN?.trim();

  if (!rawOrigins) {
    return process.env.NODE_ENV === 'production' ? defaultCorsOrigins : true;
  }

  return rawOrigins
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
}

export function getRateLimitConfig(): RateLimitConfig {
  const ttlSeconds = parsePositiveInteger(
    process.env.RATE_LIMIT_TTL,
    defaultRateLimitTtlSeconds,
  );
  const limit = parsePositiveInteger(
    process.env.RATE_LIMIT_MAX,
    defaultRateLimitMax,
  );

  return {
    ttl: ttlSeconds * 1000,
    limit,
  };
}

export function getBodyLimit(): string {
  return process.env.BODY_LIMIT?.trim() || defaultBodyLimit;
}

function parsePositiveInteger(
  value: string | undefined,
  fallback: number,
): number {
  const parsed = Number(value);

  return Number.isInteger(parsed) && parsed > 0 ? parsed : fallback;
}
