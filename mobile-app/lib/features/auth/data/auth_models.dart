// ignore_for_file: constant_identifier_names

enum UserRole {
  FARMER,
  LIVESTOCK_OWNER,
  MACHINERY_OWNER,
  BUYER,
  AGRONOMIST,
  VETERINARIAN,
  ADMIN;

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'LIVESTOCK_OWNER':
        return UserRole.LIVESTOCK_OWNER;
      case 'MACHINERY_OWNER':
        return UserRole.MACHINERY_OWNER;
      case 'BUYER':
        return UserRole.BUYER;
      case 'AGRONOMIST':
        return UserRole.AGRONOMIST;
      case 'VETERINARIAN':
        return UserRole.VETERINARIAN;
      case 'ADMIN':
        return UserRole.ADMIN;
      case 'FARMER':
      default:
        return UserRole.FARMER;
    }
  }

  String toJson() => name;
}

class RequestOtpResponse {
  final String message;
  final int? expiresInMinutes;
  final String? devCode;

  const RequestOtpResponse({
    required this.message,
    this.expiresInMinutes,
    this.devCode,
  });

  factory RequestOtpResponse.fromJson(Map<String, dynamic> json) {
    return RequestOtpResponse(
      message: json['message'] as String? ?? 'Kodni yuborish muvaffaqiyatli yakunlandi',
      expiresInMinutes: json['expiresInMinutes'] as int?,
      devCode: json['devCode']?.toString(),
    );
  }
}

class AuthProfile {
  final String? fullName;
  final String? avatarUrl;
  final String? regionId;
  final String? address;

  const AuthProfile({
    this.fullName,
    this.avatarUrl,
    this.regionId,
    this.address,
  });

  factory AuthProfile.fromJson(Map<String, dynamic> json) {
    return AuthProfile(
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      regionId: json['regionId'] as String?,
      address: json['address'] as String?,
    );
  }
}

class AuthUser {
  final String id;
  final String phone;
  final String role;
  final bool isVerified;
  final bool isActive;
  final AuthProfile? profile;

  const AuthUser({
    required this.id,
    required this.phone,
    required this.role,
    required this.isVerified,
    required this.isActive,
    this.profile,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      role: (json['role'] ?? 'FARMER').toString(),
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true, // Default to true if missing in VerifyOtpResponse
      profile: json['profile'] != null
          ? AuthProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }
}

class VerifyOtpResponse {
  final String accessToken;
  final AuthUser user;

  const VerifyOtpResponse({
    required this.accessToken,
    required this.user,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      accessToken: (json['accessToken'] ?? '').toString(),
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>? ?? const {}),
    );
  }
}

class MeResponse {
  final AuthUser user;

  const MeResponse({
    required this.user,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    return MeResponse(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>? ?? const {}),
    );
  }
}
