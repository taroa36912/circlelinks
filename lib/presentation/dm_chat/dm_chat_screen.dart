import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart'; // app_export.dart (RiverpodとServiceを含む)

class DmChatScreen extends ConsumerStatefulWidget {
  final String dmChannelId;
  final String recipientName; // 相手（サークルまたは個人）の名前

  const DmChatScreen({
    super.key,
    required this.dmChannelId,
    required this.recipientName,
  });

  @override
  ConsumerState<DmChatScreen> createState() => _DmChatScreenState();
}

class _DmChatScreenState extends ConsumerState<DmChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;
  String _currentUserName = '...'; // 自分の表示名

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authService = ref.read(firebaseAuthServiceProvider);
    final user = authService.currentUser;
    if (user != null) {
      // ログインユーザー（個人またはサークル管理者）の情報を取得
      _currentUserId = user.uid;
      
      // 自分のサークル情報を取得試行（自分がサークル側の場合）
      final firestoreService = ref.read(firestoreServiceProvider);
      final myCircle = await firestoreService.getCircle(user.uid);
      
      setState(() {
        // サークル情報があればサークル名、なければメールアドレス（の@前など）を使う
        _currentUserName = myCircle?.circleName ?? user.email?.split('@').first ?? 'ユーザー';
      });
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
          return Center(child: Text('メッセージを送信してDMを開始しましょう。'));
        }
        
        // ... (ListView.builder とスクロール処理 - chat.dart と同様) ...
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
            final isOwnMessage = message.senderId == _currentUserId;
            // (chat.dart の _buildMessageBubble と同様の実装)
            return _buildMessageBubble(message, isOwnMessage);
          },
        );
      },
    );
  }
  
  // (chat.dart から _buildMessageBubble をコピー＆ペーストし、
  //  MessageModel の代わりに DmMessageModel を使うように修正)
  Widget _buildMessageBubble(DmMessageModel message, bool isOwnMessage) {
    // ... (chat.dart の _buildMessageBubble とほぼ同じレイアウト) ...
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
              child: Text(
                message.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isOwnMessage
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    // ... (chat.dart の _buildMessageInput と同様の実装) ...
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

    final message = DmMessageModel(
      id: '', // Firestoreが設定
      senderId: _currentUserId!,
      senderName: _currentUserName, // 自分の表示名
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