import { apiGet } from "@/lib/api";
import type {
  AdminUsersQuery,
  AdminUsersResponse,
  AdminUserDetailResponse
} from "@/types/api";

/**
 * GET /admin/users
 */
export async function getAdminUsers(
  token: string,
  query: AdminUsersQuery
): Promise<AdminUsersResponse> {
  const params = new URLSearchParams({
    page: String(query.page),
    limit: String(query.limit)
  });

  if (query.role) {
    params.append("role", query.role);
  }

  if (query.isActive !== undefined) {
    params.append("isActive", String(query.isActive));
  }

  if (query.isVerified !== undefined) {
    params.append("isVerified", String(query.isVerified));
  }

  if (query.search?.trim()) {
    params.append("search", query.search.trim());
  }

  return apiGet<AdminUsersResponse>(`/admin/users?${params.toString()}`, token);
}

/**
 * GET /admin/users/:id
 */
export async function getAdminUserDetail(
  token: string,
  userId: string
): Promise<AdminUserDetailResponse> {
  return apiGet<AdminUserDetailResponse>(`/admin/users/${userId}`, token);
}
