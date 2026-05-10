import 'package:cloud_firestore/cloud_firestore.dart';

class BoardCommentModel {
  final String id;
  final String threadId;
  final String authorId;
  final String authorName;
  final String body;
  final DateTime createdAt;

  BoardCommentModel({
    required this.id,
    required this.threadId,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.createdAt,
  });

  factory BoardCommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAt = data['createdAt'];

    return BoardCommentModel(
      id: doc.id,
      threadId: data['threadId'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '名無しユーザー',
      body: data['body'] ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'threadId': threadId,
      'authorId': authorId,
      'authorName': authorName,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'participationType': 'individual',
    };
  }
}
