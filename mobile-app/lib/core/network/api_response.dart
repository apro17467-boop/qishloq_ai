class PaginatedMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginatedMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginatedMeta.fromJson(Map<String, dynamic> json) {
    return PaginatedMeta(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> data;
  final PaginatedMeta meta;

  const PaginatedResponse({
    required this.data,
    required this.meta,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    final list = json['data'] as List<dynamic>? ?? [];
    final items = list.map((item) => fromJsonT(item as Map<String, dynamic>)).toList();
    final metaData = json['meta'] as Map<String, dynamic>? ?? {};

    return PaginatedResponse(
      data: items,
      meta: PaginatedMeta.fromJson(metaData),
    );
  }
}
