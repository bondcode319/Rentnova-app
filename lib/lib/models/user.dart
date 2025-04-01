import 'package:firebase_auth/firebase_auth.dart' as auth;

enum UserRole { tenant, landlord, admin }

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final UserRole role;
  final Map<String, dynamic>? additionalData;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    required this.role,
    this.additionalData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      role: _parseRole(data['role']),
      additionalData: data['additionalData'],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.fromFirebaseUser(
    auth.User user,
    Map<String, dynamic> data,
  ) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      role: _parseRole(data['role']),
      additionalData: data['additionalData'],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
      'additionalData': additionalData,
      'updatedAt': DateTime.now(),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? phoneNumber,
    UserRole? role,
    Map<String, dynamic>? additionalData,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static UserRole _parseRole(String? roleStr) {
    if (roleStr == 'admin') return UserRole.admin;
    if (roleStr == 'landlord') return UserRole.landlord;
    return UserRole.tenant; // Default role
  }
}
