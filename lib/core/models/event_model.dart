import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String circleId;
  final String title;
  final String description;
  final String category;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? mainImageUrl;
  final int fee; // 0 if free
  final String visibility; // public | private
  final List<String> allowedCircleIds; // for private events
  final bool isDraft;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String ownerCircleId;
  final List<String> organizerCircleIds;
  final Map<String, String> circlePermissions;
  final String collaborationStatus;
  final List<String> invitedCircleIds;
  final String attendancePolicy;
  final bool requiresPhysicalCheckIn;
  final DateTime? attendanceOpenAt;
  final DateTime? attendanceCloseAt;

  EventModel({
    required this.id,
    required this.circleId,
    required this.title,
    required this.description,
    this.category = 'other',
    required this.startTime,
    required this.endTime,
    required this.location,
    this.mainImageUrl,
    this.fee = 0,
    this.visibility = 'public',
    this.allowedCircleIds = const [],
    this.isDraft = false,
    required this.createdAt,
    required this.updatedAt,
    this.ownerCircleId = '',
    this.organizerCircleIds = const [],
    this.circlePermissions = const {},
    this.collaborationStatus = 'none',
    this.invitedCircleIds = const [],
    this.attendancePolicy = 'manualAllowed',
    this.requiresPhysicalCheckIn = false,
    this.attendanceOpenAt,
    this.attendanceCloseAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final resolvedCircleId = data['circleId'] ?? '';
    return EventModel(
      id: doc.id,
      circleId: resolvedCircleId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'other',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      mainImageUrl: data['mainImageUrl'],
      fee: data['fee'] ?? 0,
      visibility: data['visibility'] ?? 'public',
      allowedCircleIds: (data['allowedCircleIds'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      isDraft: data['isDraft'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ownerCircleId: data['ownerCircleId'] ?? resolvedCircleId,
      organizerCircleIds: (data['organizerCircleIds'] as List<dynamic>? ?? [resolvedCircleId])
          .map((e) => e.toString())
          .toList(),
      circlePermissions: (data['circlePermissions'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v.toString())) ??
          {resolvedCircleId: 'owner'},
      collaborationStatus: data['collaborationStatus'] ?? 'none',
      invitedCircleIds: (data['invitedCircleIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      attendancePolicy: data['attendancePolicy'] ?? 'manualAllowed',
      requiresPhysicalCheckIn: data['requiresPhysicalCheckIn'] ?? false,
      attendanceOpenAt:
          (data['attendanceOpenAt'] as Timestamp?)?.toDate(),
      attendanceCloseAt:
          (data['attendanceCloseAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'circleId': circleId,
      'title': title,
      'description': description,
      'category': category,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'mainImageUrl': mainImageUrl,
      'fee': fee,
      'visibility': visibility,
      'allowedCircleIds': allowedCircleIds,
      'isDraft': isDraft,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'ownerCircleId': ownerCircleId.isEmpty ? circleId : ownerCircleId,
      'organizerCircleIds': organizerCircleIds.isEmpty ? [circleId] : organizerCircleIds,
      'circlePermissions': circlePermissions.isEmpty ? {circleId: 'owner'} : circlePermissions,
      'collaborationStatus': collaborationStatus,
      'invitedCircleIds': invitedCircleIds,
      'attendancePolicy': attendancePolicy,
      'requiresPhysicalCheckIn': requiresPhysicalCheckIn,
      'attendanceOpenAt': attendanceOpenAt != null ? Timestamp.fromDate(attendanceOpenAt!) : null,
      'attendanceCloseAt': attendanceCloseAt != null ? Timestamp.fromDate(attendanceCloseAt!) : null,
    };
  }

  EventModel copyWith({
    String? id,
    String? circleId,
    String? title,
    String? description,
    String? category,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? mainImageUrl,
    int? fee,
    String? visibility,
    List<String>? allowedCircleIds,
    bool? isDraft,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerCircleId,
    List<String>? organizerCircleIds,
    Map<String, String>? circlePermissions,
    String? collaborationStatus,
    List<String>? invitedCircleIds,
    String? attendancePolicy,
    bool? requiresPhysicalCheckIn,
    DateTime? attendanceOpenAt,
    DateTime? attendanceCloseAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      fee: fee ?? this.fee,
      visibility: visibility ?? this.visibility,
      allowedCircleIds: allowedCircleIds ?? this.allowedCircleIds,
      isDraft: isDraft ?? this.isDraft,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerCircleId: ownerCircleId ?? this.ownerCircleId,
      organizerCircleIds: organizerCircleIds ?? this.organizerCircleIds,
      circlePermissions: circlePermissions ?? this.circlePermissions,
      collaborationStatus: collaborationStatus ?? this.collaborationStatus,
      invitedCircleIds: invitedCircleIds ?? this.invitedCircleIds,
      attendancePolicy: attendancePolicy ?? this.attendancePolicy,
      requiresPhysicalCheckIn: requiresPhysicalCheckIn ?? this.requiresPhysicalCheckIn,
      attendanceOpenAt: attendanceOpenAt ?? this.attendanceOpenAt,
      attendanceCloseAt: attendanceCloseAt ?? this.attendanceCloseAt,
    );
  }
}
