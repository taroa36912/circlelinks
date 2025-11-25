import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id; // Auth UID
  final String email;
  final String userName; // 表示名 (例: ユーザーA)
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.userName,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      userName: data['userName'] ?? '名無しユーザー',
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'userName': userName,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? userName,
    String? profileImageUrl,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      email: email,
      userName: userName ?? this.userName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}