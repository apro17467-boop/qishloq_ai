export type ApiErrorResponse = {
  success: false;
  error: {
    code: string;
    message: string;
    details: string[];
  };
  statusCode: number;
  path: string;
  timestamp: string;
};

export type PaginatedMeta = {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
};

export type PaginatedResponse<T> = {
  data: T[];
  meta: PaginatedMeta;
};
