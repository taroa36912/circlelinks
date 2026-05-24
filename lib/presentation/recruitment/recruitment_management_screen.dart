import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class RecruitmentManagementScreen extends ConsumerStatefulWidget {
  final String circleId;

  const RecruitmentManagementScreen({super.key, required this.circleId});

  @override
  ConsumerState<RecruitmentManagementScreen> createState() =>
      _RecruitmentManagementScreenState();
}

class _RecruitmentManagementScreenState
    extends ConsumerState<RecruitmentManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('募集管理'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: StreamBuilder<List<RecruitmentModel>>(
        stream: firestoreService.getRecruitmentsForCircle(widget.circleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final errStr = snapshot.error.toString();
            final isPermissionDenied = errStr.contains('permission-denied');
            return Center(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPermissionDenied ? Icons.lock : Icons.error_outline,
                      size: 64,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isPermissionDenied
                          ? '募集情報を読み込めませんでした。\n権限設定を確認してください。'
                          : 'エラー: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (isPermissionDenied) ...[
                      SizedBox(height: 1.h),
                      Text(
                        'Firestore Security Rules の設定が必要です。\nfirebase deploy --only firestore:rules を実行してください。',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          final recruitments = snapshot.data ?? [];

          if (recruitments.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.campaign,
                      size: 64, color: colorScheme.onSurfaceVariant),
                  SizedBox(height: 2.h),
                  const Text('作成した募集はまだありません'),
                  SizedBox(height: 2.h),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.recruitmentCreation,
                      arguments: {'circleId': widget.circleId},
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('新規募集を作成'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(4.w),
            itemCount: recruitments.length,
            separatorBuilder: (_, __) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final r = recruitments[index];
              return Card(
                child: ListTile(
                  title: Text(r.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      'status: ${r.status == "open" ? "募集中" : "終了"}  応募: ${r.applicantCount}件'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action == 'applications') {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.recruitmentApplications,
                          arguments: {
                            'circleId': widget.circleId,
                            'recruitmentId': r.id,
                          },
                        );
                      } else if (action == 'close') {
                        await firestoreService.closeRecruitment(r.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('募集を終了しました')),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'applications',
                          child: Text('応募者を見る')),
                      if (r.status == 'open')
                        const PopupMenuItem(
                            value: 'close', child: Text('募集を終了')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.recruitmentCreation,
          arguments: {'circleId': widget.circleId},
        ),
        icon: const Icon(Icons.add),
        label: const Text('新規募集を作成'),
      ),
    );
  }
}
