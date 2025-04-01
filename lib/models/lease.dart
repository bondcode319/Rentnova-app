// lib/models/lease.dart
class LeaseAgreement {
  final String id;
  final String propertyId;
  final String landlordId;
  final String tenantId;
  final String applicationId;
  final DateTime startDate;
  final DateTime endDate;
  final double monthlyRent;
  final double securityDeposit;
  final String documentUrl;
  final DateTime sentDate;
  final DateTime? signedDate;
  final DateTime? acceptedDate;
  final bool isActive;
  final List<Map<String, dynamic>> terms;

  LeaseAgreement({
    required this.id,
    required this.propertyId,
    required this.landlordId,
    required this.tenantId,
    required this.applicationId,
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
    required this.securityDeposit,
    required this.documentUrl,
    required this.sentDate,
    this.signedDate,
    this.acceptedDate,
    required this.isActive,
    required this.terms,
  });

  factory LeaseAgreement.fromMap(String id, Map<String, dynamic> data) {
    return LeaseAgreement(
      id: id,
      propertyId: data['propertyId'],
      landlordId: data['landlordId'],
      tenantId: data['tenantId'],
      applicationId: data['applicationId'],
      startDate: DateTime.parse(data['startDate']),
      endDate: DateTime.parse(data['endDate']),
      monthlyRent: data['monthlyRent'].toDouble(),
      securityDeposit: data['securityDeposit'].toDouble(),
      documentUrl: data['documentUrl'],
      sentDate: DateTime.parse(data['sentDate']),
      signedDate:
          data['signedDate'] != null
              ? DateTime.parse(data['signedDate'])
              : null,
      acceptedDate:
          data['acceptedDate'] != null
              ? DateTime.parse(data['acceptedDate'])
              : null,
      isActive: data['isActive'],
      terms: List<Map<String, dynamic>>.from(data['terms']),
    );
  }
}
