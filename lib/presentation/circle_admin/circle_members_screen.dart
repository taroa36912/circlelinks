import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_export.dart';
import '../../core/models/member_model.dart'; // 👈 追加: MemberModel のインポート
import '../../core/models/user_model.dart';   // 👈 追加: UserModel のインポート

class CircleMembersScreen extends ConsumerWidget {
  final String circleId;

  const CircleMembersScreen({super.key, required this.circleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('メンバー管理'),
      ),
      body: StreamBuilder<List<MemberModel>>(
        stream: firestoreService.getCircleMembersStream(circleId),
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

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              
              // ⬇️ 修正: FutureBuilder の中身を詳細な状態判定に変更
              return FutureBuilder<UserModel?>(
                future: firestoreService.getUser(member.userId),
                builder: (context, userSnapshot) {
                  String userName = '読み込み中...';
                  String? avatarUrl;

                  // 通信が完了しているかどうかの判定
                  if (userSnapshot.connectionState == ConnectionState.done) {
                    if (userSnapshot.hasError) {
                      userName = 'エラー';
                    } else if (userSnapshot.data == null) {
                      // 🔥 usersコレクションにデータが存在しない場合
                      userName = '不明なユーザー (データ未登録)';
                    } else {
                      // 正常に取得できた場合
                      userName = userSnapshot.data!.userName;
                      avatarUrl = userSnapshot.data!.profileImageUrl;
                    }
                  }

                  final isMe = member.userId == ref.read(firebaseAuthServiceProvider).currentUser?.uid;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null 
                          ? Icon(member.role == 'admin' ? Icons.star : Icons.person) 
                          : null,
                    ),
                    title: Text(userName),
                    subtitle: Text(member.role == 'admin' ? '管理者' : 'メンバー'),
                    trailing: isMe ? const Chip(label: Text('あなた')) : PopupMenuButton<String>(
                      onSelected: (action) => _handleAction(context, ref, action, member.userId, member.role),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle_role',
                          child: Text(member.role == 'admin' ? '一般メンバーへ降格' : '管理者へ昇格'),
                        ),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Text('追放する', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String action, String userId, String currentRole) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    
    try {
      if (action == 'toggle_role') {
        final newRole = currentRole == 'admin' ? 'member' : 'admin';
        await firestoreService.updateCircleMemberRole(circleId, userId, newRole); 
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('権限を更新しました')));
        }
      } else if (action == 'remove') {
        await firestoreService.removeCircleMember(circleId, userId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('メンバーを追放しました')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
      }
    }
  }
}