import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String circleId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? mainImageUrl;
  final int fee; // 0 if free
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.circleId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.mainImageUrl,
    this.fee = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      circleId: data['circleId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      mainImageUrl: data['mainImageUrl'],
      fee: data['fee'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'circleId': circleId,
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'mainImageUrl': mainImageUrl,
      'fee': fee,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  EventModel copyWith({
    String? id,
    String? circleId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? mainImageUrl,
    int? fee,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      fee: fee ?? this.fee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
