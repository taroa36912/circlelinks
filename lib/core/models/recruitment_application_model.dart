import 'package:cloud_firestore/cloud_firestore.dart';

class RecruitmentApplicationModel {
  final String id;
  final String recruitmentId;
  final String circleId;
  final String applicantUserId;
  final String applicantName;
  final String applicantEmail;
  final String? applicantProfileImageUrl;
  final String message;
  final List<String> applicantTags;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecruitmentApplicationModel({
    required this.id,
    required this.recruitmentId,
    required this.circleId,
    required this.applicantUserId,
    this.applicantName = '',
    this.applicantEmail = '',
    this.applicantProfileImageUrl,
    this.message = '',
    this.applicantTags = const [],
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecruitmentApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecruitmentApplicationModel(
      id: doc.id,
      recruitmentId: data['recruitmentId'] ?? '',
      circleId: data['circleId'] ?? '',
      applicantUserId: data['applicantUserId'] ?? '',
      applicantName: data['applicantName'] ?? '',
      applicantEmail: data['applicantEmail'] ?? '',
      applicantProfileImageUrl: data['applicantProfileImageUrl'],
      message: data['message'] ?? '',
      applicantTags: List<String>.from(data['applicantTags'] ?? []),
      status: data['status'] ?? 'pending',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recruitmentId': recruitmentId,
      'circleId': circleId,
      'applicantUserId': applicantUserId,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'applicantProfileImageUrl': applicantProfileImageUrl,
      'message': message,
      'applicantTags': applicantTags,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  RecruitmentApplicationModel copyWith({
    String? id,
    String? recruitmentId,
    String? circleId,
    String? applicantUserId,
    String? applicantName,
    String? applicantEmail,
    String? applicantProfileImageUrl,
    String? message,
    List<String>? applicantTags,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecruitmentApplicationModel(
      id: id ?? this.id,
      recruitmentId: recruitmentId ?? this.recruitmentId,
      circleId: circleId ?? this.circleId,
      applicantUserId: applicantUserId ?? this.applicantUserId,
      applicantName: applicantName ?? this.applicantName,
      applicantEmail: applicantEmail ?? this.applicantEmail,
      applicantProfileImageUrl:
          applicantProfileImageUrl ?? this.applicantProfileImageUrl,
      message: message ?? this.message,
      applicantTags: applicantTags ?? this.applicantTags,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
