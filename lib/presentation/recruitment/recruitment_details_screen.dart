import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class RecruitmentDetailsScreen extends ConsumerStatefulWidget {
  final String recruitmentId;

  const RecruitmentDetailsScreen({super.key, required this.recruitmentId});

  @override
  ConsumerState<RecruitmentDetailsScreen> createState() =>
      _RecruitmentDetailsScreenState();
}

class _RecruitmentDetailsScreenState
    extends ConsumerState<RecruitmentDetailsScreen> {
  bool _isLoading = false;

  Future<void> _apply(RecruitmentModel recruitment) async {
    final authService = ref.read(firebaseAuthServiceProvider);
    final user = authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログインが必要です')),
      );
      return;
    }

    final messageController = TextEditingController();
    final tagsController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('応募する'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                    labelText: 'メッセージ', hintText: '自己紹介・意気込みなど'),
                maxLines: 3,
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                    labelText: '自分のタグ', hintText: 'カンマ区切り 例: Flutter,デザイン'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('キャンセル')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('応募する')),
        ],
      ),
    );

    if (result != true) return;

    setState(() => _isLoading = true);
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final userModel = await firestoreService.getUser(user.uid);
      final now = DateTime.now();

      final application = RecruitmentApplicationModel(
        id: '',
        recruitmentId: recruitment.id,
        circleId: recruitment.circleId,
        applicantUserId: user.uid,
        applicantName: userModel?.userName ?? user.displayName ?? user.email ?? '',
        applicantEmail: user.email ?? '',
        applicantProfileImageUrl: user.photoURL,
        message: messageController.text.trim(),
        applicantTags: tagsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        status: 'pending',
        createdAt: now,
        updatedAt: now,
      );

      await firestoreService.applyToRecruitment(application);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('応募しました！'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('応募に失敗しました: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startDm(RecruitmentModel recruitment) async {
    final authService = ref.read(firebaseAuthServiceProvider);
    final user = authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログインが必要です')),
      );
      return;
    }

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final channelId = await firestoreService.startCircleDm(
        individualId: user.uid,
        circleId: recruitment.circleId,
        individualName: user.displayName ?? user.email ?? 'ユーザー',
        circleName: recruitment.circleName,
        individualAvatarUrl: user.photoURL,
      );

      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.dmChat, arguments: {
          'dmChannelId': channelId,
          'recipientName': recruitment.circleName,
          'isCircleAdmin': false,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('DMの開始に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<RecruitmentModel?>(
      stream: firestoreService.getRecruitmentStream(widget.recruitmentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final recruitment = snapshot.data;
        if (recruitment == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('募集詳細')),
            body: const Center(child: Text('募集が見つかりません')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('募集詳細'),
            backgroundColor: colorScheme.surface,
            elevation: 0,
          ),
          body: ListView(
            padding: EdgeInsets.all(4.w),
            children: [
              Text(recruitment.title,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: 2.h),
              Text('${recruitment.circleName}  (${recruitment.universityName})',
                  style: theme.textTheme.bodyLarge),
              SizedBox(height: 2.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('活動内容',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 1.h),
                      Text(recruitment.description),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              if (recruitment.welcomeTags.isNotEmpty)
                _buildTagRow('歓迎タグ', recruitment.welcomeTags, colorScheme),
              if (recruitment.requiredTags.isNotEmpty)
                _buildTagRow('必須タグ', recruitment.requiredTags, colorScheme,
                    isRequired: true),
              if (recruitment.activityDaysText.isNotEmpty)
                _buildInfoRow('活動日', recruitment.activityDaysText, theme),
              if (recruitment.feeText.isNotEmpty)
                _buildInfoRow('費用', recruitment.feeText, theme),
              if (recruitment.deadline != null)
                _buildInfoRow(
                  '締切',
                  DateFormat('yyyy/MM/dd').format(recruitment.deadline!),
                  theme,
                ),
              if (recruitment.capacity != null)
                _buildInfoRow('定員', '${recruitment.capacity}名', theme),
              _buildInfoRow(
                '応募方法',
                recruitment.applicationMethod == 'dm'
                    ? 'DMで問い合わせ'
                    : recruitment.applicationMethod == 'form'
                        ? 'フォーム応募'
                        : 'イベント経由',
                theme,
              ),
              SizedBox(height: 3.h),
              if (recruitment.applicationMethod == 'dm')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _startDm(recruitment),
                    icon: const Icon(Icons.message),
                    label: const Text('DMで問い合わせる'),
                  ),
                ),
              if (recruitment.applicationMethod == 'form')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _apply(recruitment),
                    icon: const Icon(Icons.send),
                    label: const Text('応募する'),
                  ),
                ),
              if (recruitment.applicationMethod == 'event' &&
                  recruitment.relatedEventId != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.eventDetails,
                        arguments: {'eventId': recruitment.relatedEventId}),
                    icon: const Icon(Icons.event),
                    label: const Text('イベント詳細を見る'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTagRow(String label, List<String> tags, ColorScheme colorScheme,
      {bool isRequired = false}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags
                  .map((t) => Chip(
                        label: Text(t),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        backgroundColor: isRequired
                            ? colorScheme.primaryContainer
                            : null,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Text('$label: ',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
