import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/circle_model.dart';
import '../models/connection_request_model.dart';
import '../models/message_model.dart';

// ⬇️ --- 新規追加 --- ⬇️
import '../models/dm_channel_model.dart';
import '../models/dm_message_model.dart';
// ⬆️ --- 新規追加 --- ⬆️

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Circles collection
  static const String circlesCollection = 'circles';
  static const String connectionRequestsCollection = 'connectionRequests';
  static const String chatsCollection = 'chats'; // サークル間チャット
  static const String messagesCollection = 'messages';

  // ⬇️ --- 新規追加 --- ⬇️
  // 個人-サークル間DM
  static const String dmChannelsCollection = 'dm_channels'; 
  static const String dmMessagesCollection = 'dm_messages';
  // ⬆️ --- 新規追加 --- ⬆️

  // Circle operations
  Future<void> createCircle(CircleModel circle) async {
    try {
      await _firestore
          .collection(circlesCollection)
          .doc(circle.id)
          .set(circle.toFirestore());
    } catch (e) {
      throw Exception('サークルの作成に失敗しました: $e');
    }
  }

  Future<CircleModel?> getCircle(String circleId) async {
    try {
      final doc =
          await _firestore.collection(circlesCollection).doc(circleId).get();

      if (doc.exists) {
        return CircleModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('サークルの取得に失敗しました: $e');
    }
  }

  Stream<List<CircleModel>> getCirclesStream() {
    return _firestore
        .collection(circlesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CircleModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<List<CircleModel>> searchCircles(String query) async {
    // ... (既存のコード)
    try {
      final querySnapshot = await _firestore
          .collection(circlesCollection)
          .where('circleName', isGreaterThanOrEqualTo: query)
          .where('circleName', isLessThan: '${query}z')
          .get();

      return querySnapshot.docs
          .map((doc) => CircleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('サークルの検索に失敗しました: $e');
    }
  }

  Future<List<CircleModel>> getCirclesByUniversity(
      String universityName) async {
    // ... (既存のコード)
    try {
      final querySnapshot = await _firestore
          .collection(circlesCollection)
          .where('universityName', isEqualTo: universityName)
          .get();

      return querySnapshot.docs
          .map((doc) => CircleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('大学別サークル取得に失敗しました: $e');
    }
  }

  // Connection request operations
  Future<void> sendConnectionRequest(ConnectionRequestModel request) async {
    // ... (既存のコード)
    try {
      await _firestore
          .collection(connectionRequestsCollection)
          .add(request.toFirestore());
    } catch (e) {
      throw Exception('コネクションリクエストの送信に失敗しました: $e');
    }
  }

  Stream<List<ConnectionRequestModel>> getReceivedConnectionRequests(
      String circleId) {
    // ... (既存のコード)
    return _firestore
        .collection(connectionRequestsCollection)
        .where('toCircleId', isEqualTo: circleId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConnectionRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<ConnectionRequestModel>> getSentConnectionRequests(
      String circleId) {
    // ... (既存のコード)
    return _firestore
        .collection(connectionRequestsCollection)
        .where('fromCircleId', isEqualTo: circleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConnectionRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<ConnectionRequestModel>> getApprovedConnections(String circleId) {
    // ... (既存のコード)
    return _firestore
        .collection(connectionRequestsCollection)
        .where('status', isEqualTo: 'approved')
        .where('toCircleId', isEqualTo: circleId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConnectionRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateConnectionRequestStatus(
      String requestId, ConnectionStatus status) async {
    // ... (既存のコード)
    try {
      await _firestore
          .collection(connectionRequestsCollection)
          .doc(requestId)
          .update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('コネクションリクエストの更新に失敗しました: $e');
    }
  }

  Future<void> deleteConnectionRequest(String requestId) async {
    // ... (既存のコード)
    try {
      await _firestore
          .collection(connectionRequestsCollection)
          .doc(requestId)
          .delete();
    } catch (e) {
      throw Exception('コネクションリクエストの削除に失敗しました: $e');
    }
  }

  // Chat operations
  Future<void> sendMessage(MessageModel message) async {
    // ... (既存のコード)
    try {
      await _firestore
          .collection(chatsCollection)
          .doc(message.chatId)
          .collection(messagesCollection)
          .add(message.toFirestore());
    } catch (e) {
      throw Exception('メッセージの送信に失敗しました: $e');
    }
  }

  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    // ... (既存のコード)
    return _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> createChat(
      String connectionId, Map<String, String> participants) async {
    // ... (既存のコード)
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

  // ⬇️ --- ここからDM機能 (新規追加) --- ⬇️

  /// 個人-サークル間のDMチャンネルを取得または作成する
  Future<String> getOrCreateDmChannel({
    required String individualId,
    required String circleId,
    required String individualName,
    required String circleName,
    String? circleAvatarUrl,
    String? individualAvatarUrl, // 将来用
  }) async {
    // 既にチャンネルが存在するか確認 (個人IDとサークルIDの両方を含む)
    final query = _firestore
        .collection(dmChannelsCollection)
        .where('participants', arrayContains: individualId);
        
    final snapshot = await query.get();
    
    // 参加者リストを使ってクライアント側でフィルタリング
    // (Firestoreの 'arrayContains' は1つしか指定できないため)
    final existingChannels = snapshot.docs.where((doc) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      return participants.contains(circleId);
    }).toList();

    if (existingChannels.isNotEmpty) {
      // チャンネルが既に存在する場合
      return existingChannels.first.id;
    } else {
      // チャンネルが存在しない場合、新規作成
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

  /// サークルが受信したDMチャンネル一覧を取得する
  Stream<List<DmChannelModel>> getDmChannelsForCircle(String circleId) {
    return _firestore
        .collection(dmChannelsCollection)
        .where('circleId', isEqualTo: circleId) // 自分のサークルIDで絞り込み
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DmChannelModel.fromFirestore(doc))
            .toList());
  }

  /// 個人ユーザーが送受信したDMチャンネル一覧を取得する
  Stream<List<DmChannelModel>> getDmChannelsForIndividual(String individualId) {
    return _firestore
        .collection(dmChannelsCollection)
        .where('individualId', isEqualTo: individualId) // 自分の個人IDで絞り込み
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DmChannelModel.fromFirestore(doc))
            .toList());
  }

  /// DMのメッセージ一覧を取得する
  Stream<List<DmMessageModel>> getDmMessagesStream(String channelId) {
    return _firestore
        .collection(dmChannelsCollection)
        .doc(channelId)
        .collection(dmMessagesCollection) // サブコレクション名は dm_messages
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DmMessageModel.fromFirestore(doc))
            .toList());
  }

  /// DMメッセージを送信する
  Future<void> sendDmMessage({
    required String channelId,
    required DmMessageModel message,
  }) async {
    // トランザクションでメッセージ追加とチャンネル情報の更新を同時に行う
    await _firestore.runTransaction((transaction) async {
      final channelRef = _firestore.collection(dmChannelsCollection).doc(channelId);
      final messageRef = channelRef.collection(dmMessagesCollection).doc();

      // メッセージを追加
      transaction.set(messageRef, message.toFirestore());

      // チャンネルの最終メッセージ情報を更新
      transaction.update(channelRef, {
        'lastMessage': message.message,
        'lastMessageTimestamp': message.timestamp,
        // TODO: 必要に応じて未読フラグなどもここで更新
      });
    });
  }
  // ⬆️ --- DM機能ここまで --- ⬆️

}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});