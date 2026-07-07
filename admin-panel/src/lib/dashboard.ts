import { apiGet } from "@/lib/api";
import type {
  DashboardStats,
  PaginatedMeta,
  PaginatedResponse
} from "@/types/api";

type CountResponse = PaginatedResponse<unknown>;

function totalFrom(response: { meta: PaginatedMeta }) {
  return response.meta.total;
}

export async function getDashboardStats(token: string): Promise<DashboardStats> {
  const [users, pendingListings, activeListings, openComplaints] =
    await Promise.all([
      apiGet<CountResponse>("/admin/users?page=1&limit=1", token),
      apiGet<CountResponse>("/admin/listings?page=1&limit=1&status=PENDING", token),
      apiGet<CountResponse>("/admin/listings?page=1&limit=1&status=ACTIVE", token),
      apiGet<CountResponse>(
        "/admin/complaints?page=1&limit=1&status=OPEN",
        token
      )
    ]);

  return {
    usersTotal: totalFrom(users),
    pendingListings: totalFrom(pendingListings),
    activeListings: totalFrom(activeListings),
    openComplaints: totalFrom(openComplaints)
  };
}
