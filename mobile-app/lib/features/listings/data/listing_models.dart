import 'package:qishloq_ai_mobile/core/network/api_response.dart';

class ListingImage {
  final String id;
  final String url;
  final int? sortOrder;

  ListingImage({
    required this.id,
    required this.url,
    this.sortOrder,
  });

  factory ListingImage.fromJson(Map<String, dynamic> json) {
    return ListingImage(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      sortOrder: json['sortOrder'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'sortOrder': sortOrder,
    };
  }
}

class ListingCategory {
  final String id;
  final String nameUz;
  final String? slug;

  ListingCategory({
    required this.id,
    required this.nameUz,
    this.slug,
  });

  factory ListingCategory.fromJson(Map<String, dynamic> json) {
    return ListingCategory(
      id: json['id'] as String? ?? '',
      nameUz: json['nameUz'] as String? ?? '',
      slug: json['slug'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameUz': nameUz,
      'slug': slug,
    };
  }
}

class ListingRegion {
  final String id;
  final String nameUz;

  ListingRegion({
    required this.id,
    required this.nameUz,
  });

  factory ListingRegion.fromJson(Map<String, dynamic> json) {
    return ListingRegion(
      id: json['id'] as String? ?? '',
      nameUz: json['nameUz'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameUz': nameUz,
    };
  }
}

class Listing {
  final String id;
  final String type;
  final String status;
  final String title;
  final String? description;
  final String? priceAmount;
  final String? priceCurrency;
  final String? unit;
  final String? contactPhone;
  final String? address;
  final String createdAt;
  final String? updatedAt;
  final ListingCategory? category;
  final ListingRegion? region;
  final List<ListingImage>? images;

  Listing({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    this.description,
    this.priceAmount,
    this.priceCurrency,
    this.unit,
    this.contactPhone,
    this.address,
    required this.createdAt,
    this.updatedAt,
    this.category,
    this.region,
    this.images,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    List<ListingImage>? imagesList;
    if (json['images'] != null) {
      final list = json['images'] as List<dynamic>;
      imagesList = list.map((item) => ListingImage.fromJson(item as Map<String, dynamic>)).toList();
    }

    return Listing(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      priceAmount: json['priceAmount']?.toString(),
      priceCurrency: json['priceCurrency'] as String?,
      unit: json['unit'] as String?,
      contactPhone: json['contactPhone'] as String?,
      address: json['address'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
      category: json['category'] != null ? ListingCategory.fromJson(json['category'] as Map<String, dynamic>) : null,
      region: json['region'] != null ? ListingRegion.fromJson(json['region'] as Map<String, dynamic>) : null,
      images: imagesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'title': title,
      'description': description,
      'priceAmount': priceAmount,
      'priceCurrency': priceCurrency,
      'unit': unit,
      'contactPhone': contactPhone,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'category': category?.toJson(),
      'region': region?.toJson(),
      'images': images?.map((x) => x.toJson()).toList(),
    };
  }
}

class ListingListResponse {
  final List<Listing> data;
  final PaginatedMeta meta;

  ListingListResponse({
    required this.data,
    required this.meta,
  });

  factory ListingListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    final items = list.map((item) => Listing.fromJson(item as Map<String, dynamic>)).toList();
    final metaData = json['meta'] as Map<String, dynamic>? ?? {};

    return ListingListResponse(
      data: items,
      meta: PaginatedMeta.fromJson(metaData),
    );
  }
}

extension ListingHelpers on Listing {
  String get typeLabel {
    switch (type) {
      case 'MACHINERY_RENT':
        return 'Texnika ijarasi';
      case 'PRODUCT_SALE':
        return 'Dehqon mahsulotlari';
      case 'LIVESTOCK_SALE':
        return 'Chorva savdosi';
      case 'MACHINERY_SALE':
        return 'Texnika savdosi';
      case 'SERVICE':
        return 'Agro xizmatlar';
      default:
        return type;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'ACTIVE':
        return 'Faol';
      case 'PENDING':
        return 'Kutilmoqda';
      case 'REJECTED':
        return 'Rad etilgan';
      case 'ARCHIVED':
        return 'Arxivda';
      default:
        return status;
    }
  }

  String get formattedPrice {
    if (priceAmount == null || priceAmount!.isEmpty) {
      return 'Narx kelishiladi';
    }
    final currency = priceCurrency ?? 'UZS';
    if (unit == null || unit!.isEmpty) {
      return '$priceAmount $currency';
    }
    return '$priceAmount $currency / $unit';
  }

  String get formattedDate {
    try {
      final dateTime = DateTime.parse(createdAt).toLocal();
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day.$month.$year $hour:$minute';
    } catch (_) {
      return createdAt;
    }
  }
}
