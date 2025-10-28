import 'dart:convert';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final bool isEmailVerified;
  final DateTime createdAt;
  final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.isEmailVerified,
    required this.createdAt,
    this.profileImageUrl,
  });

  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    bool? isEmailVerified,
    DateTime? createdAt,
    String? profileImageUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  // Convert to JSON
  String toJson() {
    return jsonEncode({
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'profileImageUrl': profileImageUrl,
    });
  }

  // Create from JSON
  factory UserModel.fromJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      isEmailVerified: data['isEmailVerified'] ?? false,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      profileImageUrl: data['profileImageUrl'],
    );
  }

  // Create from Map
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      isEmailVerified: data['isEmailVerified'] ?? false,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      profileImageUrl: data['profileImageUrl'],
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'profileImageUrl': profileImageUrl,
    };
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, isEmailVerified: $isEmailVerified, createdAt: $createdAt, profileImageUrl: $profileImageUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode {
    return uid.hashCode;
  }
}