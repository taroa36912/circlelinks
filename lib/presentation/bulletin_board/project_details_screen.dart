import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import 'project_providers.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectProvider(widget.projectId));
    final userAsync = ref.watch(currentUserModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text('募集詳細'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: projectAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
        data: (project) {
          if (project == null) {
            return const Center(child: Text('プロジェクトが見つかりません'));
          }

          return userAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _ProjectDetailsContent(
              project: project,
              currentUser: null,
              isLoading: _isLoading,
              errorMessage: error.toString(),
              onJoin: null,
              onLeave: null,
            ),
            data: (currentUser) => _ProjectDetailsContent(
              project: project,
              currentUser: currentUser,
              isLoading: _isLoading,
              onJoin: currentUser == null ? null : () => _join(project),
              onLeave: currentUser == null ? null : () => _leave(project),
            ),
          );
        },
      ),
    );
  }

  Future<void> _join(ProjectModel project) async {
    final firebaseUser = ref.read(firebaseAuthServiceProvider).currentUser;
    if (firebaseUser == null) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(firestoreServiceProvider)
          .joinProject(project.id, firebaseUser.uid);
      ref.invalidate(projectProvider(project.id));
      ref.invalidate(openProjectsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _leave(ProjectModel project) async {
    final firebaseUser = ref.read(firebaseAuthServiceProvider).currentUser;
    if (firebaseUser == null) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(firestoreServiceProvider)
          .leaveProject(project.id, firebaseUser.uid);
      ref.invalidate(projectProvider(project.id));
      ref.invalidate(openProjectsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _ProjectDetailsContent extends StatelessWidget {
  final ProjectModel project;
  final UserModel? currentUser;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;

  const _ProjectDetailsContent({
    required this.project,
    required this.currentUser,
    required this.isLoading,
    this.errorMessage,
    this.onJoin,
    this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUserId = currentUser?.id;
    final isParticipant =
        currentUserId != null && project.participantIds.contains(currentUserId);
    final canJoin = currentUser?.isUniversityStudent ?? false;
    final maxParticipants = project.maxParticipants;
    final participantText = maxParticipants == null
        ? '${project.participantIds.length}人参加中'
        : '${project.participantIds.length} / $maxParticipants人';
    final isFull = maxParticipants != null &&
        project.participantIds.length >= maxParticipants;

    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SafeAvatarWidget(
                    imageUrl: project.creatorImageUrl,
                    radius: 24,
                    fallback: CustomIconWidget(
                      iconName: 'person',
                      color: colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.creatorName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
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
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                project.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    iconName: 'category',
                    label: project.category,
                  ),
                  _InfoChip(
                    iconName: 'groups',
                    label: participantText,
                  ),
                  _InfoChip(
                    iconName: project.status == 'open' ? 'campaign' : 'lock',
                    label: project.status == 'open' ? '募集中' : '募集終了',
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                '説明',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                project.description,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        if (errorMessage != null) ...[
          SizedBox(height: 2.h),
          Text(
            errorMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ],
        SizedBox(height: 3.h),
        if (currentUser == null)
          const Text('参加するにはログインが必要です')
        else if (!canJoin)
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '大学アカウントでのみ参加可能です',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else if (isParticipant)
          OutlinedButton(
            onPressed: isLoading ? null : onLeave,
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('参加をキャンセルする'),
          )
        else
          ElevatedButton(
            onPressed:
                isLoading || project.status != 'open' || isFull ? null : onJoin,
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isFull ? '募集上限に達しています' : '参加する'),
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String iconName;
  final String label;

  const _InfoChip({
    required this.iconName,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: colorScheme.onPrimaryContainer,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
