import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart'; // app_export.dart (RiverpodとServiceを含む)

class CircleAdminScreen extends ConsumerStatefulWidget {
  const CircleAdminScreen({super.key});

  @override
  ConsumerState<CircleAdminScreen> createState() => _CircleAdminScreenState();
}

class _CircleAdminScreenState extends ConsumerState<CircleAdminScreen> {
  String? _currentCircleId;
  
  @override
  void initState() {
    super.initState();
    _currentCircleId = ref.read(firebaseAuthServiceProvider).currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_currentCircleId == null) {
      // ログインしていないか、サークルID（Auth UID）が取得できない
      return Scaffold(
        appBar: AppBar(title: const Text('サークル管理')),
        body: const Center(child: Text('管理者情報が見つかりません。')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'サークル管理',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        // TODO: ここにタブ（DM, イベント管理, メンバー管理など）を追加できる
      ),
      body: _buildDmList(theme),
    );
  }

  // サークルが受信したDMの一覧
  Widget _buildDmList(ThemeData theme) {
    final firestoreService = ref.read(firestoreServiceProvider);

    return StreamBuilder<List<DmChannelModel>>(
      stream: firestoreService.getDmChannelsForCircle(_currentCircleId!),
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
                // TODO: 個人のアバター (channel.individualAvatarUrl)
                child: Icon(Icons.person),
              ),
              title: Text(
                channel.individualName, // DM相手（個人）の名前
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
                    'recipientName': channel.individualName,
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