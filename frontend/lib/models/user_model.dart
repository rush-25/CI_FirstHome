class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String role; // Customer, Provider, Admin
  final String? state;
  final String? city;
  final String? contactPreference;
  final DateTime? consentAt;
  final int? providerId;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.state,
    this.city,
    this.contactPreference,
    this.consentAt,
    this.providerId,
    required this.createdAt,
  });

  bool get isCustomer => role == 'Customer';
  bool get isProvider => role == 'Provider';
  bool get isAdmin => role == 'Admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'Customer',
      state: json['state'] as String?,
      city: json['city'] as String?,
      contactPreference: json['contactPreference'] as String?,
      consentAt: json['consentAt'] != null
          ? DateTime.tryParse(json['consentAt'].toString())
          : null,
      providerId: json['providerId'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': role,
        'state': state,
        'city': city,
        'contactPreference': contactPreference,
        'consentAt': consentAt?.toIso8601String(),
        'providerId': providerId,
        'createdAt': createdAt.toIso8601String(),
      };
}

class AuthResponseModel {
  final String token;
  final DateTime expiresAt;
  final UserModel user;

  AuthResponseModel({
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String? ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}
