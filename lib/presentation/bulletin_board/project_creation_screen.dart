import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import 'project_providers.dart';

class ProjectCreationScreen extends ConsumerStatefulWidget {
  const ProjectCreationScreen({super.key});

  @override
  ConsumerState<ProjectCreationScreen> createState() =>
      _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends ConsumerState<ProjectCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _requiredTagsController = TextEditingController();
  final _relatedTagsController = TextEditingController();
  String _category = 'Study';
  bool _isLoading = false;
  String _recruitmentType = 'project';
  String _applicationPolicy = 'firstCome';

  static const List<String> _categories = [
    'Study',
    'Development',
    'Event',
    'Research',
    'Creative',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    _requiredTagsController.dispose();
    _relatedTagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text('募集を作成'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
        data: (userModel) {
          final firebaseUser =
              ref.watch(firebaseAuthServiceProvider).currentUser;
          if (firebaseUser == null || userModel == null) {
            return const Center(child: Text('ログインが必要です'));
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(4.w),
              children: [
                _FormCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'タイトル',
                          hintText: '例: ハッカソンのチームメンバー募集',
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'タイトルを入力してください';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: '詳細説明',
                          hintText: '目的、活動内容、参加条件などを書いてください',
                          alignLabelWithHint: true,
                        ),
                        minLines: 5,
                        maxLines: 8,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '詳細説明を入力してください';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(labelText: 'カテゴリー'),
                        items: _categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _category = value);
                          }
                        },
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _maxParticipantsController,
                        decoration: const InputDecoration(
                          labelText: '上限人数',
                          hintText: '未入力なら上限なし',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final parsed = int.tryParse(value);
                          if (parsed == null || parsed <= 0) {
                            return '1以上の数字を入力してください';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                      DropdownButtonFormField<String>(
                        initialValue: _recruitmentType,
                        decoration: const InputDecoration(labelText: '募集タイプ'),
                        items: const [
                          DropdownMenuItem(value: 'project', child: Text('プロジェクト立ち上げ')),
                          DropdownMenuItem(value: 'temporary_member', child: Text('臨時メンバー募集')),
                          DropdownMenuItem(value: 'joint_event', child: Text('合同企画スタッフ募集')),
                          DropdownMenuItem(value: 'new_member', child: Text('新規メンバー募集')),
                          DropdownMenuItem(value: 'staff', child: Text('スタッフ募集')),
                          DropdownMenuItem(value: 'other', child: Text('その他')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _recruitmentType = v);
                        },
                      ),
                      SizedBox(height: 2.h),
                      DropdownButtonFormField<String>(
                        initialValue: _applicationPolicy,
                        decoration: const InputDecoration(labelText: '応募方式'),
                        items: const [
                          DropdownMenuItem(value: 'firstCome', child: Text('先着順')),
                          DropdownMenuItem(value: 'approvalRequired', child: Text('承認制')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _applicationPolicy = v);
                        },
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _requiredTagsController,
                        decoration: const InputDecoration(
                            labelText: '必須タグ', hintText: 'カンマ区切り'),
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _relatedTagsController,
                        decoration: const InputDecoration(
                            labelText: '関連タグ', hintText: 'カンマ区切り'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _createProject(
                            creatorId: firebaseUser.uid,
                            userModel: userModel,
                          ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('募集を公開する'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _createProject({
    required String creatorId,
    required UserModel userModel,
  }) async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final maxParticipantsText = _maxParticipantsController.text.trim();
      final now = DateTime.now();
      final project = ProjectModel(
        id: '',
        creatorId: creatorId,
        creatorName: userModel.userName,
        creatorImageUrl: userModel.profileImageUrl,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        maxParticipants:
            maxParticipantsText.isEmpty ? null : int.parse(maxParticipantsText),
        participantIds: [creatorId],
        status: 'open',
        createdAt: now,
        updatedAt: now,
        recruitmentType: _recruitmentType,
        applicationPolicy: _applicationPolicy,
        requiredTags: _requiredTagsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        relatedTags: _relatedTagsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      );

      await ref.read(firestoreServiceProvider).createProject(project);
      ref.invalidate(openProjectsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('募集を作成しました')),
        );
      }
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

class _FormCard extends StatelessWidget {
  final Widget child;

  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
