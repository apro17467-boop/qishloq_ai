"use client";

import { FormEvent, useCallback, useEffect, useMemo, useState } from "react";
import { ProtectedAdminRoute } from "@/components/auth/ProtectedAdminRoute";
import { AdminShell } from "@/components/layout/AdminShell";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Input } from "@/components/ui/Input";
import { getAccessToken } from "@/lib/auth";
import { getAdminListings, moderateListing } from "@/lib/listings";
import type {
  AdminListing,
  AdminListingsQuery,
  AdminListingsResponse,
  ListingStatus,
  ModerateListingStatus,
  ListingType
} from "@/types/api";

const DEFAULT_QUERY: AdminListingsQuery = {
  page: 1,
  limit: 10,
  status: "",
  type: "",
  search: ""
};

const statusOptions: Array<ListingStatus | ""> = [
  "",
  "PENDING",
  "ACTIVE",
  "REJECTED",
  "ARCHIVED"
];

const typeOptions: Array<ListingType | ""> = [
  "",
  "MACHINERY_RENT",
  "PRODUCT_SALE",
  "LIVESTOCK_SALE",
  "MACHINERY_SALE",
  "SERVICE"
];

const statusClassNames: Record<ListingStatus, string> = {
  PENDING: "bg-amber-50 text-amber-700 ring-amber-100",
  ACTIVE: "bg-field-100 text-field-700 ring-field-100",
  REJECTED: "bg-red-50 text-red-700 ring-red-100",
  ARCHIVED: "bg-slate-100 text-slate-600 ring-slate-200"
};

const typeLabels: Record<ListingType, string> = {
  MACHINERY_RENT: "Texnika ijarasi",
  PRODUCT_SALE: "Dehqon mahsulotlari",
  LIVESTOCK_SALE: "Chorva savdosi",
  MACHINERY_SALE: "Texnika savdosi",
  SERVICE: "Agro xizmatlar"
};

const finalizedStatusLabels: Record<Exclude<ListingStatus, "PENDING">, string> = {
  ACTIVE: "Tasdiqlangan",
  REJECTED: "Rad etilgan",
  ARCHIVED: "Arxivda"
};

function formatTypeLabel(type: ListingType) {
  return typeLabels[type] ?? type;
}

function formatPrice(listing: AdminListing) {
  if (!listing.priceAmount) {
    return "Kelishiladi";
  }

  return [listing.priceAmount, listing.priceCurrency, listing.unit]
    .filter(Boolean)
    .join(" / ");
}

function formatDate(value: string) {
  return new Intl.DateTimeFormat("uz-UZ", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit"
  }).format(new Date(value));
}

export default function ListingsPage() {
  const [query, setQuery] = useState<AdminListingsQuery>(DEFAULT_QUERY);
  const [searchInput, setSearchInput] = useState("");
  const [response, setResponse] = useState<AdminListingsResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [moderationError, setModerationError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [moderatingListingId, setModeratingListingId] = useState<string | null>(
    null
  );

  const listings = response?.data ?? [];
  const meta = response?.meta;

  const canGoPrevious = Boolean(meta && meta.page > 1);
  const canGoNext = Boolean(meta && meta.totalPages > 0 && meta.page < meta.totalPages);

  const loadListings = useCallback(async (options?: { silent?: boolean }) => {
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
      const data = await getAdminListings(token, query);
      setResponse(data);
    } catch {
      setError("E'lonlarni yuklashda xatolik yuz berdi");
    } finally {
      if (!options?.silent) {
        setLoading(false);
      }
    }
  }, [query]);

  useEffect(() => {
    void loadListings();
  }, [loadListings]);

  const filterSummary = useMemo(() => {
    const parts = [
      query.status ? `Status: ${query.status}` : null,
      query.type ? `Tur: ${formatTypeLabel(query.type)}` : null,
      query.search ? `Qidiruv: ${query.search}` : null
    ].filter(Boolean);

    return parts.length > 0 ? parts.join(" | ") : "Barcha e'lonlar";
  }, [query]);

  function handleSearch(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setQuery((current) => ({
      ...current,
      page: 1,
      search: searchInput.trim()
    }));
  }

  function handleClearFilters() {
    setSearchInput("");
    setQuery(DEFAULT_QUERY);
  }

  function updateStatus(status: ListingStatus | "") {
    setQuery((current) => ({
      ...current,
      page: 1,
      status
    }));
  }

  function updateType(type: ListingType | "") {
    setQuery((current) => ({
      ...current,
      page: 1,
      type
    }));
  }

  function goToPage(page: number) {
    setQuery((current) => ({
      ...current,
      page
    }));
  }

  async function handleModerateListing(
    listing: AdminListing,
    status: ModerateListingStatus
  ) {
    const token = getAccessToken();

    if (!token) {
      setModerationError("Moderatsiya bajarilmadi: token topilmadi");
      return;
    }

    const confirmed = window.confirm(
      status === "ACTIVE"
        ? `"${listing.title}" e'lonini tasdiqlaysizmi?`
        : `"${listing.title}" e'lonini rad etasizmi?`
    );

    if (!confirmed) {
      return;
    }

    setModeratingListingId(listing.id);
    setModerationError(null);
    setSuccessMessage(null);

    try {
      await moderateListing(token, listing.id, { status });
      setSuccessMessage(
        status === "ACTIVE" ? "E'lon tasdiqlandi" : "E'lon rad etildi"
      );
      await loadListings({ silent: true });
    } catch (caughtError) {
      const message =
        caughtError instanceof Error
          ? caughtError.message
          : "Noma'lum xatolik yuz berdi";
      setModerationError(`Moderatsiya bajarilmadi: ${message}`);
    } finally {
      setModeratingListingId(null);
    }
  }

  function renderModerationAction(listing: AdminListing) {
    const isModerating = moderatingListingId === listing.id;

    if (listing.status !== "PENDING") {
      return (
        <span className="text-xs font-medium text-slate-500">
          {finalizedStatusLabels[listing.status]}
        </span>
      );
    }

    return (
      <div className="flex flex-col gap-2">
        <Button
          type="button"
          className="min-h-9 px-3"
          disabled={isModerating}
          onClick={() => void handleModerateListing(listing, "ACTIVE")}
        >
          {isModerating ? "Kutilmoqda..." : "Tasdiqlash"}
        </Button>
        <Button
          type="button"
          variant="secondary"
          className="min-h-9 px-3"
          disabled={isModerating}
          onClick={() => void handleModerateListing(listing, "REJECTED")}
        >
          Rad etish
        </Button>
      </div>
    );
  }

  return (
    <ProtectedAdminRoute>
      <AdminShell>
        <div className="space-y-6">
          <div className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <p className="text-sm font-medium text-field-700">
                E&apos;lonlar boshqaruvi
              </p>
              <h1 className="mt-1 text-2xl font-semibold tracking-normal text-slate-950">
                E&apos;lonlar
              </h1>
              <p className="mt-2 max-w-2xl text-sm text-slate-500">
                Foydalanuvchilar joylagan e&apos;lonlarni ko&apos;rish va
                moderatsiyaga tayyorlash.
              </p>
            </div>
          </div>

          <Card>
            <div className="grid gap-4 lg:grid-cols-[180px_220px_1fr_auto] lg:items-end">
              <label className="block">
                <span className="mb-2 block text-sm font-medium text-slate-700">
                  Status
                </span>
                <select
                  className="block min-h-11 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm text-slate-950 outline-none transition focus:border-field-600 focus:ring-2 focus:ring-field-100"
                  value={query.status}
                  onChange={(event) =>
                    updateStatus(event.target.value as ListingStatus | "")
                  }
                >
                  {statusOptions.map((status) => (
                    <option key={status || "all"} value={status}>
                      {status || "Barchasi"}
                    </option>
                  ))}
                </select>
              </label>

              <label className="block">
                <span className="mb-2 block text-sm font-medium text-slate-700">
                  Turi
                </span>
                <select
                  className="block min-h-11 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm text-slate-950 outline-none transition focus:border-field-600 focus:ring-2 focus:ring-field-100"
                  value={query.type}
                  onChange={(event) =>
                    updateType(event.target.value as ListingType | "")
                  }
                >
                  {typeOptions.map((type) => (
                    <option key={type || "all"} value={type}>
                      {type ? formatTypeLabel(type) : "Barchasi"}
                    </option>
                  ))}
                </select>
              </label>

              <form
                className="grid gap-3 sm:grid-cols-[1fr_auto_auto] sm:items-end"
                onSubmit={handleSearch}
              >
                <Input
                  label="Qidiruv"
                  placeholder="Sarlavha yoki umumiy qidiruv"
                  value={searchInput}
                  onChange={(event) => setSearchInput(event.target.value)}
                />
                <Button type="submit">Qidirish</Button>
                <Button type="button" variant="secondary" onClick={handleClearFilters}>
                  Tozalash
                </Button>
              </form>

              <div className="text-sm text-slate-500 lg:text-right">
                {filterSummary}
              </div>
            </div>
          </Card>

          {error ? (
            <Card className="flex flex-col gap-4 border-red-200 bg-red-50 sm:flex-row sm:items-center sm:justify-between">
              <p className="text-sm font-medium text-red-700">{error}</p>
              <Button
                type="button"
                variant="secondary"
                onClick={() => void loadListings()}
              >
                Qayta urinish
              </Button>
            </Card>
          ) : null}

          {moderationError ? (
            <Card className="border-red-200 bg-red-50">
              <p className="text-sm font-medium text-red-700">
                {moderationError}
              </p>
            </Card>
          ) : null}

          {successMessage ? (
            <Card className="border-field-100 bg-field-50">
              <p className="text-sm font-medium text-field-700">
                {successMessage}
              </p>
            </Card>
          ) : null}

          <Card className="overflow-hidden p-0">
            {loading ? (
              <div className="p-5 text-sm text-slate-500">Yuklanmoqda...</div>
            ) : listings.length === 0 && !error ? (
              <div className="p-5">
                <p className="text-sm font-semibold text-slate-900">
                  E&apos;lonlar topilmadi
                </p>
                <p className="mt-1 text-sm text-slate-500">
                  Filterlarni tozalab qayta urinib ko&apos;ring.
                </p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-slate-200 text-left text-sm">
                  <thead className="bg-slate-50 text-xs font-semibold uppercase text-slate-500">
                    <tr>
                      <th className="px-4 py-3">Sarlavha</th>
                      <th className="px-4 py-3">Turi</th>
                      <th className="px-4 py-3">Status</th>
                      <th className="px-4 py-3">Narx</th>
                      <th className="px-4 py-3">Hudud</th>
                      <th className="px-4 py-3">Egasi</th>
                      <th className="px-4 py-3">Sana</th>
                      <th className="px-4 py-3">Amal</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 bg-white">
                    {listings.map((listing) => (
                      <tr key={listing.id} className="align-top">
                        <td className="max-w-xs px-4 py-3">
                          <p className="font-medium text-slate-950">{listing.title}</p>
                          {listing.description ? (
                            <p className="mt-1 line-clamp-2 text-xs text-slate-500">
                              {listing.description}
                            </p>
                          ) : null}
                        </td>
                        <td className="px-4 py-3 text-slate-700">
                          {formatTypeLabel(listing.type)}
                        </td>
                        <td className="px-4 py-3">
                          <Badge className={statusClassNames[listing.status]}>
                            {listing.status}
                          </Badge>
                        </td>
                        <td className="px-4 py-3 text-slate-700">
                          {formatPrice(listing)}
                        </td>
                        <td className="px-4 py-3 text-slate-700">
                          {listing.region?.nameUz ?? listing.address ?? "-"}
                        </td>
                        <td className="px-4 py-3 text-slate-700">
                          <p>{listing.owner?.profile?.fullName ?? "Noma'lum"}</p>
                          <p className="text-xs text-slate-500">
                            {listing.owner?.phone ?? "-"}
                          </p>
                        </td>
                        <td className="px-4 py-3 text-slate-700">
                          {formatDate(listing.createdAt)}
                        </td>
                        <td className="px-4 py-3">
                          {renderModerationAction(listing)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </Card>

          <div className="flex flex-col gap-3 text-sm text-slate-600 sm:flex-row sm:items-center sm:justify-between">
            <p>
              Jami: {meta?.total ?? 0} ta | Sahifa {meta?.page ?? query.page} /{" "}
              {meta?.totalPages ?? 0}
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
      </AdminShell>
    </ProtectedAdminRoute>
  );
}
