import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/models/member_model.dart';
import '../../core/models/user_model.dart';

class CircleMembersScreen extends ConsumerStatefulWidget {
  final String circleId;

  const CircleMembersScreen({super.key, required this.circleId});

  @override
  ConsumerState<CircleMembersScreen> createState() =>
      _CircleMembersScreenState();
}

class _CircleMembersScreenState extends ConsumerState<CircleMembersScreen> {
  // 取得済みユーザーデータを格納するキャッシュ (userId → UserModel? / null=ドキュメント未存在)
  final Map<String, UserModel?> _resolvedUsers = {};
  // 現在取得中の userId セット (重複リクエスト防止)
  final Set<String> _fetchingUsers = {};

  /// userId に対応するユーザーデータをまだ取得していなければ非同期で取得し、
  /// 完了次第 setState して画面を更新する。
  /// FutureBuilder を使わずに State で管理することで、StreamBuilder が
  /// リビルドされても「読み込み中...」に戻らないようにする。
  void _ensureUserLoaded(String userId) {
    // 取得済み or 取得中ならスキップ
    if (_resolvedUsers.containsKey(userId) || _fetchingUsers.contains(userId)) {
      return;
    }
    _fetchingUsers.add(userId);

    ref
        .read(firestoreServiceProvider)
        .getUser(userId)
        .then((user) {
          if (mounted) {
            setState(() {
              _resolvedUsers[userId] = user;
              _fetchingUsers.remove(userId);
            });
          } else {
            _fetchingUsers.remove(userId);
          }
        })
        .catchError((e) {
          // エラー時は null として扱い「不明なユーザー」を表示
          if (mounted) {
            setState(() {
              _resolvedUsers[userId] = null;
              _fetchingUsers.remove(userId);
            });
          } else {
            _fetchingUsers.remove(userId);
          }
        });
  }

  /// 取得済みデータから表示名を解決する
  String _resolveDisplayName(String userId) {
    if (!_resolvedUsers.containsKey(userId)) {
      return '読み込み中...';
    }
    final user = _resolvedUsers[userId];
    if (user == null) {
      return '不明なユーザー';
    }
    // userName が null 相当 (Firestore 未設定 → '名無しユーザー') または空の場合は
    // メールアドレスにフォールバック
    final hasValidName =
        user.userName.isNotEmpty && user.userName != '名無しユーザー';
    return hasValidName
        ? user.userName
        : (user.email.isNotEmpty ? user.email : '不明なユーザー');
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('メンバー管理'),
      ),
      body: StreamBuilder<List<MemberModel>>(
        stream: firestoreService.getCircleMembersStream(widget.circleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }

          final members = snapshot.data ?? [];
          if (members.isEmpty) {
            return const Center(child: Text('メンバーがいません'));
          }

          // StreamBuilder がリビルドされるたびに未取得ユーザーの取得を開始する
          for (final member in members) {
            _ensureUserLoaded(member.userId);
          }

          final currentUid =
              ref.read(firebaseAuthServiceProvider).currentUser?.uid;

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final displayName = _resolveDisplayName(member.userId);
              final avatarUrl = _resolvedUsers[member.userId]?.profileImageUrl;
              final isMe = member.userId == currentUid;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Icon(
                          member.role == 'admin' ? Icons.star : Icons.person)
                      : null,
                ),
                title: Text(displayName),
                subtitle: Text(member.role == 'admin' ? '管理者' : 'メンバー'),
                trailing: isMe
                    ? const Chip(label: Text('あなた'))
                    : PopupMenuButton<String>(
                        onSelected: (action) => _handleAction(
                            context, action, member.userId, member.role),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'toggle_role',
                            child: Text(member.role == 'admin'
                                ? '一般メンバーへ降格'
                                : '管理者へ昇格'),
                          ),
                          const PopupMenuItem(
                            value: 'remove',
                            child: Text('追放する',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, String action, String userId,
      String currentRole) async {
    final firestoreService = ref.read(firestoreServiceProvider);

    try {
      if (action == 'toggle_role') {
        final newRole = currentRole == 'admin' ? 'member' : 'admin';
        // ロール変更後はキャッシュを削除して次回再取得させる
        _resolvedUsers.remove(userId);
        await firestoreService.updateCircleMemberRole(
            widget.circleId, userId, newRole);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('権限を更新しました')));
        }
      } else if (action == 'remove') {
        _resolvedUsers.remove(userId);
        await firestoreService.removeCircleMember(widget.circleId, userId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('メンバーを追放しました')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('エラー: $e')));
      }
    }
  }
}
