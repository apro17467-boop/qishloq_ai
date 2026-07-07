import { apiGet, apiPost } from "@/lib/api";
import type {
  AuthUser,
  MeResponse,
  RequestOtpResponse,
  VerifyOtpResponse
} from "@/types/api";

const TOKEN_KEY = "qishloq_ai_admin_token";

type VerifyAdminOtpParams = {
  phone: string;
  code: string;
  fullName?: string;
  address?: string;
};

export function requestAdminOtp(phone: string) {
  return apiPost<RequestOtpResponse, { phone: string }>("/auth/request-otp", {
    phone
  });
}

export function verifyAdminOtp({
  phone,
  code,
  fullName = "Admin User",
  address = "Admin panel login"
}: VerifyAdminOtpParams) {
  return apiPost<
    VerifyOtpResponse,
    {
      phone: string;
      code: string;
      role: "ADMIN";
      fullName: string;
      address: string;
    }
  >("/auth/verify-otp", {
    phone,
    code,
    role: "ADMIN",
    fullName,
    address
  });
}

export function getMe(token: string) {
  return apiGet<MeResponse>("/auth/me", token);
}

export function isAdminUser(user: AuthUser) {
  return user.role === "ADMIN" && user.isActive === true;
}

export function saveAccessToken(token: string) {
  if (typeof window === "undefined") {
    return;
  }

  window.localStorage.setItem(TOKEN_KEY, token);
}

export function getAccessToken() {
  if (typeof window === "undefined") {
    return null;
  }

  return window.localStorage.getItem(TOKEN_KEY);
}

export function clearAccessToken() {
  if (typeof window === "undefined") {
    return;
  }

  window.localStorage.removeItem(TOKEN_KEY);
}
