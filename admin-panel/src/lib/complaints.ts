import { apiGet, apiPatch } from "@/lib/api";
import type {
  AdminComplaintsQuery,
  AdminComplaintsResponse,
  UpdateComplaintStatusRequest,
  UpdateComplaintStatusResponse
} from "@/types/api";

/**
 * GET /admin/complaints
 *
 * Backend AdminComplaintsQueryDto qo'llab-quvvatlagan paramlar:
 *   - page    (min: 1, default: 1)
 *   - limit   (min: 1, max: 50, default: 20)
 *   - status  (ComplaintStatus — har doim yuboriladi, default backend: OPEN)
 *
 * Backend DTO da `reason` parametri mavjud emas – u query ga qo'shilmaydi.
 * Keyingi qadamlarda listingId yoki reporterId qo'shish mumkin.
 */
export async function getAdminComplaints(
  token: string,
  query: AdminComplaintsQuery
): Promise<AdminComplaintsResponse> {
  const params = new URLSearchParams({
    page: String(query.page),
    limit: String(query.limit),
    status: query.status
  });

  return apiGet<AdminComplaintsResponse>(
    `/admin/complaints?${params.toString()}`,
    token
  );
}

/**
 * PATCH /admin/complaints/:id/status
 */
export async function updateComplaintStatus(
  token: string,
  complaintId: string,
  body: UpdateComplaintStatusRequest
): Promise<UpdateComplaintStatusResponse> {
  return apiPatch<UpdateComplaintStatusResponse, UpdateComplaintStatusRequest>(
    `/admin/complaints/${complaintId}/status`,
    body,
    token
  );
}
