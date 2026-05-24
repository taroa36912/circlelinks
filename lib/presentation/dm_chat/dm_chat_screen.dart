import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class DmChatScreen extends ConsumerStatefulWidget {
  final String dmChannelId;
  final String recipientName;
  // サークル管理者として参加しているかどうか
  final bool isCircleAdmin;

  const DmChatScreen({
    super.key,
    required this.dmChannelId,
    required this.recipientName,
    this.isCircleAdmin = false, // デフォルトは個人 (false)
  });

  @override
  ConsumerState<DmChatScreen> createState() => _DmChatScreenState();
}

class _DmChatScreenState extends ConsumerState<DmChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;
  String _currentUserName = '...'; // 送信者名

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authService = ref.read(firebaseAuthServiceProvider);
    final user = authService.currentUser;
    if (user != null) {
      _currentUserId = user.uid;

      if (widget.isCircleAdmin) {
        // サークル管理者として発言する場合 -> 自分のサークル名を取得
        final firestoreService = ref.read(firestoreServiceProvider);
        final myCircle = await firestoreService.getCircle(user.uid);
        if (mounted && myCircle != null) {
          setState(() {
            _currentUserName = myCircle.circleName;
          });
        }
      } else {
        // 個人として発言する場合 -> 自分のユーザー名を取得
        final firestoreService = ref.read(firestoreServiceProvider);
        final myUser = await firestoreService.getUser(user.uid);
        if (mounted && myUser != null) {
          setState(() {
            _currentUserName = myUser.userName;
          });
        }
      }
    }
  }

  Future<void> _showAddMemberDialog() async {
    final firestoreService = ref.read(firestoreServiceProvider);
    
    final channel = await firestoreService.getDmChannel(widget.dmChannelId);
    if (channel == null) return;

    final isAlreadyMember =
        await firestoreService.isCircleMember(channel.circleId, channel.individualId);

    if (!mounted) return;

    final displayRoleController = TextEditingController();
    final roleTagsController = TextEditingController();
    final skillTagsController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isAlreadyMember ? 'メンバー情報を更新' : 'メンバー追加'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isAlreadyMember
                  ? '${channel.individualName}さんは既に「${channel.circleName}」のメンバーです。タグ・役職を更新しますか？'
                  : '${channel.individualName}さんを「${channel.circleName}」のメンバーとして追加しますか？'),
              SizedBox(height: 2.h),
              TextField(
                controller: displayRoleController,
                decoration: const InputDecoration(labelText: '役職名', hintText: '例: 会計, 広報'),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: roleTagsController,
                decoration: const InputDecoration(labelText: '役割タグ', hintText: 'カンマ区切り'),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: skillTagsController,
                decoration: const InputDecoration(labelText: 'スキルタグ', hintText: 'カンマ区切り'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); 
              try {
                await firestoreService.addIndividualToCircleFromDm(
                  dmChannelId: widget.dmChannelId,
                  role: 'member',
                  displayRole: displayRoleController.text.trim().isNotEmpty
                      ? displayRoleController.text.trim()
                      : null,
                  roleTags: roleTagsController.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList(),
                  skillTags: skillTagsController.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isAlreadyMember ? 'メンバー情報を更新しました' : 'メンバーを追加しました！')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('操作に失敗しました: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text(isAlreadyMember ? '更新する' : '追加する'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientName),
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        // ⬇️ 新規追加: サークル管理者の場合のみ追加ボタンを表示
        actions: [
          if (widget.isCircleAdmin)
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'サークルに追加',
              onPressed: _showAddMemberDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final firestoreService = ref.read(firestoreServiceProvider);

    return StreamBuilder<List<DmMessageModel>>(
      stream: firestoreService.getDmMessagesStream(widget.dmChannelId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('エラー: ${snapshot.error}'));
        }

        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return const Center(child: Text('メッセージがありません。'));
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.senderId == _currentUserId;

            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isMe
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.message,
                      style: TextStyle(
                        color: isMe
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 4.w,
        right: 4.w,
        top: 2.h,
        bottom: MediaQuery.of(context).padding.bottom + 2.h,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'メッセージを入力...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
              maxLines: null,
            ),
          ),
          SizedBox(width: 2.w),
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _currentUserId == null) return;

    final firestoreService = ref.read(firestoreServiceProvider);

    final message = DmMessageModel(
      id: '',
      senderId: _currentUserId!,
      senderName: _currentUserName,
      message: messageText,
      timestamp: DateTime.now(),
    );

    try {
      await firestoreService.sendDmMessage(
        channelId: widget.dmChannelId,
        message: message,
      );
      _messageController.clear();
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100, // 送信時に少し余分にスクロール
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('メッセージの送信に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}