"use client";

import { useCallback, useEffect, useState } from "react";
import { ProtectedAdminRoute } from "@/components/auth/ProtectedAdminRoute";
import { AdminShell } from "@/components/layout/AdminShell";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { getAccessToken } from "@/lib/auth";
import { getAdminComplaints, updateComplaintStatus } from "@/lib/complaints";
import type {
  AdminComplaint,
  AdminComplaintsQuery,
  AdminComplaintsResponse,
  ComplaintStatus,
  UpdateComplaintStatusValue
} from "@/types/api";

// ─── Constants ────────────────────────────────────────────────────────────────

/**
 * Default holat: OPEN. Backend status bo'sh yuborilganda ham OPEN qaytaradi,
 * lekin aniqlik uchun har doim status=OPEN yuboriladi.
 */
const DEFAULT_QUERY: AdminComplaintsQuery = {
  page: 1,
  limit: 10,
  status: "OPEN"
};

/** Backend DTO da qo'llab-quvvatlanadigan status qiymatlari (reason yo'q). */
const COMPLAINT_STATUSES: ComplaintStatus[] = [
  "OPEN",
  "IN_REVIEW",
  "RESOLVED",
  "REJECTED"
];

/**
 * Reason label helper — backend schemada reason oddiy String saqlanadi.
 * Bu ro'yxat faqat jadvalda o'zbekcha label ko'rsatish uchun.
 * Reason bo'yicha server-side filtrlash backend DTO da qo'llab-quvvatlanmaydi.
 */
const KNOWN_REASONS: Array<{ value: string; label: string }> = [
  { value: "FRAUD", label: "Firibgarlik" },
  { value: "SPAM", label: "Spam" },
  { value: "WRONG_INFO", label: "Noto'g'ri ma'lumot" },
  { value: "INAPPROPRIATE", label: "Nomaqbul kontent" },
  { value: "DUPLICATE", label: "Takroriy e'lon" },
  { value: "OTHER", label: "Boshqa" }
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

function formatDate(value: string): string {
  return new Intl.DateTimeFormat("uz-UZ", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit"
  }).format(new Date(value));
}

function truncateMessage(message: string, maxLength = 90): string {
  if (message.length <= maxLength) return message;
  return message.slice(0, maxLength).trimEnd() + "...";
}

function getReasonLabel(reason: string): string {
  const found = KNOWN_REASONS.find((r) => r.value === reason);
  return found ? found.label : reason;
}

const statusLabels: Record<ComplaintStatus, string> = {
  OPEN: "Ochiq",
  IN_REVIEW: "Ko'rib chiqilmoqda",
  RESOLVED: "Hal qilingan",
  REJECTED: "Rad etilgan"
};

/** Status filter dropdown uchun label (faqat 4 ta qiymat, "Barchasi" yo'q). */
const statusSelectLabels: Record<ComplaintStatus, string> = {
  OPEN: "Ochiq",
  IN_REVIEW: "Ko'rib chiqilmoqda",
  RESOLVED: "Hal qilingan",
  REJECTED: "Rad etilgan"
};

/**
 * Empty state matni — tanlangan statusga mos.
 */
const emptyStateLabels: Record<ComplaintStatus, string> = {
  OPEN: "Ochiq shikoyatlar topilmadi.",
  IN_REVIEW: "Ko'rib chiqilayotgan shikoyatlar topilmadi.",
  RESOLVED: "Hal qilingan shikoyatlar topilmadi.",
  REJECTED: "Rad etilgan shikoyatlar topilmadi."
};

/**
 * Status badge ranglari:
 * OPEN      → sariq/amber
 * IN_REVIEW → ko'k
 * RESOLVED  → yashil
 * REJECTED  → kulrang
 */
const statusBadgeClass: Record<ComplaintStatus, string> = {
  OPEN: "bg-amber-50 text-amber-700 ring-amber-100",
  IN_REVIEW: "bg-blue-50 text-blue-700 ring-blue-100",
  RESOLVED: "bg-emerald-50 text-emerald-700 ring-emerald-100",
  REJECTED: "bg-slate-100 text-slate-600 ring-slate-200"
};

// ─── Page component ───────────────────────────────────────────────────────────

export default function ComplaintsPage() {
  const [query, setQuery] = useState<AdminComplaintsQuery>(DEFAULT_QUERY);
  const [response, setResponse] = useState<AdminComplaintsResponse | null>(
    null
  );
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [updatingId, setUpdatingId] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [updateError, setUpdateError] = useState<string | null>(null);

  const complaints: AdminComplaint[] = response?.data ?? [];
  const meta = response?.meta;

  const canGoPrevious = Boolean(meta && meta.page > 1);
  const canGoNext = Boolean(
    meta && meta.totalPages > 0 && meta.page < meta.totalPages
  );

  const loadComplaints = useCallback(
    async (options?: { silent?: boolean }) => {
      const token = getAccessToken();

      if (!token) {
        setLoading(false);
        return;
      }

      if (!options?.silent) {
        setLoading(true);
      }
      setError(null);

      try {
        const data = await getAdminComplaints(token, query);
        setResponse(data);
      } catch {
        setError("Shikoyatlarni yuklashda xatolik yuz berdi");
      } finally {
        if (!options?.silent) {
          setLoading(false);
        }
      }
    },
    [query]
  );

  useEffect(() => {
    void loadComplaints();
  }, [loadComplaints]);

  // ─── Handlers ───────────────────────────────────────────────────────────────

  function updateStatus(status: ComplaintStatus) {
    setQuery((current) => ({ ...current, page: 1, status }));
  }

  function goToPage(page: number) {
    setQuery((current) => ({ ...current, page }));
  }

  function handleResetToDefault() {
    setQuery(DEFAULT_QUERY);
  }

  async function handleStatusUpdate(
    complaintId: string,
    newStatus: UpdateComplaintStatusValue,
    confirmMessage: string,
    successText: string
  ) {
    if (!window.confirm(confirmMessage)) return;

    const token = getAccessToken();
    if (!token) return;

    setUpdatingId(complaintId);
    setUpdateError(null);
    setSuccessMessage(null);

    try {
      await updateComplaintStatus(token, complaintId, { status: newStatus });
      setSuccessMessage(successText);
      await loadComplaints({ silent: true });
    } catch (err: any) {
      setUpdateError(
        `Shikoyat statusini yangilashda xatolik yuz berdi. ${err?.message || ""}`
      );
    } finally {
      setUpdatingId(null);
    }
  }

  // ─── Render helpers ──────────────────────────────────────────────────────────

  function renderActionCell(complaint: AdminComplaint) {
    const isUpdating = updatingId === complaint.id;

    if (complaint.status === "OPEN") {
      return (
        <div className="flex flex-col gap-2 min-w-[120px]">
          <Button
            type="button"
            variant="secondary"
            className="w-full text-xs"
            disabled={isUpdating}
            onClick={() =>
              handleStatusUpdate(
                complaint.id,
                "IN_REVIEW",
                "Shikoyatni ko'rib chiqish holatiga o'tkazasizmi?",
                "Shikoyat ko'rib chiqishga olindi."
              )
            }
          >
            {isUpdating ? "..." : "Ko'rib chiqish"}
          </Button>
          <Button
            type="button"
            variant="secondary"
            className="w-full text-xs text-red-600 border-red-200 hover:bg-red-50 hover:border-red-300"
            disabled={isUpdating}
            onClick={() =>
              handleStatusUpdate(
                complaint.id,
                "REJECTED",
                "Shikoyatni rad etasizmi?",
                "Shikoyat rad etildi."
              )
            }
          >
            Rad etish
          </Button>
        </div>
      );
    }

    if (complaint.status === "IN_REVIEW") {
      return (
        <div className="flex flex-col gap-2 min-w-[120px]">
          <Button
            type="button"
            variant="secondary"
            className="w-full text-xs text-emerald-700 border-emerald-200 hover:bg-emerald-50 hover:border-emerald-300"
            disabled={isUpdating}
            onClick={() =>
              handleStatusUpdate(
                complaint.id,
                "RESOLVED",
                "Shikoyatni hal qilingan deb belgilaysizmi?",
                "Shikoyat hal qilingan deb belgilandi."
              )
            }
          >
            {isUpdating ? "..." : "Hal qilish"}
          </Button>
          <Button
            type="button"
            variant="secondary"
            className="w-full text-xs text-red-600 border-red-200 hover:bg-red-50 hover:border-red-300"
            disabled={isUpdating}
            onClick={() =>
              handleStatusUpdate(
                complaint.id,
                "REJECTED",
                "Shikoyatni rad etasizmi?",
                "Shikoyat rad etildi."
              )
            }
          >
            Rad etish
          </Button>
        </div>
      );
    }

    return (
      <span className="text-xs font-medium text-slate-400">
        {complaint.status === "RESOLVED" ? "Hal qilingan" : "Rad etilgan"}
      </span>
    );
  }

  // ─── JSX ─────────────────────────────────────────────────────────────────────

  return (
    <ProtectedAdminRoute>
      <AdminShell>
        <div className="space-y-6">
          {/* ── Header ──────────────────────────────────────────────────────── */}
          <div className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <p className="text-sm font-medium text-field-700">
                Admin complaints
              </p>
              <h1 className="mt-1 text-2xl font-semibold tracking-normal text-slate-950">
                Shikoyatlar
              </h1>
              <p className="mt-2 max-w-2xl text-sm text-slate-500">
                Foydalanuvchilar yuborgan shikoyatlarni ko&apos;rish va tahlil
                qilish.
              </p>
            </div>
          </div>

          {/* ── Alerts ─────────────────────────────────────────────────────── */}
          {successMessage && (
            <Card className="border-emerald-200 bg-emerald-50 p-4">
              <p className="text-sm font-medium text-emerald-700">
                {successMessage}
              </p>
            </Card>
          )}

          {updateError && (
            <Card className="flex flex-col gap-4 border-red-200 bg-red-50 sm:flex-row sm:items-center sm:justify-between p-4">
              <p className="text-sm font-medium text-red-700">{updateError}</p>
              <Button
                type="button"
                variant="secondary"
                onClick={() => setUpdateError(null)}
              >
                Yopish
              </Button>
            </Card>
          )}

          {/* ── Filters ─────────────────────────────────────────────────────── */}
          <Card>
            <div className="flex flex-wrap items-end gap-4">
              {/* Status filter */}
              <label className="block flex-1 min-w-[180px] max-w-xs">
                <span className="mb-2 block text-sm font-medium text-slate-700">
                  Status
                </span>
                <select
                  id="complaints-status-filter"
                  className="block min-h-11 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm text-slate-950 outline-none transition focus:border-field-600 focus:ring-2 focus:ring-field-100"
                  value={query.status}
                  onChange={(e) =>
                    updateStatus(e.target.value as ComplaintStatus)
                  }
                >
                  {COMPLAINT_STATUSES.map((s) => (
                    <option key={s} value={s}>
                      {statusSelectLabels[s]}
                    </option>
                  ))}
                </select>
              </label>

              {/* Reset to default */}
              <Button
                id="complaints-reset-filter"
                type="button"
                variant="secondary"
                onClick={handleResetToDefault}
              >
                Ochiq shikoyatlar
              </Button>

              {/* Info note */}
              <p className="text-xs text-slate-400 self-end pb-1">
                Shikoyatlar status bo&apos;yicha ko&apos;rsatilmoqda.
              </p>
            </div>
          </Card>

          {/* ── Error state ─────────────────────────────────────────────────── */}
          {error ? (
            <Card className="flex flex-col gap-4 border-red-200 bg-red-50 sm:flex-row sm:items-center sm:justify-between">
              <p className="text-sm font-medium text-red-700">{error}</p>
              <Button
                id="complaints-retry"
                type="button"
                variant="secondary"
                onClick={() => void loadComplaints()}
              >
                Qayta urinish
              </Button>
            </Card>
          ) : null}

          {/* ── Table card ──────────────────────────────────────────────────── */}
          <Card className="overflow-hidden p-0">
            {loading ? (
              <div className="p-5 text-sm text-slate-500">Yuklanmoqda...</div>
            ) : complaints.length === 0 && !error ? (
              /* ── Empty state ─────────────────────────────────────────────── */
              <div className="p-6">
                <p className="text-sm font-semibold text-slate-900">
                  {emptyStateLabels[query.status]}
                </p>
                <p className="mt-1 text-sm text-slate-500">
                  Boshqa statusni tanlang yoki keyinroq qayta tekshiring.
                </p>
                <button
                  type="button"
                  className="mt-3 text-sm font-medium text-field-700 underline-offset-2 hover:underline"
                  onClick={handleResetToDefault}
                >
                  Ochiq shikoyatlarga qaytish
                </button>
              </div>
            ) : (
              /* ── Table ───────────────────────────────────────────────────── */
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-slate-200 text-left text-sm">
                  <thead className="bg-slate-50 text-xs font-semibold uppercase tracking-wide text-slate-500">
                    <tr>
                      <th className="px-4 py-3">Sabab</th>
                      <th className="px-4 py-3">Status</th>
                      <th className="px-4 py-3">E&apos;lon</th>
                      <th className="px-4 py-3">Shikoyatchi</th>
                      <th className="px-4 py-3">E&apos;lon egasi</th>
                      <th className="px-4 py-3 max-w-xs">Xabar</th>
                      <th className="px-4 py-3">Sana</th>
                      <th className="px-4 py-3">Amal</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 bg-white">
                    {complaints.map((complaint) => (
                      <tr key={complaint.id} className="align-top">
                        {/* Sabab */}
                        <td className="px-4 py-3">
                          <span className="font-medium text-slate-800">
                            {getReasonLabel(complaint.reason)}
                          </span>
                          <p className="text-xs text-slate-400 mt-0.5">
                            {complaint.reason}
                          </p>
                        </td>

                        {/* Status */}
                        <td className="px-4 py-3">
                          <Badge
                            className={
                              statusBadgeClass[complaint.status] ??
                              "bg-slate-100 text-slate-600 ring-slate-200"
                            }
                          >
                            {statusLabels[complaint.status] ?? complaint.status}
                          </Badge>
                        </td>

                        {/* E'lon */}
                        <td className="px-4 py-3 text-slate-700">
                          {complaint.listing ? (
                            <>
                              <p className="font-medium text-slate-950 line-clamp-2 max-w-[180px]">
                                {complaint.listing.title}
                              </p>
                              {complaint.listing.type ? (
                                <p className="text-xs text-slate-400 mt-0.5">
                                  {complaint.listing.type}
                                </p>
                              ) : null}
                            </>
                          ) : (
                            <span className="text-slate-400">—</span>
                          )}
                        </td>

                        {/* Shikoyatchi */}
                        <td className="px-4 py-3 text-slate-700">
                          {complaint.reporter ? (
                            <>
                              <p>
                                {complaint.reporter.profile?.fullName ??
                                  "Noma'lum"}
                              </p>
                              <p className="text-xs text-slate-400">
                                {complaint.reporter.phone}
                              </p>
                            </>
                          ) : (
                            <span className="text-slate-400">—</span>
                          )}
                        </td>

                        {/* E'lon egasi */}
                        <td className="px-4 py-3 text-slate-700">
                          {complaint.listing?.owner ? (
                            <>
                              <p>
                                {complaint.listing.owner.profile?.fullName ??
                                  "Noma'lum"}
                              </p>
                              <p className="text-xs text-slate-400">
                                {complaint.listing.owner.phone}
                              </p>
                            </>
                          ) : (
                            <span className="text-slate-400">—</span>
                          )}
                        </td>

                        {/* Xabar */}
                        <td className="px-4 py-3 text-slate-600 max-w-xs">
                          {complaint.message ? (
                            <span title={complaint.message}>
                              {truncateMessage(complaint.message)}
                            </span>
                          ) : (
                            <span className="text-slate-400">—</span>
                          )}
                        </td>

                        {/* Sana */}
                        <td className="px-4 py-3 text-slate-700 whitespace-nowrap">
                          {formatDate(complaint.createdAt)}
                        </td>

                        {/* Amal */}
                        <td className="px-4 py-3">
                          {renderActionCell(complaint)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </Card>

          {/* ── Pagination ──────────────────────────────────────────────────── */}
          <div className="flex flex-col gap-3 text-sm text-slate-600 sm:flex-row sm:items-center sm:justify-between">
            <p>
              Jami: {meta?.total ?? 0} ta | Sahifa{" "}
              {meta?.page ?? query.page} / {meta?.totalPages ?? 0}
            </p>
            <div className="flex gap-2">
              <Button
                id="complaints-prev-page"
                type="button"
                variant="secondary"
                disabled={!canGoPrevious || loading}
                onClick={() => goToPage((meta?.page ?? query.page) - 1)}
              >
                Oldingi
              </Button>
              <Button
                id="complaints-next-page"
                type="button"
                variant="secondary"
                disabled={!canGoNext || loading}
                onClick={() => goToPage((meta?.page ?? query.page) + 1)}
              >
                Keyingi
              </Button>
            </div>
          </div>
        </div>
      </AdminShell>
    </ProtectedAdminRoute>
  );
}
