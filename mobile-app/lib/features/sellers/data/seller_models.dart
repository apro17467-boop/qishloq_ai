class SellerRegion {
  final String id;
  final String nameUz;

  SellerRegion({required this.id, required this.nameUz});

  factory SellerRegion.fromJson(Map<String, dynamic> json) {
    return SellerRegion(
      id: json['id'] as String? ?? '',
      nameUz: json['nameUz'] as String? ?? '',
    );
  }
}

class SellerProfile {
  final String id;
  final String? fullName;
  final String role;
  final SellerRegion? region;
  final String? address;
  final bool isVerified;
  final int activeListingsCount;
  final String createdAt;

  SellerProfile({
    required this.id,
    this.fullName,
    required this.role,
    this.region,
    this.address,
    required this.isVerified,
    required this.activeListingsCount,
    required this.createdAt,
  });

  factory SellerProfile.fromJson(Map<String, dynamic> json) {
    return SellerProfile(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String?,
      role: json['role'] as String? ?? '',
      region: json['region'] != null
          ? SellerRegion.fromJson(json['region'] as Map<String, dynamic>)
          : null,
      address: json['address'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      activeListingsCount: json['activeListingsCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

extension SellerProfileHelpers on SellerProfile {
  String get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return 'Foydalanuvchi';
  }

  String get roleLabel {
    switch (role) {
      case 'FARMER':
        return 'Fermer';
      case 'LIVESTOCK_OWNER':
        return 'Chorvador';
      case 'MACHINERY_OWNER':
        return 'Texnika egasi';
      case 'BUYER':
        return 'Xaridor';
      case 'AGRONOMIST':
        return 'Agronom';
      case 'VETERINARIAN':
        return 'Veterinar';
      case 'ADMIN':
        return 'Admin';
      default:
        return role.isEmpty ? 'Foydalanuvchi' : role;
    }
  }

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'F';
    }
    if (parts.length == 1) {
      return _firstLetter(parts.first).toUpperCase();
    }
    return '${_firstLetter(parts[0])}${_firstLetter(parts[1])}'.toUpperCase();
  }

  String get joinedDate {
    try {
      final dateTime = DateTime.parse(createdAt).toLocal();
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      return '$day.$month.$year';
    } catch (_) {
      return createdAt;
    }
  }

  String _firstLetter(String value) {
    if (value.isEmpty) {
      return '';
    }
    return value.substring(0, 1);
  }
}
