import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class RecruitmentApplicationsScreen extends ConsumerStatefulWidget {
  final String circleId;
  final String? recruitmentId;

  const RecruitmentApplicationsScreen({
    super.key,
    required this.circleId,
    this.recruitmentId,
  });

  @override
  ConsumerState<RecruitmentApplicationsScreen> createState() =>
      _RecruitmentApplicationsScreenState();
}

class _RecruitmentApplicationsScreenState
    extends ConsumerState<RecruitmentApplicationsScreen> {
  Future<void> _acceptAndAdd(RecruitmentApplicationModel app) async {
    final roleController = TextEditingController();
    final roleTagsController = TextEditingController();
    final skillTagsController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('メンバーとして追加'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${app.applicantName} さんをメンバーに追加しますか？'),
              SizedBox(height: 2.h),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(
                    labelText: '役職名', hintText: '例: 会計, 広報'),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: roleTagsController,
                decoration: const InputDecoration(
                    labelText: '役割タグ', hintText: 'カンマ区切り'),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: skillTagsController,
                decoration: const InputDecoration(
                    labelText: 'スキルタグ', hintText: 'カンマ区切り'),
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
              child: const Text('追加する')),
        ],
      ),
    );

    if (result != true) return;

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.acceptRecruitmentApplicationAndAddMember(
        recruitmentId: app.recruitmentId,
        applicationId: app.id,
        displayRole: roleController.text.trim().isNotEmpty
            ? roleController.text.trim()
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
          const SnackBar(
              content: Text('メンバーを追加しました！'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('追加に失敗しました: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('応募者一覧'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: StreamBuilder<List<RecruitmentApplicationModel>>(
        stream: widget.recruitmentId != null
            ? firestoreService
                .getApplicationsForRecruitment(widget.recruitmentId!)
            : firestoreService.getApplicationsForCircle(widget.circleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラー: ${snapshot.error}'));
          }

          final apps = snapshot.data ?? [];

          if (apps.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: colorScheme.onSurfaceVariant),
                  SizedBox(height: 2.h),
                  const Text('応募者はまだいません'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(4.w),
            itemCount: apps.length,
            separatorBuilder: (_, __) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final app = apps[index];
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(app.applicantName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                          ),
                          _statusChip(app.status),
                        ],
                      ),
                      if (app.message.isNotEmpty) ...[
                        SizedBox(height: 1.h),
                        Text(app.message,
                            style: theme.textTheme.bodyMedium),
                      ],
                      if (app.applicantTags.isNotEmpty) ...[
                        SizedBox(height: 1.h),
                        Wrap(
                          spacing: 4,
                          children: app.applicantTags
                              .map((t) => Chip(
                                    label: Text(t),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                      ],
                      SizedBox(height: 2.h),
                      if (app.status == 'pending')
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await firestoreService
                                      .updateRecruitmentApplicationStatus(
                                    recruitmentId: app.recruitmentId,
                                    applicationId: app.id,
                                    status: 'declined',
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red),
                                child: const Text('辞退'),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _acceptAndAdd(app),
                                child: const Text('承諾して追加'),
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            if (app.status == 'declined')
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await firestoreService
                                        .updateRecruitmentApplicationStatus(
                                      recruitmentId: app.recruitmentId,
                                      applicationId: app.id,
                                      status: 'pending',
                                    );
                                  },
                                  child: const Text('再検討'),
                                ),
                              ),
                            if (app.status == 'accepted')
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _acceptAndAdd(app),
                                  child: const Text('メンバー追加(再実行)'),
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
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'accepted':
        color = Colors.green;
        label = '承諾済み';
        break;
      case 'declined':
        color = Colors.red;
        label = '辞退';
        break;
      case 'withdrawn':
        color = Colors.grey;
        label = '取り下げ';
        break;
      default:
        color = Colors.orange;
        label = '審査中';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child:
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
