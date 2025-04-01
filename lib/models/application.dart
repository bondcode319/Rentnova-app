// lib/models/application.dart
enum ApplicationStatus {
  pendingReview,
  underReview,
  declined,
  actionRequired,
  awaitingLandlordReview,
  approved,
  scheduleViewing,
  leaseAgreementSent,
  leaseSigned,
  leaseAccepted,
  activeTenant,
}

class RentalApplication {
  final String id;
  final String propertyId;
  final String tenantId;
  final String landlordId;
  final DateTime applicationDate;
  ApplicationStatus status;
  final Map<String, dynamic> rentalProfile;
  final List<String> documentUrls;
  final DateTime? viewingDate;
  final String? leaseDocumentUrl;
  final DateTime? leaseSentDate;
  final DateTime? leaseSignedDate;
  final DateTime? leaseAcceptedDate;
  final String? declineReason;
  final String? additionalInfoRequest;

  RentalApplication({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.landlordId,
    required this.applicationDate,
    required this.status,
    required this.rentalProfile,
    required this.documentUrls,
    this.viewingDate,
    this.leaseDocumentUrl,
    this.leaseSentDate,
    this.leaseSignedDate,
    this.leaseAcceptedDate,
    this.declineReason,
    this.additionalInfoRequest,
  });

  factory RentalApplication.fromMap(String id, Map<String, dynamic> data) {
    return RentalApplication(
      id: id,
      propertyId: data['propertyId'],
      tenantId: data['tenantId'],
      landlordId: data['landlordId'],
      applicationDate: DateTime.parse(data['applicationDate']),
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString() == 'ApplicationStatus.${data['status']}',
        orElse: () => ApplicationStatus.pendingReview,
      ),
      rentalProfile: Map<String, dynamic>.from(data['rentalProfile']),
      documentUrls: List<String>.from(data['documentUrls']),
      viewingDate:
          data['viewingDate'] != null
              ? DateTime.parse(data['viewingDate'])
              : null,
      leaseDocumentUrl: data['leaseDocumentUrl'],
      leaseSentDate:
          data['leaseSentDate'] != null
              ? DateTime.parse(data['leaseSentDate'])
              : null,
      leaseSignedDate:
          data['leaseSignedDate'] != null
              ? DateTime.parse(data['leaseSignedDate'])
              : null,
      leaseAcceptedDate:
          data['leaseAcceptedDate'] != null
              ? DateTime.parse(data['leaseAcceptedDate'])
              : null,
      declineReason: data['declineReason'],
      additionalInfoRequest: data['additionalInfoRequest'],
    );
  }
}
