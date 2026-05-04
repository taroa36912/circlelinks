import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  static const Set<String> _universityDomains = {
    'ynu.jp',
    'keio.jp',
  };

  final String id; // Auth UID
  final String email;
  final String userName; // 表示名 (例: ユーザーA)
  final String? profileImageUrl;
  final String role; // student / guest
  final String accountType; // university / guest
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.userName,
    this.profileImageUrl,
    String? role,
    String? accountType,
    required this.createdAt,
    required this.updatedAt,
  })  : role = role ?? 'guest',
        accountType = accountType ??
            ((role ?? 'guest') == 'student' ? 'university' : 'guest');

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final email = data['email'] ?? '';
    final resolvedRole = data['role'] ?? roleFromEmail(email);
    return UserModel(
      id: doc.id,
      email: email,
      userName: data['userName'] ?? '名無しユーザー',
      profileImageUrl: data['profileImageUrl'],
      role: resolvedRole,
      accountType: data['accountType'] ?? accountTypeFromRole(resolvedRole),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static bool isUniversityEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return false;
    }

    final domain = normalizedEmail.split('@').last;
    return domain.endsWith('.ac.jp') || _universityDomains.contains(domain);
  }

  static String roleFromEmail(String email) {
    return isUniversityEmail(email) ? 'student' : 'guest';
  }

  static String accountTypeFromRole(String role) {
    return role == 'student' ? 'university' : 'guest';
  }

  static String accountTypeFromEmail(String email) {
    return isUniversityEmail(email) ? 'university' : 'guest';
  }

  bool get isUniversityStudent => role == 'student';
  bool get canCreateCircle => role == 'student';
  bool get canSendDm => role == 'student';

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'userName': userName,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'accountType': accountType,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? userName,
    String? profileImageUrl,
    String? role,
    String? accountType,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      email: email,
      userName: userName ?? this.userName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      accountType: accountType ?? this.accountType,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
