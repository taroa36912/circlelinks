import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import 'project_providers.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(openProjectsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text('プロジェクト募集'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          final errStr = error.toString();
          final isPermissionDenied = errStr.contains('permission-denied');
          return _ProjectErrorView(
            message: isPermissionDenied
                ? 'プロジェクト一覧を読み込めませんでした。\n権限設定を確認してください。\nfirebase deploy --only firestore:rules を実行してください。'
                : errStr,
            onRetry: () => ref.invalidate(openProjectsProvider),
          );
        },
        data: (projects) {
          if (projects.isEmpty) {
            return _EmptyProjectView(
              onCreate: () => Navigator.pushNamed(
                context,
                AppRoutes.projectCreation,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(openProjectsProvider),
            child: ListView.separated(
              padding: EdgeInsets.all(4.w),
              itemCount: projects.length,
              separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
              itemBuilder: (context, index) {
                final project = projects[index];
                return _ProjectCard(
                  project: project,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.projectDetails,
                    arguments: {'projectId': project.id},
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.projectCreation,
        ),
        icon: CustomIconWidget(
          iconName: 'add',
          color: colorScheme.onPrimary,
          size: 20,
        ),
        label: const Text('募集を作成する'),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxParticipants = project.maxParticipants;
    final countText = maxParticipants == null
        ? '${project.participantIds.length}人参加中'
        : '${project.participantIds.length} / $maxParticipants人';

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
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
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: project.creatorImageUrl != null &&
                            project.creatorImageUrl!.trim().isNotEmpty
                        ? NetworkImage(project.creatorImageUrl!)
                        : null,
                    child: project.creatorImageUrl == null ||
                            project.creatorImageUrl!.trim().isEmpty
                        ? CustomIconWidget(
                            iconName: 'person',
                            color: colorScheme.onSurfaceVariant,
                            size: 22,
                          )
                        : null,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.creatorName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateFormat('yyyy/MM/dd HH:mm')
                              .format(project.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CategoryChip(category: project.category),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                project.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.h),
              Text(
                project.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'groups',
                    color: colorScheme.primary,
                    size: 18,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    countText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _EmptyProjectView extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyProjectView({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'campaign',
              color: colorScheme.primary,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              '募集中のプロジェクトはまだありません',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              '勉強会、開発チーム、イベント企画などの募集を作成できます。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('募集を作成する'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProjectErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('再読み込み'),
            ),
          ],
        ),
      ),
    );
  }
}
