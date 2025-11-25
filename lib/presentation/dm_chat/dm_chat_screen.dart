import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart'; 

class DmChatScreen extends ConsumerStatefulWidget {
  final String dmChannelId;
  final String recipientName;
  // ⬇️ 追加: サークル管理者として参加しているかどうか
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
      
      // ⬇️ --- 修正: 名前決定ロジック --- ⬇️
      if (widget.isCircleAdmin) {
        // サークル管理者として発言する場合 -> 自分のサークル名を取得
        final firestoreService = ref.read(firestoreServiceProvider);
        final myCircle = await firestoreService.getCircle(user.uid);
        setState(() {
          _currentUserName = myCircle?.circleName ?? 'サークル管理者';
        });
      } else {
        // 個人として発言する場合 -> Authの表示名 or メール
        setState(() {
          _currentUserName = user.displayName ?? user.email?.split('@').first ?? 'ユーザー';
        });
      }
      // ⬆️ --- 修正ここまで --- ⬆️
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientName),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_currentUserId == null) {
      return const Center(child: Text('読み込み中...'));
    }

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
          return const Center(child: Text('メッセージを送信してDMを開始しましょう。'));
        }
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(4.w),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            // 自分が送信したメッセージかどうか
            final isOwnMessage = message.senderId == _currentUserId;
            return _buildMessageBubble(message, isOwnMessage);
          },
        );
      },
    );
  }
  
  Widget _buildMessageBubble(DmMessageModel message, bool isOwnMessage) {
     return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h,),
              decoration: BoxDecoration(
                color: isOwnMessage
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 相手からのメッセージの場合、名前を表示しても良い
                  if (!isOwnMessage) ...[
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 10, 
                        color: Theme.of(context).colorScheme.onSurfaceVariant
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                  Text(
                    message.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isOwnMessage
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2), width: 1,),),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'メッセージを入力...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24),),
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h,),
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

    // ⬇️ メッセージ送信時に _currentUserName (役割に応じた名前) を使用
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('メッセージの送信に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}