"use client";

import { FormEvent, useCallback, useEffect, useMemo, useState } from "react";
import { ProtectedAdminRoute } from "@/components/auth/ProtectedAdminRoute";
import { AdminShell } from "@/components/layout/AdminShell";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Input } from "@/components/ui/Input";
import { getAccessToken } from "@/lib/auth";
import {
  getAdminAiQuestionDetail,
  getAdminAiQuestions
} from "@/lib/ai-questions";
import type {
  AdminAiQuestion,
  AdminAiQuestionDetailResponse,
  AdminAiQuestionsQuery,
  AdminAiQuestionsResponse,
  AiQuestionStatus,
  UserRole
} from "@/types/api";

const DEFAULT_QUERY: AdminAiQuestionsQuery = {
  page: 1,
  limit: 10,
  status: "",
  search: ""
};

const statusOptions: Array<AiQuestionStatus | ""> = [
  "",
  "PENDING",
  "ANSWERED",
  "FAILED"
];

const statusLabels: Record<AiQuestionStatus, string> = {
  PENDING: "Kutilmoqda",
  ANSWERED: "Javob berilgan",
  FAILED: "Xatolik"
};

const statusClassNames: Record<AiQuestionStatus, string> = {
  PENDING: "bg-amber-50 text-amber-700 ring-amber-100",
  ANSWERED: "bg-emerald-50 text-emerald-700 ring-emerald-100",
  FAILED: "bg-red-50 text-red-700 ring-red-100"
};

const roleLabels: Record<UserRole, string> = {
  FARMER: "Dehqon/Fermer",
  LIVESTOCK_OWNER: "Chorvador",
  MACHINERY_OWNER: "Texnika egasi",
  BUYER: "Xaridor",
  AGRONOMIST: "Agronom",
  VETERINARIAN: "Veterinar",
  ADMIN: "Admin"
};

function formatStatusLabel(status: AiQuestionStatus) {
  return statusLabels[status] ?? status;
}

function formatRoleLabel(role?: UserRole | null) {
  return role ? roleLabels[role] ?? role : "Ma'lumot yo'q";
}

function formatDisclaimer(disclaimerShown: boolean) {
  return disclaimerShown ? "Ko'rsatilgan" : "Ko'rsatilmagan";
}

function formatDateTime(value?: string | null) {
  if (!value) {
    return "Ma'lumot yo'q";
  }

  return new Intl.DateTimeFormat("uz-UZ", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit"
  }).format(new Date(value));
}

function truncateText(value?: string | null, maxLength = 100) {
  if (!value) {
    return "Ma'lumot yo'q";
  }

  if (value.length <= maxLength) {
    return value;
  }

  return `${value.slice(0, maxLength).trimEnd()}...`;
}

function getUserName(question: AdminAiQuestion) {
  return question.user?.profile?.fullName || "Ma'lumot yo'q";
}

function getUserPhone(question: AdminAiQuestion) {
  return question.user?.phone || "Ma'lumot yo'q";
}

export default function AiQuestionsPage() {
  const [query, setQuery] = useState<AdminAiQuestionsQuery>(DEFAULT_QUERY);
  const [searchInput, setSearchInput] = useState("");
  const [response, setResponse] = useState<AdminAiQuestionsResponse | null>(
    null
  );
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [detailOpen, setDetailOpen] = useState(false);
  const [detailLoading, setDetailLoading] = useState(false);
  const [detailError, setDetailError] = useState<string | null>(null);
  const [detailResponse, setDetailResponse] =
    useState<AdminAiQuestionDetailResponse | null>(null);
  const [selectedQuestionId, setSelectedQuestionId] = useState<string | null>(
    null
  );

  const questions = response?.data ?? [];
  const meta = response?.meta;
  const detailQuestion = detailResponse?.data ?? null;

  const canGoPrevious = Boolean(meta && meta.page > 1);
  const canGoNext = Boolean(
    meta && meta.totalPages > 0 && meta.page < meta.totalPages
  );

  const loadQuestions = useCallback(
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
        const data = await getAdminAiQuestions(token, query);
        setResponse(data);
      } catch {
        setError("AI savollarni yuklashda xatolik yuz berdi");
      } finally {
        if (!options?.silent) {
          setLoading(false);
        }
      }
    },
    [query]
  );

  useEffect(() => {
    void loadQuestions();
  }, [loadQuestions]);

  const filterSummary = useMemo(() => {
    const parts = [
      query.status ? `Status: ${formatStatusLabel(query.status)}` : null,
      query.search ? `Qidiruv: ${query.search}` : null
    ].filter(Boolean);

    return parts.length > 0 ? parts.join(" | ") : "Barcha AI savollar";
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

  function updateStatus(status: AiQuestionStatus | "") {
    setQuery((current) => ({
      ...current,
      page: 1,
      status
    }));
  }

  function goToPage(page: number) {
    setQuery((current) => ({
      ...current,
      page
    }));
  }

  async function openDetail(questionId: string) {
    const token = getAccessToken();

    if (!token) {
      return;
    }

    setDetailOpen(true);
    setDetailLoading(true);
    setDetailError(null);
    setDetailResponse(null);
    setSelectedQuestionId(questionId);

    try {
      const data = await getAdminAiQuestionDetail(token, questionId);
      setDetailResponse(data);
    } catch {
      setDetailError("AI savol tafsilotlarini yuklashda xatolik yuz berdi");
    } finally {
      setDetailLoading(false);
    }
  }

  function closeDetail() {
    setDetailOpen(false);
    setDetailLoading(false);
    setDetailError(null);
    setDetailResponse(null);
    setSelectedQuestionId(null);
  }

  function renderUser(question: AdminAiQuestion) {
    return (
      <div>
        <p className="font-medium text-slate-900">{getUserName(question)}</p>
        <p className="text-xs text-slate-500">{getUserPhone(question)}</p>
        {question.user?.role ? (
          <p className="mt-1 text-xs text-slate-400">
            {formatRoleLabel(question.user.role)}
          </p>
        ) : null}
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
                AI savollar monitoringi
              </p>
              <h1 className="mt-1 text-2xl font-semibold tracking-normal text-slate-950">
                AI savollar
              </h1>
              <p className="mt-2 max-w-2xl text-sm text-slate-500">
                Foydalanuvchilar yuborgan AI maslahat savollarini kuzatish.
              </p>
            </div>
          </div>

          <Card>
            <div className="grid gap-4 lg:grid-cols-[220px_1fr_auto] lg:items-end">
              <label className="block">
                <span className="mb-2 block text-sm font-medium text-slate-700">
                  Status
                </span>
                <select
                  className="block min-h-11 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm text-slate-950 outline-none transition focus:border-field-600 focus:ring-2 focus:ring-field-100"
                  value={query.status}
                  onChange={(event) =>
                    updateStatus(event.target.value as AiQuestionStatus | "")
                  }
                >
                  {statusOptions.map((status) => (
                    <option key={status || "all"} value={status}>
                      {status ? formatStatusLabel(status) : "Barchasi"}
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
                  placeholder="Savol yoki javob bo'yicha qidiruv"
                  value={searchInput}
                  onChange={(event) => setSearchInput(event.target.value)}
                />
                <Button type="submit">Qidirish</Button>
                <Button
                  type="button"
                  variant="secondary"
                  onClick={handleClearFilters}
                >
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
                onClick={() => void loadQuestions()}
              >
                Qayta urinish
              </Button>
            </Card>
          ) : null}

          <Card className="overflow-hidden p-0">
            {loading ? (
              <div className="p-5 text-sm text-slate-500">Yuklanmoqda...</div>
            ) : questions.length === 0 && !error ? (
              <div className="p-6">
                <p className="text-sm font-semibold text-slate-900">
                  AI savollar topilmadi
                </p>
                <p className="mt-1 text-sm text-slate-500">
                  Filterlarni tozalab qayta urinib ko&apos;ring.
                </p>
                <button
                  type="button"
                  className="mt-3 text-sm font-medium text-field-700 underline-offset-2 hover:underline"
                  onClick={handleClearFilters}
                >
                  Filterlarni tozalash
                </button>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-slate-200 text-left text-sm">
                  <thead className="bg-slate-50 text-xs font-semibold uppercase tracking-wide text-slate-500">
                    <tr>
                      <th className="px-4 py-3">Savol</th>
                      <th className="px-4 py-3">Status</th>
                      <th className="px-4 py-3">Javob</th>
                      <th className="px-4 py-3">Foydalanuvchi</th>
                      <th className="px-4 py-3">Disclaimer</th>
                      <th className="px-4 py-3">Sana</th>
                      <th className="px-4 py-3">Amal</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 bg-white">
                    {questions.map((question) => (
                      <tr key={question.id} className="align-top">
                        <td className="max-w-sm px-4 py-3">
                          <p className="font-medium text-slate-950">
                            {truncateText(question.question, 110)}
                          </p>
                        </td>
                        <td className="px-4 py-3">
                          <Badge className={statusClassNames[question.status]}>
                            {formatStatusLabel(question.status)}
                          </Badge>
                        </td>
                        <td className="max-w-sm px-4 py-3 text-slate-600">
                          {truncateText(question.answer, 100)}
                        </td>
                        <td className="px-4 py-3 text-slate-700">
                          {renderUser(question)}
                        </td>
                        <td className="px-4 py-3 text-slate-700">
                          {formatDisclaimer(question.disclaimerShown)}
                        </td>
                        <td className="px-4 py-3 text-slate-700 whitespace-nowrap">
                          {formatDateTime(question.createdAt)}
                        </td>
                        <td className="px-4 py-3">
                          <Button
                            type="button"
                            variant="secondary"
                            className="min-h-9 px-3"
                            disabled={
                              detailLoading && selectedQuestionId === question.id
                            }
                            onClick={() => void openDetail(question.id)}
                          >
                            {detailLoading && selectedQuestionId === question.id
                              ? "Yuklanmoqda..."
                              : "Ko'rish"}
                          </Button>
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

        {detailOpen ? (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/40 px-4 py-6">
            <div className="max-h-[90vh] w-full max-w-3xl overflow-y-auto rounded-lg bg-white shadow-xl">
              <div className="flex items-start justify-between gap-4 border-b border-slate-200 px-5 py-4">
                <div>
                  <p className="text-sm font-medium text-field-700">
                    AI savol tafsiloti
                  </p>
                  <h2 className="mt-1 text-lg font-semibold text-slate-950">
                    Batafsil ko&apos;rish
                  </h2>
                </div>
                <Button type="button" variant="secondary" onClick={closeDetail}>
                  Yopish
                </Button>
              </div>

              <div className="space-y-5 px-5 py-5">
                {detailLoading ? (
                  <p className="text-sm text-slate-500">Yuklanmoqda...</p>
                ) : null}

                {detailError ? (
                  <div className="rounded-lg border border-red-200 bg-red-50 p-4">
                    <p className="text-sm font-medium text-red-700">
                      {detailError}
                    </p>
                    {selectedQuestionId ? (
                      <Button
                        type="button"
                        variant="secondary"
                        className="mt-3"
                        onClick={() => void openDetail(selectedQuestionId)}
                      >
                        Qayta urinish
                      </Button>
                    ) : null}
                  </div>
                ) : null}

                {detailQuestion ? (
                  <>
                    <div>
                      <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">
                        Savol
                      </p>
                      <p className="mt-2 whitespace-pre-wrap text-sm leading-6 text-slate-900">
                        {detailQuestion.question || "Ma'lumot yo'q"}
                      </p>
                    </div>

                    <div>
                      <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">
                        Javob
                      </p>
                      <p className="mt-2 whitespace-pre-wrap text-sm leading-6 text-slate-900">
                        {detailQuestion.answer || "Javob hali yo'q"}
                      </p>
                    </div>

                    <div className="grid gap-4 sm:grid-cols-2">
                      <div>
                        <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">
                          Status
                        </p>
                        <Badge
                          className={[
                            "mt-2",
                            statusClassNames[detailQuestion.status]
                          ].join(" ")}
                        >
                          {formatStatusLabel(detailQuestion.status)}
                        </Badge>
                      </div>
                      <div>
                        <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">
                          Disclaimer
                        </p>
                        <p className="mt-2 text-sm text-slate-900">
                          {formatDisclaimer(detailQuestion.disclaimerShown)}
                        </p>
                      </div>
                      <div>
                        <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">
                          Yaratilgan
                        </p>
                        <p className="mt-2 text-sm text-slate-900">
                          {formatDateTime(detailQuestion.createdAt)}
                        </p>
                      </div>
                      <div>
                        <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">
                          Yangilangan
                        </p>
                        <p className="mt-2 text-sm text-slate-900">
                          {formatDateTime(detailQuestion.updatedAt)}
                        </p>
                      </div>
                    </div>

                    <div className="rounded-lg border border-slate-200 bg-slate-50 p-4">
                      <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">
                        Foydalanuvchi
                      </p>
                      <div className="mt-3 grid gap-3 text-sm text-slate-900 sm:grid-cols-2">
                        <p>
                          <span className="block text-xs text-slate-500">
                            Telefon
                          </span>
                          {detailQuestion.user?.phone || "Ma'lumot yo'q"}
                        </p>
                        <p>
                          <span className="block text-xs text-slate-500">
                            Rol
                          </span>
                          {formatRoleLabel(detailQuestion.user?.role)}
                        </p>
                        <p>
                          <span className="block text-xs text-slate-500">
                            Ism
                          </span>
                          {detailQuestion.user?.profile?.fullName ||
                            "Ma'lumot yo'q"}
                        </p>
                        <p>
                          <span className="block text-xs text-slate-500">
                            Manzil
                          </span>
                          {detailQuestion.user?.profile?.address ||
                            "Ma'lumot yo'q"}
                        </p>
                      </div>
                    </div>
                  </>
                ) : null}
              </div>
            </div>
          </div>
        ) : null}
      </AdminShell>
    </ProtectedAdminRoute>
  );
}
