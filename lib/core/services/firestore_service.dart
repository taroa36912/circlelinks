import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
import '../models/project_model.dart';
import '../models/tag_model.dart';
import '../models/recruitment_model.dart';
import '../models/recruitment_application_model.dart';

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
  static const String projectsCollection = 'projects';
  static const String tagsCollection = 'tags';
  static const String recruitmentsCollection = 'recruitments';
  static const String applicationsCollection = 'applications';

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

  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(usersCollection)
        .doc(userId)
        .snapshots()
        .handleError((e) {
      print("🔥 ERROR in getUserStream: $e");
      throw e;
    }).map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
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

  Future<UserModel> upsertAuthenticatedUser({
    required String uid,
    required String email,
    String? userName,
    String? profileImageUrl,
  }) async {
    try {
      final existingUser = await getUser(uid);
      final resolvedEmail = email.trim();
      final resolvedRole = UserModel.roleFromEmail(resolvedEmail);
      final resolvedAccountType = UserModel.accountTypeFromRole(resolvedRole);
      final resolvedUserName = (userName != null && userName.trim().isNotEmpty)
          ? userName.trim()
          : existingUser?.userName ??
              (resolvedEmail.isNotEmpty
                  ? resolvedEmail.split('@').first
                  : '名無しユーザー');

      final user = UserModel(
        id: uid,
        email: resolvedEmail,
        userName: resolvedUserName,
        profileImageUrl: profileImageUrl ?? existingUser?.profileImageUrl,
        role: resolvedRole,
        accountType: resolvedAccountType,
        university: existingUser?.university,
        major: existingUser?.major,
        portfolioItems: existingUser?.portfolioItems,
        portfolioAchievements: existingUser?.portfolioAchievements,
        portfolioSkills: existingUser?.portfolioSkills,
        createdAt: existingUser?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (existingUser == null) {
        await createUser(user);
      } else {
        await updateUser(user);
      }

      return user;
    } catch (e) {
      print("🔥 ERROR in upsertAuthenticatedUser: $e");
      throw Exception('認証ユーザー情報の保存に失敗しました: $e');
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
          .collection('circles')
          .doc(circleId)
          .collection('members')
          .doc(userId)
          .update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('権限の変更に失敗しました: $e');
    }
  }

  Future<void> removeCircleMember(String circleId, String userId) async {
    try {
      // 1. メンバーサブコレクションから削除
      await _firestore
          .collection('circles')
          .doc(circleId)
          .collection('members')
          .doc(userId)
          .delete();

      // 2. サークル本体のメンバー数を -1 する
      await _firestore.collection('circles').doc(circleId).update({
        'memberCount': FieldValue.increment(-1),
      });
    } catch (e) {
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
          .where('individualId', isEqualTo: individualId);
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

  // --- Legacy attendance operations ---
  Future<void> rsvpEvent(AttendanceModel attendance) async {
    try {
      await _firestore
          .collection(eventsCollection)
          .doc(attendance.eventId)
          .collection(attendancesCollection)
          .doc(attendance.userId)
          .set(attendance.toFirestore());
    } catch (e) {
      debugPrint("🔥 ERROR in rsvpEvent: $e");
      throw Exception('イベントへの参加登録に失敗しました: $e');
    }
  }

  Stream<List<AttendanceModel>> getEventAttendances(String eventId) {
    return _firestore
        .collection(eventsCollection)
        .doc(eventId)
        .collection(attendancesCollection)
        .snapshots()
        .handleError((e) {
      debugPrint("🔥 ERROR in getEventAttendances: $e");
      throw e;
    }).map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
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
      debugPrint("🔥 ERROR in getUpcomingEvents: $e");
      throw Exception('イベント一覧の取得に失敗しました: $e');
    }
  }

  Future<List<EventModel>> getVisibleEventsForUser(String userId) async {
    try {
      final memberSnapshot = await _firestore
          .collectionGroup('members')
          .where('userId', isEqualTo: userId)
          .get();

      final myCircleIds = memberSnapshot.docs
          .map((doc) => doc.reference.parent.parent?.id)
          .whereType<String>()
          .toSet();

      final visibleCreatorCircleIds = <String>{...myCircleIds};
      for (final circleId in myCircleIds) {
        final received = await _firestore
            .collection(connectionRequestsCollection)
            .where('toCircleId', isEqualTo: circleId)
            .where('status', isEqualTo: 'approved')
            .get();
        for (final doc in received.docs) {
          final data = doc.data();
          final fromCircleId = (data['fromCircleId'] as String?) ?? '';
          if (fromCircleId.isNotEmpty) {
            visibleCreatorCircleIds.add(fromCircleId);
          }
        }

        final sent = await _firestore
            .collection(connectionRequestsCollection)
            .where('fromCircleId', isEqualTo: circleId)
            .where('status', isEqualTo: 'approved')
            .get();
        for (final doc in sent.docs) {
          final data = doc.data();
          final toCircleId = (data['toCircleId'] as String?) ?? '';
          if (toCircleId.isNotEmpty) {
            visibleCreatorCircleIds.add(toCircleId);
          }
        }
      }

      final resultById = <String, EventModel>{};

      final publicSnapshot = await _firestore
          .collection(eventsCollection)
          .where('isDraft', isEqualTo: false)
          .where('visibility', isEqualTo: 'public')
          .orderBy('startTime', descending: false)
          .limit(200)
          .get();
      for (final doc in publicSnapshot.docs) {
        final event = EventModel.fromFirestore(doc);
        resultById[event.id] = event;
      }

      if (visibleCreatorCircleIds.isNotEmpty) {
        final ids = visibleCreatorCircleIds.toList();
        for (var i = 0; i < ids.length; i += 10) {
          final chunk = ids.sublist(i, (i + 10).clamp(0, ids.length));
          final creatorSnapshot = await _firestore
              .collection(eventsCollection)
              .where('isDraft', isEqualTo: false)
              .where('circleId', whereIn: chunk)
              .orderBy('startTime', descending: false)
              .limit(200)
              .get();

          for (final doc in creatorSnapshot.docs) {
            final event = EventModel.fromFirestore(doc);
            if (event.visibility == 'public' ||
                event.allowedCircleIds.any(myCircleIds.contains) ||
                myCircleIds.contains(event.circleId)) {
              resultById[event.id] = event;
            }
          }
        }
      }

      final sorted = resultById.values.toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      return sorted;
    } catch (e) {
      debugPrint("🔥 ERROR in getVisibleEventsForUser: $e");
      throw Exception('閲覧可能なイベントの取得に失敗しました: $e');
    }
  }

  // --- Project operations ---
  Future<void> createProject(ProjectModel project) async {
    try {
      final docRef = project.id.isEmpty
          ? _firestore.collection(projectsCollection).doc()
          : _firestore.collection(projectsCollection).doc(project.id);

      final normalizedParticipants = project.participantIds.contains(
        project.creatorId,
      )
          ? project.participantIds
          : [project.creatorId, ...project.participantIds];

      final now = DateTime.now();
      final projectToSave = project.copyWith(
        id: docRef.id,
        participantIds: normalizedParticipants.toSet().toList(),
        createdAt: project.createdAt,
        updatedAt: now,
      );

      await docRef.set(projectToSave.toFirestore());
    } catch (e) {
      debugPrint("🔥 ERROR in createProject: $e");
      throw Exception('プロジェクトの作成に失敗しました: $e');
    }
  }

  Stream<List<ProjectModel>> getOpenProjects() {
    return _firestore
        .collection(projectsCollection)
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) {
      debugPrint("🔥 ERROR in getOpenProjects: $e");
      throw e;
    }).map((snapshot) {
      return snapshot.docs
          .map((doc) => ProjectModel.fromFirestore(doc))
          .toList();
    });
  }

  Stream<ProjectModel?> getProjectStream(String projectId) {
    return _firestore
        .collection(projectsCollection)
        .doc(projectId)
        .snapshots()
        .handleError((e) {
      debugPrint("🔥 ERROR in getProjectStream: $e");
      throw e;
    }).map((doc) => doc.exists ? ProjectModel.fromFirestore(doc) : null);
  }

  Future<void> joinProject(String projectId, String userId) async {
    try {
      final projectRef =
          _firestore.collection(projectsCollection).doc(projectId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(projectRef);
        if (!snapshot.exists) {
          throw Exception('プロジェクトが見つかりません');
        }

        final project = ProjectModel.fromFirestore(snapshot);
        if (project.status != 'open') {
          throw Exception('この募集は終了しています');
        }

        if (project.participantIds.contains(userId)) {
          return;
        }

        final maxParticipants = project.maxParticipants;
        if (maxParticipants != null &&
            project.participantIds.length >= maxParticipants) {
          throw Exception('募集上限人数に達しています');
        }

        transaction.update(projectRef, {
          'participantIds': FieldValue.arrayUnion([userId]),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      debugPrint("🔥 ERROR in joinProject: $e");
      throw Exception('プロジェクトへの参加に失敗しました: $e');
    }
  }

  Future<void> leaveProject(String projectId, String userId) async {
    try {
      await _firestore.collection(projectsCollection).doc(projectId).update({
        'participantIds': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint("🔥 ERROR in leaveProject: $e");
      throw Exception('プロジェクト参加のキャンセルに失敗しました: $e');
    }
  }

  // --- Tag operations ---
  Future<Map<String, dynamic>?> getMemberData(String circleId, String userId) async {
    try {
      final doc = await _firestore
          .collection(circlesCollection)
          .doc(circleId)
          .collection('members')
          .doc(userId)
          .get();
      if (doc.exists) return doc.data() as Map<String, dynamic>;
      return null;
    } catch (e) {
      debugPrint("🔥 ERROR in getMemberData: $e");
      return null;
    }
  }

  Future<void> createTag(TagModel tag) async {
    try {
      final ref = tag.circleId != null
          ? _firestore
              .collection(circlesCollection)
              .doc(tag.circleId)
              .collection(tagsCollection)
              .doc(tag.id)
          : _firestore.collection(tagsCollection).doc(tag.id);
      await ref.set(tag.toFirestore());
    } catch (e) {
      debugPrint("🔥 ERROR in createTag: $e");
      throw Exception('タグの作成に失敗しました: $e');
    }
  }

  Future<void> updateTag(TagModel tag) async {
    try {
      final ref = tag.circleId != null
          ? _firestore
              .collection(circlesCollection)
              .doc(tag.circleId)
              .collection(tagsCollection)
              .doc(tag.id)
          : _firestore.collection(tagsCollection).doc(tag.id);
      await ref.update(tag.toFirestore());
    } catch (e) {
      debugPrint("🔥 ERROR in updateTag: $e");
      throw Exception('タグの更新に失敗しました: $e');
    }
  }

  Future<void> deleteTag(String tagId, {String? circleId}) async {
    try {
      final ref = circleId != null
          ? _firestore
              .collection(circlesCollection)
              .doc(circleId)
              .collection(tagsCollection)
              .doc(tagId)
          : _firestore.collection(tagsCollection).doc(tagId);
      await ref.delete();
    } catch (e) {
      debugPrint("🔥 ERROR in deleteTag: $e");
      throw Exception('タグの削除に失敗しました: $e');
    }
  }

  Stream<List<TagModel>> getGlobalTagsStream({String? type}) {
    Query<Map<String, dynamic>> query = _firestore.collection(tagsCollection);
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    return query.snapshots().handleError((e) {
      debugPrint("🔥 ERROR in getGlobalTagsStream: $e");
      throw e;
    }).map((snapshot) =>
        snapshot.docs.map((doc) => TagModel.fromFirestore(doc)).toList());
  }

  Stream<List<TagModel>> getCircleTagsStream(String circleId, {String? type}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(circlesCollection)
        .doc(circleId)
        .collection(tagsCollection);
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    return query.snapshots().handleError((e) {
      debugPrint("🔥 ERROR in getCircleTagsStream: $e");
      throw e;
    }).map((snapshot) =>
        snapshot.docs.map((doc) => TagModel.fromFirestore(doc)).toList());
  }

  Future<void> updateCircleMemberTags({
    required String circleId,
    required String userId,
    List<String>? roleTags,
    List<String>? skillTags,
    String? displayRole,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      if (roleTags != null) updates['roleTags'] = roleTags;
      if (skillTags != null) updates['skillTags'] = skillTags;
      if (displayRole != null) updates['displayRole'] = displayRole;
      await _firestore
          .collection(circlesCollection)
          .doc(circleId)
          .collection('members')
          .doc(userId)
          .update(updates);
    } catch (e) {
      debugPrint("🔥 ERROR in updateCircleMemberTags: $e");
      throw Exception('メンバータグの更新に失敗しました: $e');
    }
  }

  // --- Recruitment operations ---
  Future<void> createRecruitment(RecruitmentModel recruitment) async {
    try {
      final docRef = _firestore.collection(recruitmentsCollection).doc();
      final toSave = recruitment.copyWith(id: docRef.id);
      await docRef.set(toSave.toFirestore());
    } catch (e) {
      debugPrint("🔥 ERROR in createRecruitment: $e");
      throw Exception('募集の作成に失敗しました: $e');
    }
  }

  Future<void> updateRecruitment(RecruitmentModel recruitment) async {
    try {
      await _firestore
          .collection(recruitmentsCollection)
          .doc(recruitment.id)
          .update(recruitment.toFirestore());
    } catch (e) {
      debugPrint("🔥 ERROR in updateRecruitment: $e");
      throw Exception('募集の更新に失敗しました: $e');
    }
  }

  Future<void> closeRecruitment(String recruitmentId) async {
    try {
      await _firestore.collection(recruitmentsCollection).doc(recruitmentId).update({
        'status': 'closed',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint("🔥 ERROR in closeRecruitment: $e");
      throw Exception('募集の終了に失敗しました: $e');
    }
  }

  Future<RecruitmentModel?> getRecruitment(String recruitmentId) async {
    try {
      final doc = await _firestore
          .collection(recruitmentsCollection)
          .doc(recruitmentId)
          .get();
      if (doc.exists) {
        return RecruitmentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint("🔥 ERROR in getRecruitment: $e");
      throw Exception('募集の取得に失敗しました: $e');
    }
  }

  Stream<RecruitmentModel?> getRecruitmentStream(String recruitmentId) {
    return _firestore
        .collection(recruitmentsCollection)
        .doc(recruitmentId)
        .snapshots()
        .map((doc) => doc.exists ? RecruitmentModel.fromFirestore(doc) : null)
        .handleError((e) {
      debugPrint("🔥 ERROR in getRecruitmentStream: $e");
      throw e;
    });
  }

  Stream<List<RecruitmentModel>> getOpenRecruitmentsStream() {
    return _firestore
        .collection(recruitmentsCollection)
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) {
      debugPrint("🔥 ERROR in getOpenRecruitmentsStream: $e");
      throw e;
    }).map((snapshot) => snapshot.docs
        .map((doc) => RecruitmentModel.fromFirestore(doc))
        .toList());
  }

  Stream<List<RecruitmentModel>> getRecruitmentsForCircle(String circleId) {
    return _firestore
        .collection(recruitmentsCollection)
        .where('circleId', isEqualTo: circleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) {
      debugPrint("🔥 ERROR in getRecruitmentsForCircle: $e");
      throw e;
    }).map((snapshot) => snapshot.docs
        .map((doc) => RecruitmentModel.fromFirestore(doc))
        .toList());
  }

  Future<List<RecruitmentModel>> getOpenRecruitmentsForCircle(
      String circleId) async {
    try {
      final snapshot = await _firestore
          .collection(recruitmentsCollection)
          .where('circleId', isEqualTo: circleId)
          .where('status', isEqualTo: 'open')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => RecruitmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("🔥 ERROR in getOpenRecruitmentsForCircle: $e");
      return [];
    }
  }

  // --- Application operations ---
  Future<String> applyToRecruitment(
      RecruitmentApplicationModel application) async {
    try {
      final docRef = _firestore
          .collection(recruitmentsCollection)
          .doc(application.recruitmentId)
          .collection(applicationsCollection)
          .doc();
      final toSave = application.copyWith(id: docRef.id);
      await docRef.set(toSave.toFirestore());

      await _firestore
          .collection(recruitmentsCollection)
          .doc(application.recruitmentId)
          .update({
        'applicantCount': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return docRef.id;
    } catch (e) {
      debugPrint("🔥 ERROR in applyToRecruitment: $e");
      throw Exception('応募に失敗しました: $e');
    }
  }

  Stream<List<RecruitmentApplicationModel>> getApplicationsForRecruitment(
      String recruitmentId) {
    return _firestore
        .collection(recruitmentsCollection)
        .doc(recruitmentId)
        .collection(applicationsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) {
      debugPrint("🔥 ERROR in getApplicationsForRecruitment: $e");
      throw e;
    }).map((snapshot) => snapshot.docs
        .map((doc) => RecruitmentApplicationModel.fromFirestore(doc))
        .toList());
  }

  Stream<List<RecruitmentApplicationModel>> getApplicationsForCircle(
      String circleId) {
    return _firestore
        .collectionGroup(applicationsCollection)
        .where('circleId', isEqualTo: circleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) {
      debugPrint("🔥 ERROR in getApplicationsForCircle: $e");
      throw e;
    }).map((snapshot) => snapshot.docs
        .map((doc) => RecruitmentApplicationModel.fromFirestore(doc))
        .toList());
  }

  Future<void> updateRecruitmentApplicationStatus({
    required String recruitmentId,
    required String applicationId,
    required String status,
  }) async {
    try {
      await _firestore
          .collection(recruitmentsCollection)
          .doc(recruitmentId)
          .collection(applicationsCollection)
          .doc(applicationId)
          .update({
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint("🔥 ERROR in updateRecruitmentApplicationStatus: $e");
      throw Exception('応募ステータスの更新に失敗しました: $e');
    }
  }

  // TODO_SECURITY: enforce this in Firestore Security Rules.
  Future<void> acceptRecruitmentApplicationAndAddMember({
    required String recruitmentId,
    required String applicationId,
    List<String> roleTags = const [],
    List<String> skillTags = const [],
    String? displayRole,
  }) async {
    try {
      final appDoc = await _firestore
          .collection(recruitmentsCollection)
          .doc(recruitmentId)
          .collection(applicationsCollection)
          .doc(applicationId)
          .get();
      if (!appDoc.exists) {
        throw Exception('応募が見つかりません');
      }

      final application = RecruitmentApplicationModel.fromFirestore(appDoc);

      final batch = _firestore.batch();

      final appRef = _firestore
          .collection(recruitmentsCollection)
          .doc(recruitmentId)
          .collection(applicationsCollection)
          .doc(applicationId);
      batch.update(appRef, {
        'status': 'accepted',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      final memberRef = _firestore
          .collection(circlesCollection)
          .doc(application.circleId)
          .collection('members')
          .doc(application.applicantUserId);
      final existingMember = await memberRef.get();
      if (!existingMember.exists) {
        final now = DateTime.now();
        final memberData = MemberModel(
          id: application.applicantUserId,
          userId: application.applicantUserId,
          role: 'member',
          joinedAt: now,
          roleTags: roleTags,
          skillTags: skillTags,
          displayRole: displayRole,
          updatedAt: now,
        );
        batch.set(memberRef, memberData.toFirestore());
      } else {
        batch.update(memberRef, {
          'roleTags': roleTags,
          'skillTags': skillTags,
          'displayRole': displayRole,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint("🔥 ERROR in acceptRecruitmentApplicationAndAddMember: $e");
      throw Exception('メンバー追加に失敗しました: $e');
    }
  }

  // --- Unified DM / member-add helpers ---
  Future<String> startCircleDm({
    required String individualId,
    required String circleId,
    required String individualName,
    required String circleName,
    String? individualAvatarUrl,
    String? circleAvatarUrl,
  }) async {
    return getOrCreateDmChannel(
      individualId: individualId,
      circleId: circleId,
      individualName: individualName,
      circleName: circleName,
      circleAvatarUrl: circleAvatarUrl,
      individualAvatarUrl: individualAvatarUrl,
    );
  }

  Future<bool> isCircleMember(String circleId, String userId) async {
    try {
      final doc = await _firestore
          .collection(circlesCollection)
          .doc(circleId)
          .collection('members')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint("🔥 ERROR in isCircleMember: $e");
      return false;
    }
  }

  Future<bool> isCircleAdmin(String circleId, String userId) async {
    try {
      final doc = await _firestore
          .collection(circlesCollection)
          .doc(circleId)
          .collection('members')
          .doc(userId)
          .get();
      if (!doc.exists) return false;
      final data = doc.data() as Map<String, dynamic>;
      return data['role'] == 'admin';
    } catch (e) {
      debugPrint("🔥 ERROR in isCircleAdmin: $e");
      return false;
    }
  }

  Future<void> addIndividualToCircleFromDm({
    required String dmChannelId,
    String role = 'member',
    List<String> roleTags = const [],
    List<String> skillTags = const [],
    String? displayRole,
  }) async {
    try {
      final channel = await getDmChannel(dmChannelId);
      if (channel == null) throw Exception('DMチャンネルが見つかりません');

      final memberRef = _firestore
          .collection(circlesCollection)
          .doc(channel.circleId)
          .collection('members')
          .doc(channel.individualId);

      final existing = await memberRef.get();
      final now = DateTime.now();

      if (!existing.exists) {
        final member = MemberModel(
          id: channel.individualId,
          userId: channel.individualId,
          role: role,
          joinedAt: now,
          roleTags: roleTags,
          skillTags: skillTags,
          displayRole: displayRole,
          updatedAt: now,
        );
        await memberRef.set(member.toFirestore());
      } else {
        await memberRef.update({
          'roleTags': roleTags,
          'skillTags': skillTags,
          'displayRole': displayRole,
          'updatedAt': Timestamp.fromDate(now),
        });
      }
    } catch (e) {
      debugPrint("🔥 ERROR in addIndividualToCircleFromDm: $e");
      throw Exception('メンバー追加に失敗しました: $e');
    }
  }

  // --- Joint event operations ---
  Future<void> inviteCircleToEvent({
    required String eventId,
    required String invitedCircleId,
  }) async {
    try {
      await _firestore.collection(eventsCollection).doc(eventId).update({
        'invitedCircleIds': FieldValue.arrayUnion([invitedCircleId]),
        'collaborationStatus': 'invited',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint("🔥 ERROR in inviteCircleToEvent: $e");
      throw Exception('共同主催の招待に失敗しました: $e');
    }
  }

  Future<void> respondToJointEventInvitation({
    required String eventId,
    required String circleId,
    required bool accepted,
  }) async {
    try {
      final batch = _firestore.batch();
      final eventRef = _firestore.collection(eventsCollection).doc(eventId);

      if (accepted) {
        batch.update(eventRef, {
          'organizerCircleIds': FieldValue.arrayUnion([circleId]),
          'invitedCircleIds': FieldValue.arrayRemove([circleId]),
          'circlePermissions.$circleId': 'viewer',
          'collaborationStatus': 'confirmed',
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        batch.update(eventRef, {
          'invitedCircleIds': FieldValue.arrayRemove([circleId]),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint("🔥 ERROR in respondToJointEventInvitation: $e");
      throw Exception('共同主催返答に失敗しました: $e');
    }
  }

  // Note: joint events for a circle can be fetched by checking organizerCircleIds
  Stream<List<EventModel>> getJointEventsForCircle(String circleId) {
    return _firestore
        .collection(eventsCollection)
        .where('organizerCircleIds', arrayContains: circleId)
        .orderBy('startTime', descending: false)
        .snapshots()
        .handleError((e) {
      debugPrint("🔥 ERROR in getJointEventsForCircle: $e");
      throw e;
    }).map((snapshot) =>
        snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  // --- Enhanced project operations ---
  Stream<List<ProjectModel>> getProjectsForCircle(String circleId) {
    return _firestore
        .collection(projectsCollection)
        .where('circleId', isEqualTo: circleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) {
      debugPrint("🔥 ERROR in getProjectsForCircle: $e");
      throw e;
    }).map((snapshot) =>
        snapshot.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList());
  }

  Stream<List<ProjectModel>> getVisibleProjectsForUser(String userId) {
    return _firestore
        .collection(projectsCollection)
        .where('visibility', isEqualTo: 'public')
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) {
      debugPrint("🔥 ERROR in getVisibleProjectsForUser: $e");
      throw e;
    }).map((snapshot) =>
        snapshot.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList());
  }

  Future<void> applyToProject(String projectId, String userId) async {
    try {
      await _firestore.collection(projectsCollection).doc(projectId).update({
        'applicantIds': FieldValue.arrayUnion([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint("🔥 ERROR in applyToProject: $e");
      throw Exception('応募に失敗しました: $e');
    }
  }

  Future<void> approveProjectApplicant(String projectId, String userId) async {
    try {
      await _firestore.collection(projectsCollection).doc(projectId).update({
        'applicantIds': FieldValue.arrayRemove([userId]),
        'participantIds': FieldValue.arrayUnion([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint("🔥 ERROR in approveProjectApplicant: $e");
      throw Exception('参加承認に失敗しました: $e');
    }
  }

  Future<void> rejectProjectApplicant(String projectId, String userId) async {
    try {
      await _firestore.collection(projectsCollection).doc(projectId).update({
        'applicantIds': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint("🔥 ERROR in rejectProjectApplicant: $e");
      throw Exception('却下に失敗しました: $e');
    }
  }

  // --- Enhanced attendance operations ---
  Future<void> createOrUpdateAttendance(AttendanceModel attendance) async {
    try {
      await _firestore
          .collection(eventsCollection)
          .doc(attendance.eventId)
          .collection(attendancesCollection)
          .doc(attendance.userId)
          .set(attendance.toFirestore());
    } catch (e) {
      debugPrint("🔥 ERROR in createOrUpdateAttendance: $e");
      throw Exception('出席情報の保存に失敗しました: $e');
    }
  }

  Future<void> updateRsvpStatus({
    required String eventId,
    required String userId,
    required AttendanceStatus status,
    required String userName,
    String? userProfileImageUrl,
  }) async {
    try {
      final now = DateTime.now();
      final ref = _firestore
          .collection(eventsCollection)
          .doc(eventId)
          .collection(attendancesCollection)
          .doc(userId);
      final existing = await ref.get();
      if (existing.exists) {
        await ref.update({
          'status': status.name,
          'userName': userName,
          'userProfileImageUrl': userProfileImageUrl,
          'updatedAt': Timestamp.fromDate(now),
        });
      } else {
        final attendance = AttendanceModel(
          id: userId,
          eventId: eventId,
          userId: userId,
          userName: userName,
          userProfileImageUrl: userProfileImageUrl,
          status: status,
          createdAt: now,
          updatedAt: now,
        );
        await ref.set(attendance.toFirestore());
      }
    } catch (e) {
      debugPrint("🔥 ERROR in updateRsvpStatus: $e");
      throw Exception('出欠ステータスの更新に失敗しました: $e');
    }
  }

  Future<void> markAttendance({
    required String eventId,
    required String userId,
    required String scanData,
    String method = 'manual',
    String? checkedInBy,
  }) async {
    try {
      final now = DateTime.now();
      final ref = _firestore
          .collection(eventsCollection)
          .doc(eventId)
          .collection(attendancesCollection)
          .doc(userId);

      final existing = await ref.get();
      if (existing.exists) {
        await ref.update({
          'status': 'attending',
          'checkedInAt': Timestamp.fromDate(now),
          'checkInMethod': method,
          'checkedInBy': checkedInBy,
          'qrTokenHash': scanData.isNotEmpty ? scanData : null,
          'updatedAt': Timestamp.fromDate(now),
        });
      } else {
        final attendance = AttendanceModel(
          id: userId,
          eventId: eventId,
          userId: userId,
          userName: userId,
          status: AttendanceStatus.attending,
          checkedInAt: now,
          createdAt: now,
          checkInMethod: method,
          checkedInBy: checkedInBy,
          qrTokenHash: scanData.isNotEmpty ? scanData : null,
          updatedAt: now,
        );
        await ref.set(attendance.toFirestore());
      }
    } catch (e) {
      debugPrint("🔥 ERROR in markAttendance: $e");
      throw Exception('出席確認に失敗しました: $e');
    }
  }

  Stream<List<AttendanceModel>> getAttendancesForEvent(String eventId) {
    return _firestore
        .collection(eventsCollection)
        .doc(eventId)
        .collection(attendancesCollection)
        .snapshots()
        .handleError((e) {
      debugPrint("🔥 ERROR in getAttendancesForEvent: $e");
      throw e;
    }).map((snapshot) => snapshot.docs
        .map((doc) => AttendanceModel.fromFirestore(doc))
        .toList());
  }

  Stream<List<AttendanceModel>> getAttendancesForUser(String userId) {
    return _firestore
        .collectionGroup(attendancesCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .handleError((e) {
      debugPrint("🔥 ERROR in getAttendancesForUser: $e");
      throw e;
    }).map((snapshot) => snapshot.docs
        .map((doc) => AttendanceModel.fromFirestore(doc))
        .toList());
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
