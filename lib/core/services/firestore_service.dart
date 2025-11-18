import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/circle_model.dart';
import '../models/connection_request_model.dart';
import '../models/message_model.dart';
import '../models/dm_channel_model.dart';
import '../models/dm_message_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // コレクション名
  static const String circlesCollection = 'circles';
  static const String connectionRequestsCollection = 'connectionRequests';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String dmChannelsCollection = 'dm_channels'; 
  static const String dmMessagesCollection = 'dm_messages';
  static const String usersCollection = 'users';
  
  // ⬇️ --- 新規追加: ユーザー管理機能 --- ⬇️
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(usersCollection).doc(user.id).set(user.toFirestore());
    } catch (e) {
      print("🔥 ERROR in createUser: $e");
      throw Exception('ユーザーの作成に失敗しました: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("🔥 ERROR in getUser: $e");
      throw Exception('ユーザー情報の取得に失敗しました: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection(usersCollection).doc(user.id).update(user.toFirestore());
    } catch (e) {
      print("🔥 ERROR in updateUser: $e");
      throw Exception('ユーザー情報の更新に失敗しました: $e');
    }
  }
  // ⬆️ --- 新規追加ここまで --- ⬆️

  // --- Circle operations ---
  Future<void> createCircle(CircleModel circle) async {
    try {
      await _firestore.collection(circlesCollection).doc(circle.id).set(circle.toFirestore());
    } catch (e) {
      print("🔥 ERROR in createCircle: $e"); // デバッグ出力
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
      print("🔥 ERROR in getCircle: $e"); // デバッグ出力
      throw Exception('サークルの取得に失敗しました: $e');
    }
  }

  Stream<List<CircleModel>> getCirclesStream() {
    return _firestore
        .collection(circlesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) { // 👈 ストリームのエラーを捕捉
          print("🔥 ERROR in getCirclesStream: $e"); // ログに出力
          throw e; // エラーを再スローしてUIにも伝える
        })
        .map((snapshot) {
      return snapshot.docs.map((doc) => CircleModel.fromFirestore(doc)).toList();
    });
  }

  Future<List<CircleModel>> searchCircles(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(circlesCollection)
          .where('circleName', isGreaterThanOrEqualTo: query)
          .where('circleName', isLessThan: '${query}z')
          .get();
      return querySnapshot.docs.map((doc) => CircleModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("🔥 ERROR in searchCircles: $e");
      throw Exception('サークルの検索に失敗しました: $e');
    }
  }

  Future<List<CircleModel>> getCirclesByUniversity(String universityName) async {
    try {
      final querySnapshot = await _firestore.collection(circlesCollection).where('universityName', isEqualTo: universityName).get();
      return querySnapshot.docs.map((doc) => CircleModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("🔥 ERROR in getCirclesByUniversity: $e");
      throw Exception('大学別サークル取得に失敗しました: $e');
    }
  }

  Future<void> updateCircle(CircleModel circle) async {
    try {
      await _firestore
          .collection(circlesCollection)
          .doc(circle.id)
          .update(circle.toFirestore());
    } catch (e) {
      print("🔥 ERROR in updateCircle: $e");
      throw Exception('サークル情報の更新に失敗しました: $e');
    }
  }

  Stream<List<CircleModel>> getMyCircles(String userId) {
    return _firestore
        .collection(circlesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) { // 👈 エラー捕捉
          print("🔥 ERROR in getMyCircles: $e"); 
          throw e;
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => CircleModel.fromFirestore(doc))
            .toList());
  }


  // --- Connection request operations ---
  Future<void> sendConnectionRequest(ConnectionRequestModel request) async {
    try {
      await _firestore.collection(connectionRequestsCollection).add(request.toFirestore());
    } catch (e) {
      print("🔥 ERROR in sendConnectionRequest: $e");
      throw Exception('コネクションリクエストの送信に失敗しました: $e');
    }
  }

  Stream<List<ConnectionRequestModel>> getReceivedConnectionRequests(String circleId) {
    return _firestore
        .collection(connectionRequestsCollection)
        .where('toCircleId', isEqualTo: circleId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) { // 👈 エラー捕捉
          print("🔥 ERROR in getReceivedConnectionRequests: $e");
          throw e;
        })
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConnectionRequestModel.fromFirestore(doc))
          .toList();
    });
  }
  
  Stream<List<ConnectionRequestModel>> getSentConnectionRequests(String circleId) {
    return _firestore
        .collection(connectionRequestsCollection)
        .where('fromCircleId', isEqualTo: circleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) { // 👈 エラー捕捉
          print("🔥 ERROR in getSentConnectionRequests: $e");
          throw e;
        })
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
        .handleError((e) { // 👈 エラー捕捉
          print("🔥 ERROR in getApprovedConnections: $e");
          throw e;
        })
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConnectionRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateConnectionRequestStatus(String requestId, ConnectionStatus status) async {
    try {
      await _firestore.collection(connectionRequestsCollection).doc(requestId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("🔥 ERROR in updateConnectionRequestStatus: $e");
      throw Exception('コネクションリクエストの更新に失敗しました: $e');
    }
  }

  Future<void> deleteConnectionRequest(String requestId) async {
    try {
      await _firestore.collection(connectionRequestsCollection).doc(requestId).delete();
    } catch (e) {
      print("🔥 ERROR in deleteConnectionRequest: $e");
      throw Exception('コネクションリクエストの削除に失敗しました: $e');
    }
  }

  // --- Chat operations ---
  Future<void> sendMessage(MessageModel message) async {
    try {
      await _firestore.collection(chatsCollection).doc(message.chatId).collection(messagesCollection).add(message.toFirestore());
    } catch (e) {
      print("🔥 ERROR in sendMessage: $e");
      throw Exception('メッセージの送信に失敗しました: $e');
    }
  }

  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .handleError((e) { // 👈 エラー捕捉
          print("🔥 ERROR in getMessagesStream: $e");
          throw e;
        })
        .map((snapshot) {
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
      print("🔥 ERROR in createChat: $e");
      throw Exception('チャットの作成に失敗しました: $e');
    }
  }

  // --- DM機能 ---
  Future<String> getOrCreateDmChannel({
    required String individualId,
    required String circleId,
    required String individualName,
    required String circleName,
    String? circleAvatarUrl,
    String? individualAvatarUrl,
  }) async {
    try {
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
    } catch (e) {
      print("🔥 ERROR in getOrCreateDmChannel: $e"); // デバッグ出力
      rethrow;
    }
  }

  Stream<List<DmChannelModel>> getDmChannelsForCircle(String circleId) {
    return _firestore
        .collection(dmChannelsCollection)
        .where('circleId', isEqualTo: circleId) 
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .handleError((e) { // 👈 エラー捕捉
          print("🔥 ERROR in getDmChannelsForCircle: $e"); // ログに詳細を出力
          throw e;
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => DmChannelModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<DmChannelModel>> getDmChannelsForIndividual(String individualId) {
    return _firestore
        .collection(dmChannelsCollection)
        .where('individualId', isEqualTo: individualId) 
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .handleError((e) { // 👈 エラー捕捉
          print("🔥 ERROR in getDmChannelsForIndividual: $e"); // ログに詳細を出力
          throw e;
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => DmChannelModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<DmMessageModel>> getDmMessagesStream(String channelId) {
    return _firestore
        .collection(dmChannelsCollection)
        .doc(channelId)
        .collection(dmMessagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .handleError((e) { // 👈 エラー捕捉
          print("🔥 ERROR in getDmMessagesStream: $e");
          throw e;
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => DmMessageModel.fromFirestore(doc))
            .toList());
  }
  
  Future<void> sendDmMessage({
    required String channelId,
    required DmMessageModel message,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final channelRef = _firestore.collection(dmChannelsCollection).doc(channelId);
        final messageRef = channelRef.collection(dmMessagesCollection).doc();
        transaction.set(messageRef, message.toFirestore());
        transaction.update(channelRef, {
          'lastMessage': message.message,
          'lastMessageTimestamp': message.timestamp,
        });
      });
    } catch (e) {
      print("🔥 ERROR in sendDmMessage: $e");
      throw Exception('メッセージの送信に失敗しました: $e');
    }
  }

}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});