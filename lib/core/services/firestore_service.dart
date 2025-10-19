import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/circle_model.dart';
import '../models/connection_request_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Circles collection
  static const String circlesCollection = 'circles';
  static const String connectionRequestsCollection = 'connectionRequests';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';

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
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

