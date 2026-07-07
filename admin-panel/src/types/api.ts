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

export type UserRole =
  | "FARMER"
  | "LIVESTOCK_OWNER"
  | "MACHINERY_OWNER"
  | "BUYER"
  | "AGRONOMIST"
  | "VETERINARIAN"
  | "ADMIN";

export type AuthUser = {
  id: string;
  phone: string;
  role: UserRole;
  isVerified: boolean;
  isActive: boolean;
  profile?: {
    fullName: string;
    avatarUrl: string | null;
    regionId: string | null;
    address: string | null;
  } | null;
};

export type RequestOtpResponse = {
  message: string;
  expiresInMinutes: number;
  devCode?: string;
};

export type VerifyOtpResponse = {
  accessToken: string;
  user: AuthUser;
};

export type MeResponse = {
  user: AuthUser;
};

export type DashboardStats = {
  usersTotal: number;
  pendingListings: number;
  activeListings: number;
  openComplaints: number;
};
