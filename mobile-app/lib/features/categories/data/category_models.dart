class Category {
  final String id;
  final String nameUz;
  final String? nameRu;
  final String slug;
  final String type;
  final bool isActive;

  Category({
    required this.id,
    required this.nameUz,
    this.nameRu,
    required this.slug,
    required this.type,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      nameUz: json['nameUz'] as String? ?? '',
      nameRu: json['nameRu'] as String?,
      slug: json['slug'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameUz': nameUz,
      'nameRu': nameRu,
      'slug': slug,
      'type': type,
      'isActive': isActive,
    };
  }
}
