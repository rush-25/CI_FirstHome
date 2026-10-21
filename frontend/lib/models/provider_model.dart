class ProviderModel {
  final int id;
  final String displayName;
  final String contactEmail;
  final String phone;
  final int categoryId;
  final String categoryName;
  final String state;
  final String city;
  final String description;
  final bool isActive;
  final String verificationStatus; // NotStarted, Pending, Verified, Rejected
  final DateTime createdAt;
  final int userId;

  ProviderModel({
    required this.id,
    required this.displayName,
    required this.contactEmail,
    required this.phone,
    required this.categoryId,
    required this.categoryName,
    required this.state,
    required this.city,
    required this.description,
    required this.isActive,
    required this.verificationStatus,
    required this.createdAt,
    required this.userId,
  });

  bool get isVerified => verificationStatus == 'Verified';

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] as int? ?? 0,
      displayName: json['displayName'] as String? ?? '',
      contactEmail: json['contactEmail'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      categoryId: json['categoryId'] as int? ?? 0,
      categoryName: json['categoryName'] as String? ?? '',
      state: json['state'] as String? ?? '',
      city: json['city'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      verificationStatus: json['verificationStatus'] as String? ?? 'NotStarted',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      userId: json['userId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'contactEmail': contactEmail,
        'phone': phone,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'state': state,
        'city': city,
        'description': description,
        'isActive': isActive,
        'verificationStatus': verificationStatus,
        'createdAt': createdAt.toIso8601String(),
        'userId': userId,
      };
}

class PagedProviders {
  final List<ProviderModel> items;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  PagedProviders({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory PagedProviders.fromJson(Map<String, dynamic> json) {
    return PagedProviders(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}
