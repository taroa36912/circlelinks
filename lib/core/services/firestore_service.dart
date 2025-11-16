import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/circle_model.dart';
import '../models/connection_request_model.dart';
import '../models/message_model.dart';
import '../models/dm_channel_model.dart';
import '../models/dm_message_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // コレクション名
  static const String circlesCollection = 'circles';
  static const String connectionRequestsCollection = 'connectionRequests';
  static const String chatsCollection = 'chats'; // サークル間チャット
  static const String messagesCollection = 'messages';
  static const String dmChannelsCollection = 'dm_channels'; 
  static const String dmMessagesCollection = 'dm_messages';

  // --- Circle operations (変更なし) ---
  Future<void> createCircle(CircleModel circle) async {
    try {
      await _firestore.collection(circlesCollection).doc(circle.id).set(circle.toFirestore());
    } catch (e) {
      throw Exception('サークルの作成に失敗しました: $e');
    }
  }
  Future<CircleModel?> getCircle(String circleId) async {
    try {
      final doc = await _firestore.collection(circlesCollection).doc(circleId).get();
      if (doc.exists) {
        return CircleModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('サークルの取得に失敗しました: $e');
    }
  }
  Stream<List<CircleModel>> getCirclesStream() {
    return _firestore.collection(circlesCollection).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CircleModel.fromFirestore(doc)).toList();
    });
  }
  // ... (searchCircles, getCirclesByUniversity 変更なし) ...
  Future<List<CircleModel>> searchCircles(String query) async {
    try {
      final querySnapshot = await _firestore.collection(circlesCollection).where('circleName', isGreaterThanOrEqualTo: query).where('circleName', isLessThan: '${query}z').get();
      return querySnapshot.docs.map((doc) => CircleModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('サークルの検索に失敗しました: $e');
    }
  }
  Future<List<CircleModel>> getCirclesByUniversity(String universityName) async {
    try {
      final querySnapshot = await _firestore.collection(circlesCollection).where('universityName', isEqualTo: universityName).get();
      return querySnapshot.docs.map((doc) => CircleModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('大学別サークル取得に失敗しました: $e');
    }
  }


  // --- Connection request operations ---
  Future<void> sendConnectionRequest(ConnectionRequestModel request) async {
    try {
      await _firestore.collection(connectionRequestsCollection).add(request.toFirestore());
    } catch (e) {
      throw Exception('コネクションリクエストの送信に失敗しました: $e');
    }
  }

  // ⬇️ --- 修正 1: `descending: false` -> `true` --- ⬇️
  Stream<List<ConnectionRequestModel>> getReceivedConnectionRequests(
      String circleId) {
    return _firestore
        .collection(connectionRequestsCollection)
        .where('toCircleId', isEqualTo: circleId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true) // 👈 true (降順) に戻す
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConnectionRequestModel.fromFirestore(doc))
          .toList();
    });
  }
  // ⬆️ --- 修正ここまで --- ⬆️
  
  Stream<List<ConnectionRequestModel>> getSentConnectionRequests(
      String circleId) {
    return _firestore
        .collection(connectionRequestsCollection)
        .where('fromCircleId', isEqualTo: circleId)
        .orderBy('createdAt', descending: true) // 👈 true (降順)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConnectionRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<ConnectionRequestModel>> getApprovedConnections(String circleId) {
    return _firestore
        .collection(connectionRequestsCollection)
        .where('toCircleId', isEqualTo: circleId) 
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConnectionRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  // ... (update, delete, Chat operations 変更なし) ...
  Future<void> updateConnectionRequestStatus(String requestId, ConnectionStatus status) async {
    try {
      await _firestore.collection(connectionRequestsCollection).doc(requestId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('コネクションリクエストの更新に失敗しました: $e');
    }
  }
  Future<void> deleteConnectionRequest(String requestId) async {
    try {
      await _firestore.collection(connectionRequestsCollection).doc(requestId).delete();
    } catch (e) {
      throw Exception('コネクションリクエストの削除に失敗しました: $e');
    }
  }
  Future<void> sendMessage(MessageModel message) async {
    try {
      await _firestore.collection(chatsCollection).doc(message.chatId).collection(messagesCollection).add(message.toFirestore());
    } catch (e) {
      throw Exception('メッセージの送信に失敗しました: $e');
    }
  }
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore.collection(chatsCollection).doc(chatId).collection(messagesCollection).orderBy('timestamp', descending: false).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList();
    });
  }
  Future<void> createChat(String connectionId, Map<String, String> participants) async {
    try {
      await _firestore.collection(chatsCollection).doc(connectionId).set({
        'participants': participants,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastMessageTime': null,
      });
    } catch (e) {
      throw Exception('チャットの作成に失敗しました: $e');
    }
  }


  // --- DM機能 ---
  
  // getOrCreateDmChannel (変更なし)
  Future<String> getOrCreateDmChannel({
    required String individualId,
    required String circleId,
    required String individualName,
    required String circleName,
    String? circleAvatarUrl,
    String? individualAvatarUrl,
  }) async {
    final query = _firestore.collection(dmChannelsCollection).where('participants', arrayContains: individualId);
    final snapshot = await query.get();
    final existingChannels = snapshot.docs.where((doc) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      return participants.contains(circleId);
    }).toList();

    if (existingChannels.isNotEmpty) {
      return existingChannels.first.id;
    } else {
      final newChannelRef = _firestore.collection(dmChannelsCollection).doc();
      final newChannel = DmChannelModel(
        id: newChannelRef.id,
        individualId: individualId,
        individualName: individualName.isEmpty ? 'ゲストユーザー' : individualName,
        individualAvatarUrl: individualAvatarUrl,
        circleId: circleId,
        circleName: circleName,
        circleAvatarUrl: circleAvatarUrl,
        lastMessage: 'DMが開始されました。',
        lastMessageTimestamp: DateTime.now(),
        participants: [individualId, circleId],
      );
      await newChannelRef.set(newChannel.toFirestore());
      return newChannelRef.id;
    }
  }

  // ⬇️ --- 修正 2: `descending: false` -> `true` --- ⬇️
  Stream<List<DmChannelModel>> getDmChannelsForCircle(String circleId) {
    return _firestore
        .collection(dmChannelsCollection)
        .where('circleId', isEqualTo: circleId) 
        .orderBy('lastMessageTimestamp', descending: true) // 👈 true (降順) に戻す
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DmChannelModel.fromFirestore(doc))
            .toList());
  }
  // ⬆️ --- 修正ここまで --- ⬆️

  // ⬇️ --- 修正 3: `descending: false` -> `true` --- ⬇️
  Stream<List<DmChannelModel>> getDmChannelsForIndividual(String individualId) {
    return _firestore
        .collection(dmChannelsCollection)
        .where('individualId', isEqualTo: individualId) 
        .orderBy('lastMessageTimestamp', descending: true) // 👈 true (降順) に戻す
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DmChannelModel.fromFirestore(doc))
            .toList());
  }
  // ⬆️ --- 修正ここまで --- ⬆️

  // getDmMessagesStream (変更なし, 昇順のまま)
  Stream<List<DmMessageModel>> getDmMessagesStream(String channelId) {
    return _firestore
        .collection(dmChannelsCollection)
        .doc(channelId)
        .collection(dmMessagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DmMessageModel.fromFirestore(doc))
            .toList());
  }
  
  // sendDmMessage (変更なし)
  Future<void> sendDmMessage({
    required String channelId,
    required DmMessageModel message,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final channelRef = _firestore.collection(dmChannelsCollection).doc(channelId);
      final messageRef = channelRef.collection(dmMessagesCollection).doc();
      transaction.set(messageRef, message.toFirestore());
      transaction.update(channelRef, {
        'lastMessage': message.message,
        'lastMessageTimestamp': message.timestamp,
      });
    });
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});