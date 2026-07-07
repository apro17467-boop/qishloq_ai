import {
  buildPaginationMeta,
  getPaginationParams,
} from './pagination.util';

describe('pagination util', () => {
  describe('getPaginationParams', () => {
    it('returns default page and limit', () => {
      expect(getPaginationParams()).toEqual({
        page: 1,
        limit: 20,
        skip: 0,
        take: 20,
      });
    });

    it('calculates skip and take', () => {
      expect(getPaginationParams(3, 10)).toEqual({
        page: 3,
        limit: 10,
        skip: 20,
        take: 10,
      });
    });

    it('caps limit at 50', () => {
      expect(getPaginationParams(1, 100)).toEqual({
        page: 1,
        limit: 50,
        skip: 0,
        take: 50,
      });
    });

    it('supports an endpoint-specific max limit', () => {
      expect(getPaginationParams(1, 100, { maxLimit: 100 })).toEqual({
        page: 1,
        limit: 100,
        skip: 0,
        take: 100,
      });
    });
  });

  describe('buildPaginationMeta', () => {
    it('returns totalPages 0 when total is 0', () => {
      expect(buildPaginationMeta(1, 20, 0)).toEqual({
        page: 1,
        limit: 20,
        total: 0,
        totalPages: 0,
      });
    });

    it('calculates totalPages with rounding up', () => {
      expect(buildPaginationMeta(1, 20, 21)).toEqual({
        page: 1,
        limit: 20,
        total: 21,
        totalPages: 2,
      });
    });
  });
});
