import { apiBaseUrl } from "@/lib/env";
import type { ApiErrorResponse } from "@/types/api";

export { apiBaseUrl };

type HttpMethod = "GET" | "POST";

function normalizePath(path: string) {
  return path.startsWith("/") ? path : `/${path}`;
}

function buildHeaders(token?: string): Record<string, string> {
  const headers: Record<string, string> = {
    Accept: "application/json"
  };

  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  return headers;
}

async function readErrorMessage(response: Response) {
  const fallbackMessage = `API request failed with status ${response.status}`;

  try {
    const payload = (await response.json()) as Partial<ApiErrorResponse>;
    const message = payload.error?.message || fallbackMessage;
    const details = payload.error?.details;

    if (Array.isArray(details) && details.length > 0) {
      return `${message}: ${details.join(", ")}`;
    }

    return message;
  } catch {
    return fallbackMessage;
  }
}

async function request<TResponse, TBody = undefined>(
  method: HttpMethod,
  path: string,
  body?: TBody,
  token?: string
): Promise<TResponse> {
  const normalizedPath = path.startsWith("/") ? path : `/${path}`;
  const headers = buildHeaders(token);

  if (body !== undefined) {
    headers["Content-Type"] = "application/json";
  }

  const response = await fetch(`${apiBaseUrl}${normalizedPath}`, {
    method,
    headers,
    body: body !== undefined ? JSON.stringify(body) : undefined
  });

  if (!response.ok) {
    throw new Error(await readErrorMessage(response));
  }

  return response.json() as Promise<TResponse>;
}

export async function apiGet<TResponse>(
  path: string,
  token?: string
): Promise<TResponse> {
  return request<TResponse>("GET", normalizePath(path), undefined, token);
}

export async function apiPost<TResponse, TBody>(
  path: string,
  body: TBody,
  token?: string
): Promise<TResponse> {
  return request<TResponse, TBody>("POST", normalizePath(path), body, token);
}
