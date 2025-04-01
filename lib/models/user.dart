// lib/models/user.dart
enum UserRole { tenant, landlord, admin }

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String nin;
  final UserRole role;
  final DateTime createdAt;
  final String? profileImageUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.nin,
    required this.role,
    required this.createdAt,
    this.profileImageUrl,
  });

  // Factory method to create user from Firebase User with validation
  factory UserModel.fromFirebaseUser(User user, Map<String, dynamic> data) {
    // Validate required fields
    if (data['fullName'] == null) {
      throw ArgumentError('Full name is required');
    }
    if (data['dateOfBirth'] == null) {
      throw ArgumentError('Date of birth is required');
    }
    if (data['phoneNumber'] == null) {
      throw ArgumentError('Phone number is required');
    }
    if (data['nin'] == null) {
      throw ArgumentError('NIN is required');
    }

    // Parse and validate dates
    DateTime? dateOfBirth;
    try {
      dateOfBirth = DateTime.parse(data['dateOfBirth']);
    } catch (e) {
      throw ArgumentError('Invalid date of birth format');
    }

    DateTime createdAt = DateTime.parse(
      data['createdAt'] ?? DateTime.now().toIso8601String(),
    );

    // Validate phone number format
    if (!RegExp(r'^\d{11}$').hasMatch(data['phoneNumber'])) {
      throw ArgumentError('Invalid phone number format');
    }

    // Validate NIN format
    if (!RegExp(r'^\d{11}$').hasMatch(data['nin'])) {
      throw ArgumentError('Invalid NIN format');
    }

    return UserModel(
      id: user.uid,
      email: user.email ?? data['email'] ?? '',
      fullName: data['fullName'],
      dateOfBirth: dateOfBirth,
      phoneNumber: data['phoneNumber'],
      nin: data['nin'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.tenant,
      ),
      createdAt: createdAt,
      profileImageUrl: data['profileImageUrl'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'phoneNumber': phoneNumber,
      'nin': nin,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };
  }

  // Generic copy with method
  UserModel copyWith({
    String? email,
    String? fullName,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? nin,
    UserRole? role,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nin: nin ?? this.nin,
      role: role ?? this.role,
      createdAt: createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  // Specific method to toggle between tenant and landlord roles
  UserModel copyWithRole(UserRole newRole) {
    if (newRole == UserRole.admin) {
      throw ArgumentError('Cannot switch to admin role');
    }
    return copyWith(role: newRole);
  }

  // Override equals operator
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          fullName == other.fullName &&
          dateOfBirth == other.dateOfBirth &&
          phoneNumber == other.phoneNumber &&
          nin == other.nin &&
          role == other.role &&
          createdAt == other.createdAt &&
          profileImageUrl == other.profileImageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      fullName.hashCode ^
      dateOfBirth.hashCode ^
      phoneNumber.hashCode ^
      nin.hashCode ^
      role.hashCode ^
      createdAt.hashCode ^
      profileImageUrl.hashCode;

  @override
  String toString() =>
      'UserModel(id: $id, email: $email, fullName: $fullName, role: $role)';
}
