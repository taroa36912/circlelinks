import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String id; // The user's uid
  final String userId; // Same as id, for convenience
  final String role; // 'admin' or 'member'
  final DateTime joinedAt;

  MemberModel({
    required this.id,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  factory MemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemberModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      role: data['role'] ?? 'member',
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  MemberModel copyWith({
    String? id,
    String? userId,
    String? role,
    DateTime? joinedAt,
  }) {
    return MemberModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
