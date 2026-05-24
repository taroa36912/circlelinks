import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../core/models/member_model.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/safe_image_helper.dart';

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
                leading: safeCircleAvatar(
                  imageUrl: avatarUrl,
                  fallback: Icon(
                      member.role == 'admin' ? Icons.star : Icons.person),
                ),
                title: Text(displayName),
                subtitle: Text(member.displayRole ?? (member.role == 'admin' ? '管理者' : 'メンバー')),
                trailing: isMe
                    ? const Chip(label: Text('あなた'))
                    : PopupMenuButton<String>(
                        onSelected: (action) => _handleAction(
                            context, action, member.userId, member.role),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit_tags',
                            child: const Text('タグ・役職を編集'),
                          ),
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
      if (action == 'edit_tags') {
        final memberData = await firestoreService.getMemberData(widget.circleId, userId);
        final displayRoleCtrl = TextEditingController(text: memberData?['displayRole'] ?? '');
        final roleTagsCtrl = TextEditingController(text: (memberData?['roleTags'] as List<dynamic>?)?.join(', ') ?? '');
        final skillTagsCtrl = TextEditingController(text: (memberData?['skillTags'] as List<dynamic>?)?.join(', ') ?? '');

        if (!context.mounted) return;
        final result = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('タグ・役職を編集'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: displayRoleCtrl,
                    decoration: const InputDecoration(labelText: '役職名'),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: roleTagsCtrl,
                    decoration: const InputDecoration(labelText: '役割タグ (カンマ区切り)'),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: skillTagsCtrl,
                    decoration: const InputDecoration(labelText: 'スキルタグ (カンマ区切り)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('保存')),
            ],
          ),
        );

        if (result == true) {
          await firestoreService.updateCircleMemberTags(
            circleId: widget.circleId,
            userId: userId,
            displayRole: displayRoleCtrl.text.trim().isNotEmpty ? displayRoleCtrl.text.trim() : null,
            roleTags: roleTagsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
            skillTags: skillTagsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('タグを更新しました')));
          }
        }
      } else if (action == 'toggle_role') {
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
