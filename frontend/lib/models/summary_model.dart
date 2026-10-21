import 'lead_model.dart';
import 'verification_model.dart';

class CustomerRowModel {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String? state;
  final String? city;
  final bool isActive;
  final int leadCount;
  final String verificationStatus;
  final DateTime createdAt;

  CustomerRowModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.state,
    this.city,
    required this.isActive,
    required this.leadCount,
    required this.verificationStatus,
    required this.createdAt,
  });

  factory CustomerRowModel.fromJson(Map<String, dynamic> json) {
    return CustomerRowModel(
      id: json['id'] as int? ?? 0,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      state: json['state'] as String?,
      city: json['city'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      leadCount: json['leadCount'] as int? ?? 0,
      verificationStatus: json['verificationStatus'] as String? ?? 'NotStarted',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class ProviderRowModel {
  final int id;
  final int userId;
  final String displayName;
  final String ownerName;
  final String email;
  final String categoryName;
  final String state;
  final String city;
  final bool isActive;
  final String verificationStatus;
  final DateTime createdAt;

  ProviderRowModel({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.ownerName,
    required this.email,
    required this.categoryName,
    required this.state,
    required this.city,
    required this.isActive,
    required this.verificationStatus,
    required this.createdAt,
  });

  factory ProviderRowModel.fromJson(Map<String, dynamic> json) {
    return ProviderRowModel(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      displayName: json['displayName'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      state: json['state'] as String? ?? '',
      city: json['city'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      verificationStatus: json['verificationStatus'] as String? ?? 'NotStarted',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class SummaryModel {
  final int totalCustomers;
  final int totalProviders;
  final int activeProviders;
  final int totalLeads;
  final Map<String, int> leadsByStatus;
  final List<LeadModel> recentLeads;
  final List<ProviderRowModel> recentProviders;
  final List<VerificationEventModel> recentVerificationEvents;

  SummaryModel({
    required this.totalCustomers,
    required this.totalProviders,
    required this.activeProviders,
    required this.totalLeads,
    required this.leadsByStatus,
    required this.recentLeads,
    required this.recentProviders,
    required this.recentVerificationEvents,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    final statusMap = <String, int>{};
    if (json['leadsByStatus'] != null) {
      final rawMap = json['leadsByStatus'] as Map<String, dynamic>;
      rawMap.forEach((k, v) {
        statusMap[k] = (v as num).toInt();
      });
    }

    return SummaryModel(
      totalCustomers: json['totalCustomers'] as int? ?? 0,
      totalProviders: json['totalProviders'] as int? ?? 0,
      activeProviders: json['activeProviders'] as int? ?? 0,
      totalLeads: json['totalLeads'] as int? ?? 0,
      leadsByStatus: statusMap,
      recentLeads: (json['recentLeads'] as List<dynamic>? ?? [])
          .map((e) => LeadModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentProviders: (json['recentProviders'] as List<dynamic>? ?? [])
          .map((e) => ProviderRowModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentVerificationEvents:
          (json['recentVerificationEvents'] as List<dynamic>? ?? [])
              .map((e) =>
                  VerificationEventModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}
