import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus {
  pending,
  attending,
  absent,
}

class AttendanceModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName; // Denormalized for easier display
  final String? userProfileImageUrl; // Denormalized
  final AttendanceStatus status;
  final DateTime? checkedInAt;
  final DateTime createdAt;
  final String checkInMethod;
  final String? checkedInBy;
  final String? qrTokenHash;
  final DateTime? updatedAt;
  final String? note;

  AttendanceModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userProfileImageUrl,
    this.status = AttendanceStatus.pending,
    this.checkedInAt,
    required this.createdAt,
    this.checkInMethod = 'manual',
    this.checkedInBy,
    this.qrTokenHash,
    this.updatedAt,
    this.note,
  });

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      userProfileImageUrl: data['userProfileImageUrl'],
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => AttendanceStatus.pending,
      ),
      checkedInAt: data['checkedInAt'] != null
          ? (data['checkedInAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      checkInMethod: data['checkInMethod'] ?? 'manual',
      checkedInBy: data['checkedInBy'],
      qrTokenHash: data['qrTokenHash'],
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      note: data['note'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userProfileImageUrl': userProfileImageUrl,
      'status': status.name,
      'checkedInAt': checkedInAt != null ? Timestamp.fromDate(checkedInAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'checkInMethod': checkInMethod,
      'checkedInBy': checkedInBy,
      'qrTokenHash': qrTokenHash,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'note': note,
    };
  }
  
  AttendanceModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? userName,
    String? userProfileImageUrl,
    AttendanceStatus? status,
    DateTime? checkedInAt,
    DateTime? createdAt,
    String? checkInMethod,
    String? checkedInBy,
    String? qrTokenHash,
    DateTime? updatedAt,
    String? note,
  }) {
    return AttendanceModel(
        id: id ?? this.id,
        eventId: eventId ?? this.eventId,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
        status: status ?? this.status,
        checkedInAt: checkedInAt ?? this.checkedInAt,
        createdAt: createdAt ?? this.createdAt,
        checkInMethod: checkInMethod ?? this.checkInMethod,
        checkedInBy: checkedInBy ?? this.checkedInBy,
        qrTokenHash: qrTokenHash ?? this.qrTokenHash,
        updatedAt: updatedAt ?? this.updatedAt,
        note: note ?? this.note,
    );
  }
}
