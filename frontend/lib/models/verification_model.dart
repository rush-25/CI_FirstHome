class VerificationEventModel {
  final int id;
  final int userId;
  final String userName;
  final String userRole;
  final String providerType;
  final String status; // NotStarted, Pending, Verified, Rejected
  final String simulatedReference;
  final String? note;
  final DateTime createdAt;

  VerificationEventModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.providerType,
    required this.status,
    required this.simulatedReference,
    this.note,
    required this.createdAt,
  });

  factory VerificationEventModel.fromJson(Map<String, dynamic> json) {
    return VerificationEventModel(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      userName: json['userName'] as String? ?? '',
      userRole: json['userRole'] as String? ?? '',
      providerType: json['providerType'] as String? ?? 'MOCK',
      status: json['status'] as String? ?? 'NotStarted',
      simulatedReference: json['simulatedReference'] as String? ?? '',
      note: json['note'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class VerificationStateModel {
  final String status;
  final String providerType;
  final bool consentGiven;
  final List<VerificationEventModel> events;
  final String disclaimer;

  VerificationStateModel({
    required this.status,
    required this.providerType,
    required this.consentGiven,
    required this.events,
    required this.disclaimer,
  });

  factory VerificationStateModel.fromJson(Map<String, dynamic> json) {
    return VerificationStateModel(
      status: json['status'] as String? ?? 'NotStarted',
      providerType: json['providerType'] as String? ?? 'MOCK',
      consentGiven: json['consentGiven'] as bool? ?? false,
      events: (json['events'] as List<dynamic>? ?? [])
          .map((e) => VerificationEventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      disclaimer: json['disclaimer'] as String? ?? '',
    );
  }
}
