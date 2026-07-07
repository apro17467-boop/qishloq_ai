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

export type ListingStatus = "PENDING" | "ACTIVE" | "REJECTED" | "ARCHIVED";

export type ListingType =
  | "MACHINERY_RENT"
  | "PRODUCT_SALE"
  | "LIVESTOCK_SALE"
  | "MACHINERY_SALE"
  | "SERVICE";

export type AdminListing = {
  id: string;
  type: ListingType;
  status: ListingStatus;
  title: string;
  description?: string | null;
  priceAmount?: string | null;
  priceCurrency?: string | null;
  unit?: string | null;
  contactPhone?: string | null;
  address?: string | null;
  createdAt: string;
  updatedAt?: string | null;
  category?: {
    id: string;
    nameUz: string;
    slug: string;
  } | null;
  region?: {
    id: string;
    nameUz: string;
  } | null;
  owner?: {
    id: string;
    phone: string;
    role?: UserRole;
    profile?: {
      fullName?: string | null;
    } | null;
  } | null;
};

export type AdminListingsQuery = {
  page: number;
  limit: number;
  status?: ListingStatus | "";
  type?: ListingType | "";
  search?: string;
};

export type AdminListingsResponse = PaginatedResponse<AdminListing>;

export type ModerateListingStatus = "ACTIVE" | "REJECTED";

export type ModerateListingRequest = {
  status: ModerateListingStatus;
};

export type ModerateListingResponse = {
  data: {
    id: string;
    status: ModerateListingStatus;
    title?: string;
    updatedAt?: string;
  };
};

// ─── Complaints ───────────────────────────────────────────────────────────────

export type ComplaintStatus =
  | "OPEN"
  | "IN_REVIEW"
  | "RESOLVED"
  | "REJECTED";

/**
 * Backend schemada reason oddiy String (enum emas).
 * Ma'lum qiymatlar amalda FRAUD, SPAM, WRONG_INFO, OTHER va h.k. bo'lishi mumkin.
 */
export type ComplaintReason = string;

export type AdminComplaint = {
  id: string;
  reason: ComplaintReason;
  message?: string | null;
  status: ComplaintStatus;
  createdAt: string;
  updatedAt?: string | null;
  listing?: {
    id: string;
    title: string;
    status?: string | null;
    type?: string | null;
    contactPhone?: string | null;
    owner?: {
      id: string;
      phone: string;
      profile?: {
        fullName?: string | null;
        avatarUrl?: string | null;
      } | null;
    } | null;
  } | null;
  reporter?: {
    id: string;
    phone: string;
    role?: string | null;
    profile?: {
      fullName?: string | null;
      avatarUrl?: string | null;
    } | null;
  } | null;
};

/**
 * Backend AdminComplaintsQueryDto ga mos query.
 * Qo'llab-quvvatlanadigan paramlar: page, limit, status.
 * listingId va reporterId ni keyingi qadamlarda ishlatish mumkin.
 * DIQQAT: Backend DTO da `reason` parametri yo'q – u query ga qo'shilmaydi.
 * status har doim aniq ComplaintStatus bo'lishi shart (backend default OPEN).
 */
export type AdminComplaintsQuery = {
  page: number;
  limit: number;
  status: ComplaintStatus;
};

export type AdminComplaintsResponse = PaginatedResponse<AdminComplaint>;

export type UpdateComplaintStatusValue = "IN_REVIEW" | "RESOLVED" | "REJECTED";

export type UpdateComplaintStatusRequest = {
  status: UpdateComplaintStatusValue;
};

export type UpdateComplaintStatusResponse = {
  data: {
    id: string;
    status: ComplaintStatus;
    reason: ComplaintReason;
    updatedAt: string;
  };
};
