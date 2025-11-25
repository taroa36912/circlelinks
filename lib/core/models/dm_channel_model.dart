import 'package:cloud_firestore/cloud_firestore.dart';

class DmChannelModel {
  final String id; // ドキュメントID
  final String individualId; // 個人のAuth ID
  final String individualName; // 個人の表示名 (初回メッセージ時に設定)
  final String? individualAvatarUrl; // 個人のアバター (将来用)
  final String circleId; // サークルのAuth ID
  final String circleName;
  final String? circleAvatarUrl;
  
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final List<String> participants; // [individualId, circleId]

  DmChannelModel({
    required this.id,
    required this.individualId,
    required this.individualName,
    this.individualAvatarUrl,
    required this.circleId,
    required this.circleName,
    this.circleAvatarUrl,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.participants,
  });

  factory DmChannelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DmChannelModel(
      id: doc.id,
      individualId: data['individualId'] ?? '',
      individualName: data['individualName'] ?? '不明なユーザー',
      individualAvatarUrl: data['individualAvatarUrl'],
      circleId: data['circleId'] ?? '',
      circleName: data['circleName'] ?? '不明なサークル',
      circleAvatarUrl: data['circleAvatarUrl'],
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTimestamp: (data['lastMessageTimestamp'] as Timestamp).toDate(),
      participants: List<String>.from(data['participants'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'individualId': individualId,
      'individualName': individualName,
      'individualAvatarUrl': individualAvatarUrl,
      'circleId': circleId,
      'circleName': circleName,
      'circleAvatarUrl': circleAvatarUrl,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': Timestamp.fromDate(lastMessageTimestamp),
      'participants': participants,
    };
  }
}