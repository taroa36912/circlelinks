import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/app_menu_drawer.dart';

class BoardScreen extends ConsumerStatefulWidget {
  const BoardScreen({super.key});

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen> {
  BoardThreadModel? _selectedThread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(firebaseAuthServiceProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('掲示板'),
      ),
      drawer: const AppMenuDrawer(),
      body: currentUser == null
          ? const Center(child: Text('ログインが必要です。'))
          : _selectedThread == null
              ? _buildThreadList(theme)
              : _buildThreadDetail(theme, currentUser.uid, _selectedThread!),
      floatingActionButton: currentUser == null || _selectedThread != null
          ? null
          : FloatingActionButton(
              onPressed: () => _showThreadSheet(currentUser.uid),
              tooltip: 'スレッド作成',
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildThreadList(ThemeData theme) {
    final firestoreService = ref.read(firestoreServiceProvider);

    return StreamBuilder<List<BoardThreadModel>>(
      stream: firestoreService.getBoardThreadsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('エラー: ${snapshot.error}'));
        }

        final threads = snapshot.data ?? [];
        if (threads.isEmpty) {
          return Center(
            child: Text(
              'まだスレッドはありません',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 10.h),
          itemCount: threads.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant,
          ),
          itemBuilder: (context, index) {
            final thread = threads[index];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedThread = thread;
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    _StyledBoardText(
                      text: thread.body,
                      baseStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            thread.authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${thread.commentCount}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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

  Widget _buildThreadDetail(
      ThemeData theme, String userId, BoardThreadModel thread) {
    final firestoreService = ref.read(firestoreServiceProvider);

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<BoardCommentModel>>(
            stream: firestoreService.getBoardCommentsStream(thread.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('エラー: ${snapshot.error}'));
              }

              final comments = snapshot.data ?? [];
              return ListView(
                padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedThread = null;
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('戻る'),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    thread.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  _StyledBoardText(
                    text: thread.body,
                    baseStyle: theme.textTheme.bodyLarge,
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    '個人参加のみ',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Divider(color: theme.colorScheme.outlineVariant),
                  SizedBox(height: 1.h),
                  if (comments.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Center(
                        child: Text(
                          'まだコメントはありません',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ...comments.map((comment) {
                      return _CommentTile(comment: comment);
                    }),
                ],
              );
            },
          ),
        ),
        _CommentComposer(
          onSubmit: (body) => _addComment(
            threadId: thread.id,
            body: body,
            userId: userId,
          ),
        ),
      ],
    );
  }

  Future<void> _showThreadSheet(String userId) async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 4.w,
              right: 4.w,
              bottom: MediaQuery.of(context).viewInsets.bottom + 2.h,
              top: 1.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'スレッド作成',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'タイトル'),
                  maxLength: 60,
                ),
                SizedBox(height: 1.h),
                _StyledBoardComposerField(
                  controller: bodyController,
                  labelText: '本文',
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final body = bodyController.text.trim();
                    if (title.isEmpty || body.isEmpty) return;
                    await _createThread(
                      title: title,
                      body: body,
                      userId: userId,
                    );
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('作成'),
                ),
              ],
            ),
          ),
        );
      },
    );

    titleController.dispose();
    bodyController.dispose();
  }

  Future<String> _currentUserName(String userId) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final authService = ref.read(firebaseAuthServiceProvider);
    try {
      final userData = await firestoreService.getUser(userId);
      return userData?.userName ??
          authService.currentUser?.email ??
          '名無しユーザー';
    } catch (_) {
      return authService.currentUser?.email ?? '名無しユーザー';
    }
  }

  Future<void> _createThread({
    required String title,
    required String body,
    required String userId,
  }) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final authorName = await _currentUserName(userId);
    final now = DateTime.now();
    final thread = BoardThreadModel(
      id: '',
      title: title,
      body: body,
      authorId: userId,
      authorName: authorName,
      createdAt: now,
      updatedAt: now,
    );

    await firestoreService.createBoardThread(thread);
  }

  Future<void> _addComment({
    required String threadId,
    required String body,
    required String userId,
  }) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final authorName = await _currentUserName(userId);
    final comment = BoardCommentModel(
      id: '',
      threadId: threadId,
      authorId: userId,
      authorName: authorName,
      body: body,
      createdAt: DateTime.now(),
    );

    await firestoreService.addBoardComment(comment);
  }
}

class _CommentTile extends StatelessWidget {
  final BoardCommentModel comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText =
        DateFormat('yyyy/MM/dd HH:mm:ss').format(comment.createdAt);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_outline,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  comment.authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          _StyledBoardText(
            text: comment.body,
            baseStyle: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 0.8.h),
          Text(
            dateText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Divider(color: theme.colorScheme.outlineVariant),
        ],
      ),
    );
  }
}

class _CommentComposer extends StatefulWidget {
  final Future<void> Function(String body) onSubmit;

  const _CommentComposer({required this.onSubmit});

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StyledBoardComposerField(
              controller: _controller,
              labelText: 'コメント',
              minLines: 1,
              maxLines: 4,
            ),
            SizedBox(height: 1.h),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _isSending ? null : _submit,
                icon: _isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text('投稿'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final body = _controller.text.trim();
    if (body.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      await widget.onSubmit(body);
      _controller.clear();
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }
}

class _StyledBoardComposerField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final int minLines;
  final int maxLines;

  const _StyledBoardComposerField({
    required this.controller,
    required this.labelText,
    this.minLines = 3,
    this.maxLines = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputDecoration(labelText: labelText),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Tooltip(
              message: '大文字',
              child: OutlinedButton(
                onPressed: () =>
                    _wrapSelection(controller, '[upper]', '[/upper]'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(44, 40),
                  padding: EdgeInsets.zero,
                ),
                child: const Text('A'),
              ),
            ),
            _ColorButton(
              color: theme.colorScheme.primary,
              onPressed: () => _wrapSelection(
                controller,
                '[color=#2B5CE6]',
                '[/color]',
              ),
            ),
            _ColorButton(
              color: AppTheme.success,
              onPressed: () => _wrapSelection(
                controller,
                '[color=#059669]',
                '[/color]',
              ),
            ),
            _ColorButton(
              color: AppTheme.error,
              onPressed: () => _wrapSelection(
                controller,
                '[color=#DC2626]',
                '[/color]',
              ),
            ),
          ],
        ),
      ],
    );
  }

  static void _wrapSelection(
    TextEditingController controller,
    String before,
    String after,
  ) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final safeStart = start.clamp(0, text.length).toInt();
    final safeEnd = end.clamp(0, text.length).toInt();
    final selectedText = text.substring(safeStart, safeEnd);
    final replacement = '$before$selectedText$after';
    final nextText = text.replaceRange(safeStart, safeEnd, replacement);

    controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(
        offset: safeStart + before.length + selectedText.length,
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final VoidCallback onPressed;

  const _ColorButton({
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '文字色',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      ),
    );
  }
}

class _StyledBoardText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final int? maxLines;

  const _StyledBoardText({
    required this.text,
    this.baseStyle,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final style = baseStyle ?? Theme.of(context).textTheme.bodyMedium;
    return RichText(
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
      text: TextSpan(
        style: style,
        children: _BoardTextParser.parse(text, style),
      ),
    );
  }
}

class _BoardTextParser {
  static final RegExp _tagPattern = RegExp(
    r'\[(upper|color=#(?:[0-9A-Fa-f]{6}))\](.*?)\[/(upper|color)\]',
    dotAll: true,
  );

  static List<TextSpan> parse(String source, TextStyle? baseStyle) {
    final spans = <TextSpan>[];
    var cursor = 0;

    for (final match in _tagPattern.allMatches(source)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: source.substring(cursor, match.start)));
      }

      final tag = match.group(1) ?? '';
      final content = match.group(2) ?? '';
      final closingTag = match.group(3) ?? '';
      final isValidUpperTag = tag == 'upper' && closingTag == 'upper';
      final isValidColorTag =
          tag.startsWith('color=#') && closingTag == 'color';

      if (isValidUpperTag) {
        spans.add(TextSpan(
          text: content.toUpperCase(),
          style: baseStyle?.copyWith(fontWeight: FontWeight.w700),
        ));
      } else if (isValidColorTag) {
        spans.add(TextSpan(
          text: content,
          style: baseStyle?.copyWith(color: _parseColor(tag.substring(7))),
        ));
      } else {
        spans.add(TextSpan(text: match.group(0)));
      }

      cursor = match.end;
    }

    if (cursor < source.length) {
      spans.add(TextSpan(text: source.substring(cursor)));
    }

    return spans;
  }

  static Color _parseColor(String hex) {
    final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
    if (value == null) return AppTheme.textPrimary;
    return Color(0xFF000000 | value);
  }
}
