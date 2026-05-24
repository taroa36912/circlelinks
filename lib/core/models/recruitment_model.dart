import 'package:cloud_firestore/cloud_firestore.dart';

class RecruitmentModel {
  final String id;
  final String circleId;
  final String circleName;
  final String universityName;
  final String title;
  final String description;
  final String status;
  final List<String> targetYears;
  final List<String> welcomeTags;
  final List<String> requiredTags;
  final String activityDaysText;
  final String feeText;
  final String applicationMethod;
  final String? relatedEventId;
  final int? capacity;
  final int applicantCount;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecruitmentModel({
    required this.id,
    required this.circleId,
    required this.circleName,
    required this.universityName,
    required this.title,
    required this.description,
    this.status = 'open',
    this.targetYears = const [],
    this.welcomeTags = const [],
    this.requiredTags = const [],
    this.activityDaysText = '',
    this.feeText = '',
    this.applicationMethod = 'dm',
    this.relatedEventId,
    this.capacity,
    this.applicantCount = 0,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecruitmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecruitmentModel(
      id: doc.id,
      circleId: data['circleId'] ?? '',
      circleName: data['circleName'] ?? '',
      universityName: data['universityName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'open',
      targetYears: List<String>.from(data['targetYears'] ?? []),
      welcomeTags: List<String>.from(data['welcomeTags'] ?? []),
      requiredTags: List<String>.from(data['requiredTags'] ?? []),
      activityDaysText: data['activityDaysText'] ?? '',
      feeText: data['feeText'] ?? '',
      applicationMethod: data['applicationMethod'] ?? 'dm',
      relatedEventId: data['relatedEventId'],
      capacity: (data['capacity'] as num?)?.toInt(),
      applicantCount: data['applicantCount'] ?? 0,
      deadline:
          (data['deadline'] as Timestamp?)?.toDate(),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'circleId': circleId,
      'circleName': circleName,
      'universityName': universityName,
      'title': title,
      'description': description,
      'status': status,
      'targetYears': targetYears,
      'welcomeTags': welcomeTags,
      'requiredTags': requiredTags,
      'activityDaysText': activityDaysText,
      'feeText': feeText,
      'applicationMethod': applicationMethod,
      'relatedEventId': relatedEventId,
      'capacity': capacity,
      'applicantCount': applicantCount,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  RecruitmentModel copyWith({
    String? id,
    String? circleId,
    String? circleName,
    String? universityName,
    String? title,
    String? description,
    String? status,
    List<String>? targetYears,
    List<String>? welcomeTags,
    List<String>? requiredTags,
    String? activityDaysText,
    String? feeText,
    String? applicationMethod,
    String? relatedEventId,
    int? capacity,
    int? applicantCount,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecruitmentModel(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      circleName: circleName ?? this.circleName,
      universityName: universityName ?? this.universityName,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      targetYears: targetYears ?? this.targetYears,
      welcomeTags: welcomeTags ?? this.welcomeTags,
      requiredTags: requiredTags ?? this.requiredTags,
      activityDaysText: activityDaysText ?? this.activityDaysText,
      feeText: feeText ?? this.feeText,
      applicationMethod: applicationMethod ?? this.applicationMethod,
      relatedEventId: relatedEventId ?? this.relatedEventId,
      capacity: capacity ?? this.capacity,
      applicantCount: applicantCount ?? this.applicantCount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
