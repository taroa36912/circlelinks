import 'package:flutter/material.dart';
// DateFormat用
import '../../core/app_export.dart';

// ⬇️ クラス名を DmListScreen に修正 ⬇️
class DmListScreen extends ConsumerStatefulWidget {
  const DmListScreen({super.key});

  @override
  ConsumerState<DmListScreen> createState() => _DmListScreenState();
}

class _DmListScreenState extends ConsumerState<DmListScreen> {
  String? _currentUserId;
  
  @override
  void initState() {
    super.initState();
    _currentUserId = ref.read(firebaseAuthServiceProvider).currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('DM一覧')),
        body: const Center(child: Text('ログインが必要です。')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DM一覧',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _buildDmList(theme),
    );
  }

  // 自分が個人として送受信したDMの一覧
  Widget _buildDmList(ThemeData theme) {
    final firestoreService = ref.read(firestoreServiceProvider);

    return StreamBuilder<List<DmChannelModel>>(
      // ⬇️ 個人用のメソッド (getDmChannelsForIndividual) を使用 ⬇️
      stream: firestoreService.getDmChannelsForIndividual(_currentUserId!), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('エラー: ${snapshot.error}')); 
        }
        final channels = snapshot.data ?? [];

        if (channels.isEmpty) {
          return Center(
            child: Text(
              'まだDMはありません',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: channels.length,
          itemBuilder: (context, index) {
            final channel = channels[index];
            return ListTile(
              leading: CircleAvatar(
                // サークルのアバター
                backgroundImage: (channel.circleAvatarUrl != null)
                  ? NetworkImage(channel.circleAvatarUrl!)
                  : null,
                child: (channel.circleAvatarUrl == null) 
                  ? const Icon(Icons.group) 
                  : null,
              ),
              title: Text(
                channel.circleName, // DM相手（サークル）の名前
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                channel.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                DateFormat('MM/dd').format(channel.lastMessageTimestamp),
                style: theme.textTheme.bodySmall,
              ),
              onTap: () {
                // DMチャット画面に遷移
                Navigator.pushNamed(
                  context,
                  AppRoutes.dmChat,
                  arguments: {
                    'dmChannelId': channel.id,
                    'recipientName': channel.circleName, // 相手（サークル）の名前
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}