class HistoryModel {
  final int id;
  final String? oldStatus;
  final String newStatus;
  final int changedByUserId;
  final String changedByName;
  final DateTime changedAt;

  HistoryModel({
    required this.id,
    this.oldStatus,
    required this.newStatus,
    required this.changedByUserId,
    required this.changedByName,
    required this.changedAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] as int? ?? 0,
      oldStatus: json['oldStatus'] as String?,
      newStatus: json['newStatus'] as String? ?? 'New',
      changedByUserId: json['changedByUserId'] as int? ?? 0,
      changedByName: json['changedByName'] as String? ?? '',
      changedAt: json['changedAt'] != null
          ? DateTime.tryParse(json['changedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class LeadModel {
  final int id;
  final String reference;
  final String enquiryType;
  final String title;
  final String description;
  final String state;
  final String city;
  final String preferredContact;
  final String status; // New, Contacted, Qualified, Closed
  final int? categoryId;
  final String? categoryName;
  final int? providerId;
  final String? providerName;
  final int customerUserId;
  final String customerName;
  final String customerEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<HistoryModel> history;

  LeadModel({
    required this.id,
    required this.reference,
    required this.enquiryType,
    required this.title,
    required this.description,
    required this.state,
    required this.city,
    required this.preferredContact,
    required this.status,
    this.categoryId,
    this.categoryName,
    this.providerId,
    this.providerName,
    required this.customerUserId,
    required this.customerName,
    required this.customerEmail,
    required this.createdAt,
    required this.updatedAt,
    this.history = const [],
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] as int? ?? 0,
      reference: json['reference'] as String? ?? '',
      enquiryType: json['enquiryType'] as String? ?? 'Service request',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      state: json['state'] as String? ?? '',
      city: json['city'] as String? ?? '',
      preferredContact: json['preferredContact'] as String? ?? 'Phone',
      status: json['status'] as String? ?? 'New',
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String?,
      providerId: json['providerId'] as int?,
      providerName: json['providerName'] as String?,
      customerUserId: json['customerUserId'] as int? ?? 0,
      customerName: json['customerName'] as String? ?? '',
      customerEmail: json['customerEmail'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      history: (json['history'] as List<dynamic>? ?? [])
          .map((h) => HistoryModel.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PagedLeads {
  final List<LeadModel> items;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  PagedLeads({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory PagedLeads.fromJson(Map<String, dynamic> json) {
    return PagedLeads(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => LeadModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}
