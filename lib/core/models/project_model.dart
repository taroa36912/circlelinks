import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String creatorId;
  final String creatorName;
  final String? creatorImageUrl;
  final String title;
  final String description;
  final String category;
  final int? maxParticipants;
  final List<String> participantIds;
  final String status; // open | closed
  final DateTime createdAt;
  final DateTime updatedAt;
  final String creatorType;
  final String? circleId;
  final String recruitmentType;
  final List<String> requiredTags;
  final List<String> relatedTags;
  final String visibility;
  final List<String> allowedCircleIds;
  final DateTime? deadline;
  final String applicationPolicy;
  final List<String> applicantIds;
  final String? relatedEventId;
  final String? relatedRecruitmentId;

  const ProjectModel({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    this.creatorImageUrl,
    required this.title,
    required this.description,
    required this.category,
    this.maxParticipants,
    required this.participantIds,
    this.status = 'open',
    required this.createdAt,
    required this.updatedAt,
    this.creatorType = 'user',
    this.circleId,
    this.recruitmentType = 'project',
    this.requiredTags = const [],
    this.relatedTags = const [],
    this.visibility = 'public',
    this.allowedCircleIds = const [],
    this.deadline,
    this.applicationPolicy = 'firstCome',
    this.applicantIds = const [],
    this.relatedEventId,
    this.relatedRecruitmentId,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      creatorId: data['creatorId'] as String? ?? '',
      creatorName: data['creatorName'] as String? ?? 'Unknown User',
      creatorImageUrl: data['creatorImageUrl'] as String?,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Study',
      maxParticipants: (data['maxParticipants'] as num?)?.toInt(),
      participantIds: (data['participantIds'] as List<dynamic>? ?? const [])
          .map((id) => id.toString())
          .toList(),
      status: data['status'] as String? ?? 'open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      creatorType: data['creatorType'] as String? ?? 'user',
      circleId: data['circleId'] as String?,
      recruitmentType: data['recruitmentType'] as String? ?? 'project',
      requiredTags: List<String>.from(data['requiredTags'] ?? []),
      relatedTags: List<String>.from(data['relatedTags'] ?? []),
      visibility: data['visibility'] as String? ?? 'public',
      allowedCircleIds: List<String>.from(data['allowedCircleIds'] ?? []),
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      applicationPolicy: data['applicationPolicy'] as String? ?? 'firstCome',
      applicantIds: (data['applicantIds'] as List<dynamic>? ?? const [])
          .map((id) => id.toString())
          .toList(),
      relatedEventId: data['relatedEventId'] as String?,
      relatedRecruitmentId: data['relatedRecruitmentId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorImageUrl': creatorImageUrl,
      'title': title,
      'description': description,
      'category': category,
      'maxParticipants': maxParticipants,
      'participantIds': participantIds,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'creatorType': creatorType,
      'circleId': circleId,
      'recruitmentType': recruitmentType,
      'requiredTags': requiredTags,
      'relatedTags': relatedTags,
      'visibility': visibility,
      'allowedCircleIds': allowedCircleIds,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'applicationPolicy': applicationPolicy,
      'applicantIds': applicantIds,
      'relatedEventId': relatedEventId,
      'relatedRecruitmentId': relatedRecruitmentId,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    String? creatorImageUrl,
    String? title,
    String? description,
    String? category,
    int? maxParticipants,
    List<String>? participantIds,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? creatorType,
    String? circleId,
    String? recruitmentType,
    List<String>? requiredTags,
    List<String>? relatedTags,
    String? visibility,
    List<String>? allowedCircleIds,
    DateTime? deadline,
    String? applicationPolicy,
    List<String>? applicantIds,
    String? relatedEventId,
    String? relatedRecruitmentId,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorImageUrl: creatorImageUrl ?? this.creatorImageUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantIds: participantIds ?? this.participantIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creatorType: creatorType ?? this.creatorType,
      circleId: circleId ?? this.circleId,
      recruitmentType: recruitmentType ?? this.recruitmentType,
      requiredTags: requiredTags ?? this.requiredTags,
      relatedTags: relatedTags ?? this.relatedTags,
      visibility: visibility ?? this.visibility,
      allowedCircleIds: allowedCircleIds ?? this.allowedCircleIds,
      deadline: deadline ?? this.deadline,
      applicationPolicy: applicationPolicy ?? this.applicationPolicy,
      applicantIds: applicantIds ?? this.applicantIds,
      relatedEventId: relatedEventId ?? this.relatedEventId,
      relatedRecruitmentId: relatedRecruitmentId ?? this.relatedRecruitmentId,
    );
  }
}
