// lib/widgets/application_status.dart
import 'package:flutter/material.dart';
import 'package:rentnova/models/application.dart';

class ApplicationStatusWidget extends StatelessWidget {
  final ApplicationStatus status;
  final bool isLandlord;

  const ApplicationStatusWidget({
    super.key,
    required this.status,
    this.isLandlord = false,
  });

  @override
  Widget build(BuildContext context) {
    final (color, text) = _getStatusInfo(status, isLandlord);
    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
      side: BorderSide(color: color),
    );
  }

  (Color, String) _getStatusInfo(ApplicationStatus status, bool isLandlord) {
    switch (status) {
      case ApplicationStatus.pendingReview:
        return (Colors.orange, isLandlord ? 'New Application' : 'Submitted');
      case ApplicationStatus.underReview:
        return (Colors.blue, 'Under Review');
      case ApplicationStatus.declined:
        return (Colors.red, 'Declined');
      case ApplicationStatus.actionRequired:
        return (Colors.amber, 'Action Required');
      case ApplicationStatus.awaitingLandlordReview:
        return (Colors.blue, 'Response Submitted');
      case ApplicationStatus.approved:
        return (Colors.green, 'Approved');
      case ApplicationStatus.scheduleViewing:
        return (Colors.purple, 'Schedule Viewing');
      case ApplicationStatus.leaseAgreementSent:
        return (Colors.indigo, 'Lease Sent');
      case ApplicationStatus.leaseSigned:
        return (
          isLandlord ? Colors.blue : Colors.green,
          isLandlord ? 'Awaiting Acceptance' : 'Signed',
        );
      case ApplicationStatus.leaseAccepted:
        return (Colors.green, 'Lease Accepted');
      case ApplicationStatus.activeTenant:
        return (Colors.green, 'Active');
    }
  }
}
