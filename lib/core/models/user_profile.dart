import 'dart:convert';
import 'user_role.dart';

class UserProfile {
  final String userId;
  final String pin; // 4-digit secure pin
  final UserRole role;
  final String fullName;
  final String mobileNumber;
  final String? aadhaarNumber; // Masked e.g. XXXX XXXX 1234
  final String? farmerId;      // e.g. FID-2026-8941
  final String? gstNumber;     // e.g. 27AAAAA0000A1Z5
  final String? fpoName;       // e.g. Sahyadri Farmer Producer Co. Ltd.
  final bool biometricEnabled;
  final DateTime createdAt;

  UserProfile({
    required this.userId,
    required this.pin,
    required this.role,
    required this.fullName,
    required this.mobileNumber,
    this.aadhaarNumber,
    this.farmerId,
    this.gstNumber,
    this.fpoName,
    this.biometricEnabled = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'pin': pin,
      'role': role.name,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'aadhaarNumber': aadhaarNumber,
      'farmerId': farmerId,
      'gstNumber': gstNumber,
      'fpoName': fpoName,
      'biometricEnabled': biometricEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] as String,
      pin: map['pin'] as String,
      role: map['role'] == 'fpo' ? UserRole.fpo : UserRole.farmer,
      fullName: map['fullName'] as String,
      mobileNumber: map['mobileNumber'] as String,
      aadhaarNumber: map['aadhaarNumber'] as String?,
      farmerId: map['farmerId'] as String?,
      gstNumber: map['gstNumber'] as String?,
      fpoName: map['fpoName'] as String?,
      biometricEnabled: (map['biometricEnabled'] as bool?) ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}
