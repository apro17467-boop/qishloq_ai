class Region {
  final String id;
  final String nameUz;
  final String? nameRu;
  final String? type;
  final String? parentId;

  Region({
    required this.id,
    required this.nameUz,
    this.nameRu,
    this.type,
    this.parentId,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] as String? ?? '',
      nameUz: json['nameUz'] as String? ?? '',
      nameRu: json['nameRu'] as String?,
      type: json['type'] as String?,
      parentId: json['parentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameUz': nameUz,
      'nameRu': nameRu,
      'type': type,
      'parentId': parentId,
    };
  }
}
