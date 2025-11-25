import 'package:cloud_firestore/cloud_firestore.dart';

class DmMessageModel {
  final String id;
  final String senderId;
  final String senderName; // デバッグ用
  final String message;
  final DateTime timestamp;

  DmMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });

  factory DmMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DmMessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}