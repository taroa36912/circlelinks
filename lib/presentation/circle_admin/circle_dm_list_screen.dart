import 'package:flutter/material.dart';
import '../../core/app_export.dart';
// DateFormat用

class CircleDmListScreen extends ConsumerStatefulWidget {
  final String circleId; // 👈 引数でサークルIDを受け取る

  const CircleDmListScreen({
    super.key,
    required this.circleId,
  });

  @override
  ConsumerState<CircleDmListScreen> createState() => _CircleDmListScreenState();
}

class _CircleDmListScreenState extends ConsumerState<CircleDmListScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('受信したDM一覧'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _buildDmList(theme),
    );
  }

  // サークルが受信したDMの一覧
  Widget _buildDmList(ThemeData theme) {
    final firestoreService = ref.read(firestoreServiceProvider);

    return StreamBuilder<List<DmChannelModel>>(
      // 👈 受け取った widget.circleId を使用
      stream: firestoreService.getDmChannelsForCircle(widget.circleId), 
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
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(
                channel.individualName,
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