import 'package:cloud_firestore/cloud_firestore.dart';

class BoardThreadModel {
  final String id;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int commentCount;

  BoardThreadModel({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
    this.commentCount = 0,
  });

  factory BoardThreadModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAt = data['createdAt'];
    final updatedAt = data['updatedAt'];

    return BoardThreadModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '名無しユーザー',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : DateTime.now(),
      commentCount: data['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'commentCount': commentCount,
      'participationType': 'individual',
    };
  }
}
