"use client";

import { useCallback, useEffect, useState } from "react";
import { ProtectedAdminRoute } from "@/components/auth/ProtectedAdminRoute";
import { AdminShell } from "@/components/layout/AdminShell";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { getAccessToken } from "@/lib/auth";
import { getAdminUsers, getAdminUserDetail } from "@/lib/users";
import type {
  AdminUser,
  AdminUsersQuery,
  AdminUsersResponse,
  AdminUserDetail,
  UserRole
} from "@/types/api";

// ─── Constants ────────────────────────────────────────────────────────────────

const DEFAULT_QUERY: AdminUsersQuery = {
  page: 1,
  limit: 10,
  role: "",
  isActive: undefined,
  isVerified: undefined,
  search: ""
};

const ROLE_LABELS: Record<UserRole, string> = {
  FARMER: "Dehqon/Fermer",
  LIVESTOCK_OWNER: "Chorvador",
  MACHINERY_OWNER: "Texnika egasi",
  BUYER: "Xaridor",
  AGRONOMIST: "Agronom",
  VETERINARIAN: "Veterinar",
  ADMIN: "Admin"
};

const ROLES: UserRole[] = [
  "FARMER",
  "LIVESTOCK_OWNER",
  "MACHINERY_OWNER",
  "BUYER",
  "AGRONOMIST",
  "VETERINARIAN",
  "ADMIN"
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

function formatDate(value: string): string {
  return new Intl.DateTimeFormat("uz-UZ", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit"
  }).format(new Date(value));
}

function formatDateTime(value: string): string {
  return new Intl.DateTimeFormat("uz-UZ", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit"
  }).format(new Date(value));
}

const statusBadgeClass = (active: boolean) =>
  active
    ? "bg-emerald-50 text-emerald-700 ring-emerald-100"
    : "bg-red-50 text-red-700 ring-red-100";

const verifiedBadgeClass = (verified: boolean) =>
  verified
    ? "bg-blue-50 text-blue-700 ring-blue-100"
    : "bg-slate-100 text-slate-600 ring-slate-200";

// ─── Page Component ───────────────────────────────────────────────────────────

export default function UsersPage() {
  const [query, setQuery] = useState<AdminUsersQuery>(DEFAULT_QUERY);
  const [searchInput, setSearchInput] = useState("");
  const [response, setResponse] = useState<AdminUsersResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Modal / Detail state
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [detailUser, setDetailUser] = useState<AdminUserDetail | null>(null);
  const [detailLoading, setDetailLoading] = useState(false);
  const [detailError, setDetailError] = useState<string | null>(null);

  const users: AdminUser[] = response?.data ?? [];
  const meta = response?.meta;

  const canGoPrevious = Boolean(meta && meta.page > 1);
  const canGoNext = Boolean(
    meta && meta.totalPages > 0 && meta.page < meta.totalPages
  );

  const loadUsers = useCallback(
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
        const data = await getAdminUsers(token, query);
        setResponse(data);
      } catch {
        setError("Foydalanuvchilarni yuklashda xatolik yuz berdi");
      } finally {
        if (!options?.silent) {
          setLoading(false);
        }
      }
    },
    [query]
  );

  useEffect(() => {
    void loadUsers();
  }, [loadUsers]);

  // Sync search input state with query search
  useEffect(() => {
    setSearchInput(query.search ?? "");
  }, [query.search]);

  // ─── Handlers ───────────────────────────────────────────────────────────────

  function handleFilterChange(key: keyof AdminUsersQuery, value: any) {
    setQuery((current) => ({
      ...current,
      page: 1,
      [key]: value
    }));
  }

  function handleSearchSubmit(e: React.FormEvent) {
    e.preventDefault();
    setQuery((current) => ({
      ...current,
      page: 1,
      search: searchInput
    }));
  }

  function handleSearchClear() {
    setSearchInput("");
    setQuery((current) => ({
      ...current,
      page: 1,
      search: ""
    }));
  }

  function handleResetFilters() {
    setSearchInput("");
    setQuery(DEFAULT_QUERY);
  }

  function goToPage(page: number) {
    setQuery((current) => ({ ...current, page }));
  }

  async function openDetailModal(userId: string) {
    setSelectedUserId(userId);
    setDetailLoading(true);
    setDetailError(null);
    setDetailUser(null);

    const token = getAccessToken();
    if (!token) {
      setDetailError("Sessiya topilmadi");
      setDetailLoading(false);
      return;
    }

    try {
      const res = await getAdminUserDetail(token, userId);
      setDetailUser(res.data);
    } catch {
      setDetailError("Foydalanuvchi tafsilotlarini yuklashda xatolik yuz berdi");
    } finally {
      setDetailLoading(false);
    }
  }

  function closeDetailModal() {
    setSelectedUserId(null);
    setDetailUser(null);
    setDetailError(null);
  }

  return (
    <ProtectedAdminRoute>
      <AdminShell>
        <div className="space-y-6">
          {/* ── Header ──────────────────────────────────────────────────────── */}
          <div className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <p className="text-sm font-medium text-field-700">
                Foydalanuvchilar monitoringi
              </p>
              <h1 className="mt-1 text-2xl font-semibold tracking-normal text-slate-950">
                Foydalanuvchilar
              </h1>
              <p className="mt-2 max-w-2xl text-sm text-slate-500">
                Platformadagi foydalanuvchilarni kuzatish va ularning faolligini
                ko&apos;rish.
              </p>
            </div>
          </div>

          {/* ── Filters ─────────────────────────────────────────────────────── */}
          <Card>
            <form
              onSubmit={handleSearchSubmit}
              className="space-y-4 md:space-y-0 md:flex md:flex-wrap md:items-end md:gap-4"
            >
              {/* Search input */}
              <div className="flex-1 min-w-[200px] max-w-sm">
                <label className="block">
                  <span className="mb-2 block text-sm font-medium text-slate-700">
                    Qidiruv (Telefon yoki Ism)
                  </span>
                  <div className="flex gap-2">
                    <input
                      type="text"
                      className="block min-h-11 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm text-slate-950 outline-none transition focus:border-field-600 focus:ring-2 focus:ring-field-100"
                      placeholder="+998901234567 yoki Familiya Ism"
                      value={searchInput}
                      onChange={(e) => setSearchInput(e.target.value)}
                    />
                    <Button type="submit" variant="primary">
                      Qidirish
                    </Button>
                    {query.search && (
                      <Button
                        type="button"
                        variant="secondary"
                        onClick={handleSearchClear}
                      >
                        Tozalash
                      </Button>
                    )}
                  </div>
                </label>
              </div>

              {/* Role filter */}
              <label className="block w-full md:w-auto md:min-w-[150px]">
                <span className="mb-2 block text-sm font-medium text-slate-700">
                  Rol
                </span>
                <select
                  className="block min-h-11 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm text-slate-950 outline-none transition focus:border-field-600 focus:ring-2 focus:ring-field-100"
                  value={query.role ?? ""}
                  onChange={(e) =>
                    handleFilterChange("role", e.target.value || undefined)
                  }
                >
                  <option value="">Barchasi</option>
                  {ROLES.map((r) => (
                    <option key={r} value={r}>
                      {ROLE_LABELS[r]}
                    </option>
                  ))}
                </select>
              </label>

              {/* Status filter */}
              <label className="block w-full md:w-auto md:min-w-[150px]">
                <span className="mb-2 block text-sm font-medium text-slate-700">
                  Status
                </span>
                <select
                  className="block min-h-11 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm text-slate-950 outline-none transition focus:border-field-600 focus:ring-2 focus:ring-field-100"
                  value={
                    query.isActive === undefined
                      ? ""
                      : query.isActive
                        ? "true"
                        : "false"
                  }
                  onChange={(e) => {
                    const val = e.target.value;
                    handleFilterChange(
                      "isActive",
                      val === "" ? undefined : val === "true"
                    );
                  }}
                >
                  <option value="">Barchasi</option>
                  <option value="true">Faol</option>
                  <option value="false">Nofaol</option>
                </select>
              </label>

              {/* Verified filter */}
              <label className="block w-full md:w-auto md:min-w-[150px]">
                <span className="mb-2 block text-sm font-medium text-slate-700">
                  Tasdiqlangan
                </span>
                <select
                  className="block min-h-11 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm text-slate-950 outline-none transition focus:border-field-600 focus:ring-2 focus:ring-field-100"
                  value={
                    query.isVerified === undefined
                      ? ""
                      : query.isVerified
                        ? "true"
                        : "false"
                  }
                  onChange={(e) => {
                    const val = e.target.value;
                    handleFilterChange(
                      "isVerified",
                      val === "" ? undefined : val === "true"
                    );
                  }}
                >
                  <option value="">Barchasi</option>
                  <option value="true">Tasdiqlangan</option>
                  <option value="false">Tasdiqlanmagan</option>
                </select>
              </label>

              {/* Reset to default */}
              <Button
                type="button"
                variant="secondary"
                onClick={handleResetFilters}
              >
                Filtrlarni tozalash
              </Button>
            </form>
          </Card>

          {/* ── Error State ─────────────────────────────────────────────────── */}
          {error && (
            <Card className="flex flex-col gap-4 border-red-200 bg-red-50 sm:flex-row sm:items-center sm:justify-between">
              <p className="text-sm font-medium text-red-700">{error}</p>
              <Button
                type="button"
                variant="secondary"
                onClick={() => void loadUsers()}
              >
                Qayta urinish
              </Button>
            </Card>
          )}

          {/* ── Table Card ──────────────────────────────────────────────────── */}
          <Card className="overflow-hidden p-0">
            {loading ? (
              <div className="p-5 text-sm text-slate-500">Yuklanmoqda...</div>
            ) : users.length === 0 && !error ? (
              /* ── Empty State ─────────────────────────────────────────────── */
              <div className="p-6">
                <p className="text-sm font-semibold text-slate-900">
                  Foydalanuvchilar topilmadi
                </p>
                <p className="mt-1 text-sm text-slate-500">
                  Boshqa qidiruv so&apos;rovi yoki filtrlarni tanlang.
                </p>
                <button
                  type="button"
                  className="mt-3 text-sm font-medium text-field-700 underline-offset-2 hover:underline"
                  onClick={handleResetFilters}
                >
                  Filtrlarni tozalash
                </button>
              </div>
            ) : (
              /* ── Table ───────────────────────────────────────────────────── */
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-slate-200 text-left text-sm">
                  <thead className="bg-slate-50 text-xs font-semibold uppercase tracking-wide text-slate-500">
                    <tr>
                      <th className="px-4 py-3">Telefon</th>
                      <th className="px-4 py-3">Ism</th>
                      <th className="px-4 py-3">Rol</th>
                      <th className="px-4 py-3">Tasdiq</th>
                      <th className="px-4 py-3">Holat</th>
                      <th className="px-4 py-3">Manzil</th>
                      <th className="px-4 py-3">Ro&apos;yxatdan o&apos;tgan sana</th>
                      <th className="px-4 py-3">Amal</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 bg-white">
                    {users.map((user) => (
                      <tr key={user.id} className="align-middle hover:bg-slate-50">
                        {/* Telefon */}
                        <td className="px-4 py-3 font-medium text-slate-900 whitespace-nowrap">
                          {user.phone}
                        </td>

                        {/* Ism */}
                        <td className="px-4 py-3 text-slate-700">
                          {user.profile?.fullName || (
                            <span className="text-slate-400 font-normal italic">
                              Kiritilmagan
                            </span>
                          )}
                        </td>

                        {/* Role */}
                        <td className="px-4 py-3 text-slate-700">
                          <span className="inline-flex rounded-full bg-slate-100 px-2 text-xs font-semibold leading-5 text-slate-800">
                            {ROLE_LABELS[user.role] ?? user.role}
                          </span>
                        </td>

                        {/* Verified */}
                        <td className="px-4 py-3">
                          <Badge className={verifiedBadgeClass(user.isVerified)}>
                            {user.isVerified ? "Ha" : "Yo'q"}
                          </Badge>
                        </td>

                        {/* Active */}
                        <td className="px-4 py-3">
                          <Badge className={statusBadgeClass(user.isActive)}>
                            {user.isActive ? "Faol" : "Nofaol"}
                          </Badge>
                        </td>

                        {/* Manzil */}
                        <td className="px-4 py-3 text-slate-600 max-w-xs truncate">
                          {user.profile?.address ? (
                            <span>{user.profile.address}</span>
                          ) : user.profile?.region?.nameUz ? (
                            <span>{user.profile.region.nameUz}</span>
                          ) : (
                            <span className="text-slate-400">—</span>
                          )}
                        </td>

                        {/* Sana */}
                        <td className="px-4 py-3 text-slate-700 whitespace-nowrap">
                          {formatDate(user.createdAt)}
                        </td>

                        {/* Amal */}
                        <td className="px-4 py-3">
                          <Button
                            type="button"
                            variant="secondary"
                            className="text-xs"
                            onClick={() => openDetailModal(user.id)}
                          >
                            Ko&apos;rish
                          </Button>
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
                type="button"
                variant="secondary"
                disabled={!canGoPrevious || loading}
                onClick={() => goToPage((meta?.page ?? query.page) - 1)}
              >
                Oldingi
              </Button>
              <Button
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

        {/* ── User Detail Modal ──────────────────────────────────────────────── */}
        {selectedUserId && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm">
            <div className="relative w-full max-w-3xl max-h-[90vh] overflow-y-auto rounded-xl bg-white shadow-2xl transition-all">
              {/* Modal Header */}
              <div className="flex items-center justify-between border-b border-slate-100 p-6">
                <div>
                  <h3 className="text-lg font-semibold text-slate-900">
                    Foydalanuvchi tafsilotlari
                  </h3>
                  <p className="text-xs text-slate-400 font-mono mt-0.5">
                    ID: {selectedUserId}
                  </p>
                </div>
                <button
                  type="button"
                  className="rounded-lg p-1 text-slate-400 hover:bg-slate-50 hover:text-slate-700"
                  onClick={closeDetailModal}
                >
                  <span className="text-xl leading-none">&times;</span>
                </button>
              </div>

              {/* Modal Content */}
              <div className="p-6 space-y-6">
                {detailLoading ? (
                  <div className="text-center py-10 text-slate-500">
                    Tafsilotlar yuklanmoqda...
                  </div>
                ) : detailError ? (
                  <div className="rounded-lg border border-red-200 bg-red-50 p-4 text-center">
                    <p className="text-sm font-medium text-red-700">
                      {detailError}
                    </p>
                    <Button
                      type="button"
                      variant="secondary"
                      className="mt-3 text-xs"
                      onClick={() => openDetailModal(selectedUserId)}
                    >
                      Qayta urinish
                    </Button>
                  </div>
                ) : detailUser ? (
                  <div className="space-y-6">
                    {/* Basic Info Grid */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 bg-slate-50 p-4 rounded-lg">
                      <div>
                        <p className="text-xs text-slate-400 font-medium">Telefon</p>
                        <p className="text-sm font-semibold text-slate-900 mt-0.5">
                          {detailUser.phone}
                        </p>
                      </div>
                      <div>
                        <p className="text-xs text-slate-400 font-medium">Foydalanuvchi roli</p>
                        <p className="text-sm font-semibold text-slate-900 mt-0.5">
                          {ROLE_LABELS[detailUser.role] ?? detailUser.role}
                        </p>
                      </div>
                      <div>
                        <p className="text-xs text-slate-400 font-medium">Holati</p>
                        <div className="mt-1">
                          <Badge className={statusBadgeClass(detailUser.isActive)}>
                            {detailUser.isActive ? "Faol" : "Nofaol"}
                          </Badge>
                        </div>
                      </div>
                      <div>
                        <p className="text-xs text-slate-400 font-medium">Tasdiqlangan</p>
                        <div className="mt-1">
                          <Badge className={verifiedBadgeClass(detailUser.isVerified)}>
                            {detailUser.isVerified ? "Tasdiqlangan" : "Tasdiqlanmagan"}
                          </Badge>
                        </div>
                      </div>
                      <div>
                        <p className="text-xs text-slate-400 font-medium">Ism / Familiya</p>
                        <p className="text-sm font-semibold text-slate-900 mt-0.5">
                          {detailUser.profile?.fullName || "Ma'lumot yo'q"}
                        </p>
                      </div>
                      <div>
                        <p className="text-xs text-slate-400 font-medium">Ro&apos;yxatdan o&apos;tgan sana</p>
                        <p className="text-sm font-semibold text-slate-900 mt-0.5">
                          {formatDateTime(detailUser.createdAt)}
                        </p>
                      </div>
                      <div className="col-span-1 md:col-span-2">
                        <p className="text-xs text-slate-400 font-medium">Manzil</p>
                        <p className="text-sm font-semibold text-slate-900 mt-0.5">
                          {[
                            detailUser.profile?.region?.nameUz,
                            detailUser.profile?.address
                          ]
                            .filter(Boolean)
                            .join(", ") || "Ma'lumot yo'q"}
                        </p>
                      </div>
                    </div>

                    {/* Stats Grid */}
                    <div>
                      <h4 className="text-sm font-semibold text-slate-900 mb-3">Statistika</h4>
                      <div className="grid grid-cols-3 gap-4">
                        <div className="border border-slate-100 rounded-lg p-3 text-center">
                          <p className="text-2xl font-bold text-slate-950">
                            {detailUser.stats.listingsCount}
                          </p>
                          <p className="text-xs text-slate-400 mt-1">E&apos;lonlar</p>
                        </div>
                        <div className="border border-slate-100 rounded-lg p-3 text-center">
                          <p className="text-2xl font-bold text-slate-950">
                            {detailUser.stats.complaintsCount}
                          </p>
                          <p className="text-xs text-slate-400 mt-1">Shikoyatlar</p>
                        </div>
                        <div className="border border-slate-100 rounded-lg p-3 text-center">
                          <p className="text-2xl font-bold text-slate-950">
                            {detailUser.stats.aiQuestionsCount}
                          </p>
                          <p className="text-xs text-slate-400 mt-1">AI savollar</p>
                        </div>
                      </div>
                    </div>

                    {/* Recent Listings */}
                    <div>
                      <h4 className="text-sm font-semibold text-slate-900 mb-3">Oxirgi e&apos;lonlar</h4>
                      {detailUser.recentListings.length === 0 ? (
                        <p className="text-xs text-slate-400 italic">E&apos;lonlar topilmadi</p>
                      ) : (
                        <div className="border border-slate-100 rounded-lg overflow-hidden">
                          <table className="min-w-full divide-y divide-slate-100 text-left text-xs">
                            <thead className="bg-slate-50 text-slate-500 font-medium uppercase">
                              <tr>
                                <th className="px-3 py-2">Sarlavha</th>
                                <th className="px-3 py-2">Status</th>
                                <th className="px-3 py-2">Yaratilgan</th>
                              </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100 text-slate-700 bg-white">
                              {detailUser.recentListings.map((l) => (
                                <tr key={l.id}>
                                  <td className="px-3 py-2 font-medium max-w-[200px] truncate">
                                    {l.title}
                                  </td>
                                  <td className="px-3 py-2">
                                    <span className="inline-flex rounded-full bg-slate-100 px-2 py-0.5 text-slate-800">
                                      {l.status}
                                    </span>
                                  </td>
                                  <td className="px-3 py-2 whitespace-nowrap">
                                    {formatDate(l.createdAt)}
                                  </td>
                                </tr>
                              ))}
                            </tbody>
                          </table>
                        </div>
                      )}
                    </div>

                    {/* Recent Complaints */}
                    <div>
                      <h4 className="text-sm font-semibold text-slate-900 mb-3">Yuborilgan shikoyatlar</h4>
                      {detailUser.recentComplaints.length === 0 ? (
                        <p className="text-xs text-slate-400 italic">Shikoyatlar topilmadi</p>
                      ) : (
                        <div className="border border-slate-100 rounded-lg overflow-hidden">
                          <table className="min-w-full divide-y divide-slate-100 text-left text-xs">
                            <thead className="bg-slate-50 text-slate-500 font-medium uppercase">
                              <tr>
                                <th className="px-3 py-2">Sabab</th>
                                <th className="px-3 py-2">Status</th>
                                <th className="px-3 py-2">Sana</th>
                              </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100 text-slate-700 bg-white">
                              {detailUser.recentComplaints.map((c) => (
                                <tr key={c.id}>
                                  <td className="px-3 py-2 font-medium">{c.reason}</td>
                                  <td className="px-3 py-2">
                                    <span className="inline-flex rounded-full bg-slate-100 px-2 py-0.5 text-slate-800">
                                      {c.status}
                                    </span>
                                  </td>
                                  <td className="px-3 py-2 whitespace-nowrap">
                                    {formatDate(c.createdAt)}
                                  </td>
                                </tr>
                              ))}
                            </tbody>
                          </table>
                        </div>
                      )}
                    </div>
                  </div>
                ) : null}
              </div>

              {/* Modal Footer */}
              <div className="flex justify-end gap-2 border-t border-slate-100 p-6 bg-slate-50">
                <Button type="button" variant="secondary" onClick={closeDetailModal}>
                  Yopish
                </Button>
              </div>
            </div>
          </div>
        )}
      </AdminShell>
    </ProtectedAdminRoute>
  );
}
