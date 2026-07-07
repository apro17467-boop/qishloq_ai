import { apiGet } from "@/lib/api";
import type {
  AdminAiQuestionDetailResponse,
  AdminAiQuestionsQuery,
  AdminAiQuestionsResponse
} from "@/types/api";

function buildAdminAiQuestionsPath(query: AdminAiQuestionsQuery) {
  const params = new URLSearchParams({
    page: String(query.page),
    limit: String(query.limit)
  });

  if (query.status) {
    params.set("status", query.status);
  }

  if (query.userId) {
    params.set("userId", query.userId);
  }

  const search = query.search?.trim();
  if (search) {
    params.set("search", search);
  }

  return `/admin/ai-questions?${params.toString()}`;
}

export function getAdminAiQuestions(
  token: string,
  query: AdminAiQuestionsQuery
): Promise<AdminAiQuestionsResponse> {
  return apiGet<AdminAiQuestionsResponse>(
    buildAdminAiQuestionsPath(query),
    token
  );
}

export function getAdminAiQuestionDetail(
  token: string,
  questionId: string
): Promise<AdminAiQuestionDetailResponse> {
  return apiGet<AdminAiQuestionDetailResponse>(
    `/admin/ai-questions/${questionId}`,
    token
  );
}
