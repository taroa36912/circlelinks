import 'package:cloud_firestore/cloud_firestore.dart';

enum ConnectionStatus { pending, approved, declined }

class ConnectionRequestModel {
  final String id;
  final String fromCircleId;
  final String toCircleId;
  final String fromCircleName;
  final String toCircleName;
  final String fromUniversityName;
  final String toUniversityName;
  final ConnectionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConnectionRequestModel({
    required this.id,
    required this.fromCircleId,
    required this.toCircleId,
    required this.fromCircleName,
    required this.toCircleName,
    required this.fromUniversityName,
    required this.toUniversityName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConnectionRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConnectionRequestModel(
      id: doc.id,
      fromCircleId: data['fromCircleId'] ?? '',
      toCircleId: data['toCircleId'] ?? '',
      fromCircleName: data['fromCircleName'] ?? '',
      toCircleName: data['toCircleName'] ?? '',
      fromUniversityName: data['fromUniversityName'] ?? '',
      toUniversityName: data['toUniversityName'] ?? '',
      status: ConnectionStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => ConnectionStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fromCircleId': fromCircleId,
      'toCircleId': toCircleId,
      'fromCircleName': fromCircleName,
      'toCircleName': toCircleName,
      'fromUniversityName': fromUniversityName,
      'toUniversityName': toUniversityName,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ConnectionRequestModel copyWith({
    String? id,
    String? fromCircleId,
    String? toCircleId,
    String? fromCircleName,
    String? toCircleName,
    String? fromUniversityName,
    String? toUniversityName,
    ConnectionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConnectionRequestModel(
      id: id ?? this.id,
      fromCircleId: fromCircleId ?? this.fromCircleId,
      toCircleId: toCircleId ?? this.toCircleId,
      fromCircleName: fromCircleName ?? this.fromCircleName,
      toCircleName: toCircleName ?? this.toCircleName,
      fromUniversityName: fromUniversityName ?? this.fromUniversityName,
      toUniversityName: toUniversityName ?? this.toUniversityName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

