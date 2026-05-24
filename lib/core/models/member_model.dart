import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String id; // The user's uid
  final String userId; // Same as id, for convenience
  final String role; // 'admin' or 'member'
  final DateTime joinedAt;
  final List<String> roleTags;
  final List<String> skillTags;
  final String? displayRole;
  final DateTime? updatedAt;

  MemberModel({
    required this.id,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.roleTags = const [],
    this.skillTags = const [],
    this.displayRole,
    this.updatedAt,
  });

  factory MemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawUserId = (data['userId'] as String?)?.trim();
    return MemberModel(
      id: doc.id,
      // Legacy documents may not have userId; use document id in that case.
      userId: (rawUserId != null && rawUserId.isNotEmpty) ? rawUserId : doc.id,
      role: data['role'] ?? 'member',
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      roleTags: List<String>.from(data['roleTags'] ?? []),
      skillTags: List<String>.from(data['skillTags'] ?? []),
      displayRole: data['displayRole'],
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'roleTags': roleTags,
      'skillTags': skillTags,
      'displayRole': displayRole,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  MemberModel copyWith({
    String? id,
    String? userId,
    String? role,
    DateTime? joinedAt,
    List<String>? roleTags,
    List<String>? skillTags,
    String? displayRole,
    DateTime? updatedAt,
  }) {
    return MemberModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      roleTags: roleTags ?? this.roleTags,
      skillTags: skillTags ?? this.skillTags,
      displayRole: displayRole ?? this.displayRole,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
