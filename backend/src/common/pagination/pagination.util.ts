import { PaginationMeta, PaginationParams } from './pagination.types';

const defaultPage = 1;
const defaultLimit = 20;
const maxLimit = 50;

export function getPaginationParams(
  page?: number,
  limit?: number,
): PaginationParams {
  const safePage = normalizePositiveInteger(page, defaultPage);
  const safeLimit = Math.min(
    normalizePositiveInteger(limit, defaultLimit),
    maxLimit,
  );

  return {
    page: safePage,
    limit: safeLimit,
    skip: (safePage - 1) * safeLimit,
    take: safeLimit,
  };
}

export function buildPaginationMeta(
  page: number,
  limit: number,
  total: number,
): PaginationMeta {
  return {
    page,
    limit,
    total,
    totalPages: total === 0 ? 0 : Math.ceil(total / limit),
  };
}

function normalizePositiveInteger(
  value: number | undefined,
  fallback: number,
): number {
  if (typeof value !== 'number' || !Number.isInteger(value) || value < 1) {
    return fallback;
  }

  return value;
}
