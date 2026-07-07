import { apiGet, apiPatch } from "@/lib/api";
import type {
  AdminListing,
  AdminListingsQuery,
  AdminListingsResponse,
  ListingStatus,
  ModerateListingRequest,
  ModerateListingResponse
} from "@/types/api";

const ALL_STATUSES: ListingStatus[] = [
  "PENDING",
  "ACTIVE",
  "REJECTED",
  "ARCHIVED"
];
const MAX_BACKEND_LIMIT = 50;

function buildListingsPath(query: AdminListingsQuery, includeSearch = true) {
  const params = new URLSearchParams({
    page: String(query.page),
    limit: String(query.limit)
  });

  if (query.status) {
    params.set("status", query.status);
  }

  if (query.type) {
    params.set("type", query.type);
  }

  const search = query.search?.trim();
  if (includeSearch && search) {
    params.set("search", search);
  }

  return `/admin/listings?${params.toString()}`;
}

function buildStatusListingsQuery(
  query: AdminListingsQuery,
  status: ListingStatus,
  page: number
): AdminListingsQuery {
  return {
    ...query,
    page,
    limit: MAX_BACKEND_LIMIT,
    status,
    search: ""
  };
}

function isUnsupportedSearchError(error: unknown) {
  return (
    error instanceof Error &&
    (error.message.includes("property search should not exist") ||
      error.message.includes("search should not exist"))
  );
}

function listingMatchesSearch(listing: AdminListing, search: string) {
  const value = search.trim().toLowerCase();

  if (!value) {
    return true;
  }

  return [
    listing.title,
    listing.description,
    listing.category?.nameUz,
    listing.region?.nameUz,
    listing.owner?.phone,
    listing.owner?.profile?.fullName,
    listing.address
  ]
    .filter(Boolean)
    .some((field) => String(field).toLowerCase().includes(value));
}

async function getAdminListingsWithClientSearchFallback(
  token: string,
  query: AdminListingsQuery
): Promise<AdminListingsResponse> {
  const search = query.search?.trim() ?? "";
  const response = await getAdminListingsFromStatuses(token, query);
  const filteredListings = search
    ? response.data.filter((listing) => listingMatchesSearch(listing, search))
    : response.data;

  return paginateListings(filteredListings, query);
}

function paginateListings(
  listings: AdminListing[],
  query: AdminListingsQuery
): AdminListingsResponse {
  const start = (query.page - 1) * query.limit;
  const data = listings.slice(start, start + query.limit);

  return {
    data,
    meta: {
      page: query.page,
      limit: query.limit,
      total: listings.length,
      totalPages: listings.length === 0 ? 0 : Math.ceil(listings.length / query.limit)
    }
  };
}

async function getListingsForStatus(
  token: string,
  query: AdminListingsQuery,
  status: ListingStatus
) {
  const firstPage = await apiGet<AdminListingsResponse>(
    buildListingsPath(buildStatusListingsQuery(query, status, 1), false),
    token
  );
  const listings = [...firstPage.data];
  const totalPages = firstPage.meta.totalPages;

  for (let page = 2; page <= totalPages; page += 1) {
    const response = await apiGet<AdminListingsResponse>(
      buildListingsPath(buildStatusListingsQuery(query, status, page), false),
      token
    );
    listings.push(...response.data);
  }

  return listings;
}

async function getAdminListingsFromStatuses(
  token: string,
  query: AdminListingsQuery
) {
  const statuses = query.status ? [query.status] : ALL_STATUSES;
  const listingsByStatus = await Promise.all(
    statuses.map((status) => getListingsForStatus(token, query, status))
  );

  return {
    data: listingsByStatus
      .flat()
      .sort(
        (left, right) =>
          new Date(right.createdAt).getTime() - new Date(left.createdAt).getTime()
      ),
    meta: {
      page: 1,
      limit: MAX_BACKEND_LIMIT,
      total: listingsByStatus.flat().length,
      totalPages: 1
    }
  } satisfies AdminListingsResponse;
}

export async function getAdminListings(
  token: string,
  query: AdminListingsQuery
): Promise<AdminListingsResponse> {
  if (!query.status) {
    try {
      await apiGet<AdminListingsResponse>(buildListingsPath(query), token);
    } catch (error) {
      if (!isUnsupportedSearchError(error)) {
        throw error;
      }
    }

    return getAdminListingsWithClientSearchFallback(token, query);
  }

  try {
    return await apiGet<AdminListingsResponse>(buildListingsPath(query), token);
  } catch (error) {
    if (query.search?.trim() && isUnsupportedSearchError(error)) {
      return getAdminListingsWithClientSearchFallback(token, query);
    }

    throw error;
  }
}

export function moderateListing(
  token: string,
  listingId: string,
  body: ModerateListingRequest
): Promise<ModerateListingResponse> {
  return apiPatch<ModerateListingResponse, ModerateListingRequest>(
    `/admin/listings/${listingId}/moderate`,
    body,
    token
  );
}
