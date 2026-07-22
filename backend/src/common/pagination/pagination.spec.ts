import { buildPaginationMeta, normalizePagination } from './pagination';

describe('pagination helpers', () => {
  it('normalizes page and limit with defaults', () => {
    expect(normalizePagination({})).toEqual({
      page: 1,
      limit: 20,
      skip: 0,
    });
  });

  it('caps limit at max', () => {
    expect(normalizePagination({ page: 2, limit: 500 })).toEqual({
      page: 2,
      limit: 100,
      skip: 100,
    });
  });

  it('builds pagination meta', () => {
    expect(buildPaginationMeta(1, 20, 45)).toEqual({
      page: 1,
      limit: 20,
      total: 45,
      totalPages: 3,
    });
  });
});
