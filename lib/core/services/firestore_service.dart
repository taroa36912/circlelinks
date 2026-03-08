import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart'; // 👈 1. 新規追加

import '../models/circle_model.dart';
import '../models/connection_request_model.dart';
import '../models/message_model.dart';
import '../models/dm_channel_model.dart';
import '../models/dm_message_model.dart';
import '../models/user_model.dart';
import '../models/event_model.dart'; // New
import '../models/attendance_model.dart'; // New
import '../models/member_model.dart';

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
  static const String eventsCollection = 'events'; // New
  static const String attendancesCollection = 'attendances'; // New

  // --- User operations ---
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(user.id)
          .set(user.toFirestore());
    } catch (e) {
      print("🔥 ERROR in createUser: $e");
      throw Exception('ユーザーの作成に失敗しました: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc =
          await _firestore.collection(usersCollection).doc(userId).get();
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
      await _firestore
          .collection(usersCollection)
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      print("🔥 ERROR in updateUser: $e");
      throw Exception('ユーザー情報の更新に失敗しました: $e');
    }
  }

  // --- Circle operations ---
  Future<void> createCircle(CircleModel circle, String creatorId) async {
    try {
      final batch = _firestore.batch();

      final circleRef = _firestore.collection(circlesCollection).doc(circle.id);
      batch.set(circleRef, circle.toFirestore());

      final memberRef = circleRef.collection('members').doc(creatorId);
      final member = MemberModel(
        id: creatorId,
        userId: creatorId,
        role: 'admin',
        joinedAt: DateTime.now(),
      );
      batch.set(memberRef, member.toFirestore());

      await batch.commit();
    } catch (e) {
      print("🔥 ERROR in createCircle: $e");
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
      print("🔥 ERROR in getCircle: $e");
      throw Exception('サークルの取得に失敗しました: $e');
    }
  }

  Stream<List<CircleModel>> getCirclesStream() {
    return _firestore
        .collection(circlesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) {
      print("🔥 ERROR in getCirclesStream: $e");
      throw e;
    }).map((snapshot) {
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
      print("🔥 ERROR in searchCircles: $e");
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
    // 1. まず、自分が admin である 'members' ドキュメントを監視する
    return _firestore
        .collectionGroup('members')
        .where('userId', isEqualTo: userId)
        .where('role', isEqualTo: 'admin')
        .snapshots()
        .asyncMap<List<CircleModel>>((snapshot) async {
      // サークルIDのリストを抽出
      final circleIds = snapshot.docs
          .map((doc) => doc.reference.parent.parent?.id)
          .whereType<String>()
          .toList();

      if (circleIds.isEmpty) return [];

      // 2. 抽出したIDを元にサークル本体のデータを取得
      // (whereIn は最大30件までの制限がありますが、個人の管理数なら通常十分です)
      // 30件を超える可能性がある場合は、分割して取得するか現在のループ方式を維持します
      try {
        final circlesSnapshot = await _firestore
            .collection(circlesCollection)
            .where(FieldPath.documentId, whereIn: circleIds.take(30).toList())
            .get();

        final circles = circlesSnapshot.docs
            .map((doc) => CircleModel.fromFirestore(doc))
            .toList();

        // 作成日順にソート
        circles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return circles;
      } catch (e) {
        print("🔥 ERROR in fetching circle details: $e");
        return [];
      }
    }).handleError((e) {
      print("🔥 ERROR in getMyCircles: $e");
      throw e;
    });
  }

  Stream<List<CircleModel>> getJoinedCircles(String userId) {
    return _firestore
        .collectionGroup('members')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap<List<CircleModel>>((snapshot) async {
      final circleIds = snapshot.docs
          .map((doc) => doc.reference.parent.parent?.id)
          .whereType<String>()
          .toList();

      if (circleIds.isEmpty) return [];

      try {
        final circlesSnapshot = await _firestore
            .collection(circlesCollection)
            .where(FieldPath.documentId, whereIn: circleIds.take(30).toList())
            .get();

        final circles = circlesSnapshot.docs
            .map((doc) => CircleModel.fromFirestore(doc))
            .toList();

        circles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return circles;
      } catch (e) {
        print("🔥 ERROR in fetching joined circles: $e");
        return [];
      }
    }).handleError((e) {
      print("🔥 ERROR in getJoinedCircles: $e");
      throw e;
    });
  }

  // --- Member operations ---
  Future<void> addCircleMember(
      String circleId, String userId, String role) async {
    try {
      final member = MemberModel(
        id: userId,
        userId: userId,
        role: role,
        joinedAt: DateTime.now(),
      );
      await _firestore
          .collection(circlesCollection)
          .doc(circleId)
          .collection('members')
          .doc(userId)
          .set(member.toFirestore());
    } catch (e) {
      print("🔥 ERROR in addCircleMember: $e");
      throw Exception('メンバーの追加に失敗しました: $e');
    }
  }

  Future<void> updateCircleMemberRole(
      String circleId, String userId, String newRole) async {
    try {
      await _firestore
          .collection(circlesCollection)
          .doc(circleId)
          .collection('members')
          .doc(userId)
          .update({'role': newRole});
    } catch (e) {
      print("🔥 ERROR in updateCircleMemberRole: $e");
      throw Exception('メンバー権限の更新に失敗しました: $e');
    }
  }

  Future<void> removeCircleMember(String circleId, String userId) async {
    try {
      await _firestore
          .collection(circlesCollection)
          .doc(circleId)
          .collection('members')
          .doc(userId)
          .delete();
    } catch (e) {
      print("🔥 ERROR in removeCircleMember: $e");
      throw Exception('メンバーの削除に失敗しました: $e');
    }
  }

  Stream<List<MemberModel>> getCircleMembersStream(String circleId) {
    return _firestore
        .collection(circlesCollection)
        .doc(circleId)
        .collection('members')
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MemberModel.fromFirestore(doc))
            .toList());
  }

  // --- Connection request operations ---
  Future<void> sendConnectionRequest(ConnectionRequestModel request) async {
    try {
      await _firestore
          .collection(connectionRequestsCollection)
          .add(request.toFirestore());
    } catch (e) {
      print("🔥 ERROR in sendConnectionRequest: $e");
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
        .handleError((e) {
      print("🔥 ERROR in getReceivedConnectionRequests: $e");
      throw e;
    }).map((snapshot) {
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
        .handleError((e) {
      print("🔥 ERROR in getSentConnectionRequests: $e");
      throw e;
    }).map((snapshot) {
      return snapshot.docs
          .map((doc) => ConnectionRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  // ⬇️ --- 修正: 受信と送信の両方を結合して返す --- ⬇️
  Stream<List<ConnectionRequestModel>> getApprovedConnections(String circleId) {
    // 1. 自分宛てのリクエスト (Approved)
    final receivedStream = _firestore
        .collection(connectionRequestsCollection)
        .where('toCircleId', isEqualTo: circleId)
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConnectionRequestModel.fromFirestore(doc))
            .toList());

    // 2. 自分発のリクエスト (Approved)
    final sentStream = _firestore
        .collection(connectionRequestsCollection)
        .where('fromCircleId', isEqualTo: circleId)
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConnectionRequestModel.fromFirestore(doc))
            .toList());

    // 3. 2つのストリームを結合 (CombineLatest)
    return Rx.combineLatest2(
      receivedStream,
      sentStream,
      (List<ConnectionRequestModel> received,
          List<ConnectionRequestModel> sent) {
        // リストを結合
        return [...received, ...sent];
      },
    ).handleError((e) {
      print("🔥 ERROR in getApprovedConnections: $e");
      throw e;
    });
  }
  // ⬆️ --- 修正ここまで --- ⬆️

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
      print("🔥 ERROR in updateConnectionRequestStatus: $e");
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
      print("🔥 ERROR in deleteConnectionRequest: $e");
      throw Exception('コネクションリクエストの削除に失敗しました: $e');
    }
  }

  // --- Chat operations ---
  // ... (sendMessage, getMessagesStream, createChat 変更なし) ...
  Future<void> sendMessage(MessageModel message) async {
    try {
      await _firestore
          .collection(chatsCollection)
          .doc(message.chatId)
          .collection(messagesCollection)
          .add(message.toFirestore());
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
        .handleError((e) {
      print("🔥 ERROR in getMessagesStream: $e");
      throw e;
    }).map((snapshot) {
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
      print("🔥 ERROR in createChat: $e");
      throw Exception('チャットの作成に失敗しました: $e');
    }
  }

  // --- DM機能 ---
  Future<DmChannelModel?> getDmChannel(String channelId) async {
    try {
      final doc = await _firestore
          .collection(dmChannelsCollection)
          .doc(channelId)
          .get();
      if (doc.exists) {
        return DmChannelModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("🔥 ERROR in getDmChannel: $e");
      throw Exception('DMチャンネルの取得に失敗しました: $e');
    }
  }

  // ... (getOrCreateDmChannel, getDmChannelsForCircle, getDmChannelsForIndividual, getDmMessagesStream, sendDmMessage 変更なし) ...
  Future<String> getOrCreateDmChannel({
    required String individualId,
    required String circleId,
    required String individualName,
    required String circleName,
    String? circleAvatarUrl,
    String? individualAvatarUrl,
  }) async {
    try {
      final query = _firestore
          .collection(dmChannelsCollection)
          .where('participants', arrayContains: individualId);
      final snapshot = await query.get();
      final existingChannels = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['circleId'] == circleId &&
            data['individualId'] == individualId;
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
      print("🔥 ERROR in getOrCreateDmChannel: $e");
      rethrow;
    }
  }

  Stream<List<DmChannelModel>> getDmChannelsForCircle(String circleId) {
    return _firestore
        .collection(dmChannelsCollection)
        .where('circleId', isEqualTo: circleId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .handleError((e) {
      print("🔥 ERROR in getDmChannelsForCircle: $e");
      throw e;
    }).map((snapshot) => snapshot.docs
            .map((doc) => DmChannelModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<DmChannelModel>> getDmChannelsForIndividual(String individualId) {
    return _firestore
        .collection(dmChannelsCollection)
        .where('individualId', isEqualTo: individualId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .handleError((e) {
      print("🔥 ERROR in getDmChannelsForIndividual: $e");
      throw e;
    }).map((snapshot) => snapshot.docs
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
        .handleError((e) {
      print("🔥 ERROR in getDmMessagesStream: $e");
      throw e;
    }).map((snapshot) => snapshot.docs
            .map((doc) => DmMessageModel.fromFirestore(doc))
            .toList());
  }

  Future<void> sendDmMessage({
    required String channelId,
    required DmMessageModel message,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final channelRef =
            _firestore.collection(dmChannelsCollection).doc(channelId);
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

  // --- Event operations ---
  Future<void> createEvent(EventModel event) async {
    try {
      await _firestore
          .collection(eventsCollection)
          .doc(event.id)
          .set(event.toFirestore());
    } catch (e) {
      print("🔥 ERROR in createEvent: $e");
      throw Exception('イベントの作成に失敗しました: $e');
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore
          .collection(eventsCollection)
          .doc(event.id)
          .update(event.toFirestore());
    } catch (e) {
      print("🔥 ERROR in updateEvent: $e");
      throw Exception('イベントの更新に失敗しました: $e');
    }
  }

  Future<EventModel?> getEvent(String eventId) async {
    try {
      final doc =
          await _firestore.collection(eventsCollection).doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("🔥 ERROR in getEvent: $e");
      throw Exception('イベントの取得に失敗しました: $e');
    }
  }

  Stream<List<EventModel>> getEventsForCircle(String circleId) {
    return _firestore
        .collection(eventsCollection)
        .where('circleId', isEqualTo: circleId)
        .orderBy('startTime', descending: false)
        .snapshots()
        .handleError((e) {
      print("🔥 ERROR in getEventsForCircle: $e");
      throw e;
    }).map((snapshot) =>
            snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  Future<List<EventModel>> getUpcomingEvents() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(eventsCollection)
          .where('startTime', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('startTime')
          .limit(20)
          .get();
      return querySnapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("🔥 ERROR in getUpcomingEvents: $e");
      throw Exception('イベント一覧の取得に失敗しました: $e');
    }
  }

  // --- Attendance operations ---
  Future<void> rsvpEvent(AttendanceModel attendance) async {
    try {
      // Check if already exists to prevent overwrite status if needed,
      // but for simple RSVP upsert is usually fine or we check explicitly.
      // Here we use set with merge true or just set.
      await _firestore
          .collection(eventsCollection)
          .doc(attendance.eventId)
          .collection(attendancesCollection)
          .doc(attendance.userId)
          .set(attendance.toFirestore());
    } catch (e) {
      print("🔥 ERROR in rsvpEvent: $e");
      throw Exception('イベントへの参加登録に失敗しました: $e');
    }
  }

  Future<void> markAttendance({
    required String eventId,
    required String userId,
    required String scanData, // In case we want to validate a token later
  }) async {
    try {
      // Direct update for now.
      // In real app, verify scanData matches logic.
      final attendanceRef = _firestore
          .collection(eventsCollection)
          .doc(eventId)
          .collection(attendancesCollection)
          .doc(userId);

      await attendanceRef.update({
        'status': 'attending', // Or 'checkedIn'
        'checkedInAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("🔥 ERROR in markAttendance: $e");
      throw Exception('出席確認に失敗しました: $e');
    }
  }

  Stream<List<AttendanceModel>> getEventAttendances(String eventId) {
    return _firestore
        .collection(eventsCollection)
        .doc(eventId)
        .collection(attendancesCollection)
        .snapshots()
        .handleError((e) {
      print("🔥 ERROR in getEventAttendances: $e");
      throw e;
    }).map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
