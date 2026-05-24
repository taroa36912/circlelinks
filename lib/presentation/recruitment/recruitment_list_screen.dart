import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class RecruitmentListScreen extends ConsumerStatefulWidget {
  const RecruitmentListScreen({super.key});

  @override
  ConsumerState<RecruitmentListScreen> createState() =>
      _RecruitmentListScreenState();
}

class _RecruitmentListScreenState extends ConsumerState<RecruitmentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('新歓・メンバー募集'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'キーワードで検索',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<RecruitmentModel>>(
              stream: firestoreService.getOpenRecruitmentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('エラー: ${snapshot.error}'));
                }

                final recruitments = (snapshot.data ?? [])
                    .where((r) =>
                        _searchQuery.isEmpty ||
                        r.title.contains(_searchQuery) ||
                        r.circleName.contains(_searchQuery) ||
                        r.description.contains(_searchQuery))
                    .toList();

                if (recruitments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64,
                            color: colorScheme.onSurfaceVariant),
                        SizedBox(height: 2.h),
                        const Text('募集中の募集はありません'),
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
                    return _RecruitmentCard(
                      recruitment: r,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.recruitmentDetails,
                        arguments: {'recruitmentId': r.id},
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecruitmentCard extends StatelessWidget {
  final RecruitmentModel recruitment;
  final VoidCallback onTap;

  const _RecruitmentCard({required this.recruitment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recruitment.title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('募集中',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: Colors.green)),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text('${recruitment.circleName}  (${recruitment.universityName})',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant)),
              SizedBox(height: 1.h),
              Text(recruitment.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium),
              if (recruitment.welcomeTags.isNotEmpty ||
                  recruitment.requiredTags.isNotEmpty) ...[
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ...recruitment.welcomeTags.take(3).map((t) => Chip(
                          label: Text(t),
                          labelStyle: theme.textTheme.labelSmall,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        )),
                    ...recruitment.requiredTags.take(2).map((t) => Chip(
                          label: Text(t),
                          labelStyle: theme.textTheme.labelSmall,
                          backgroundColor:
                              colorScheme.primaryContainer,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        )),
                  ],
                ),
              ],
              if (recruitment.deadline != null) ...[
                SizedBox(height: 1.h),
                Text(
                  '締切: ${DateFormat('yyyy/MM/dd').format(recruitment.deadline!)}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.orange),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
