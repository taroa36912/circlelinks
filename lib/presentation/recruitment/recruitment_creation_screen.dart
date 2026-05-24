import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class RecruitmentCreationScreen extends ConsumerStatefulWidget {
  final String circleId;

  const RecruitmentCreationScreen({super.key, required this.circleId});

  @override
  ConsumerState<RecruitmentCreationScreen> createState() =>
      _RecruitmentCreationScreenState();
}

class _RecruitmentCreationScreenState
    extends ConsumerState<RecruitmentCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _welcomeTagsController = TextEditingController();
  final _requiredTagsController = TextEditingController();
  final _targetYearsController = TextEditingController();
  final _activityDaysController = TextEditingController();
  final _feeController = TextEditingController();
  final _capacityController = TextEditingController();
  String _applicationMethod = 'dm';
  bool _isLoading = false;
  DateTime? _deadline;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _welcomeTagsController.dispose();
    _requiredTagsController.dispose();
    _targetYearsController.dispose();
    _activityDaysController.dispose();
    _feeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  List<String> _parseTags(String text) {
    return text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _createRecruitment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final circle = await ref.read(firestoreServiceProvider).getCircle(widget.circleId);
      final firestoreService = ref.read(firestoreServiceProvider);
      final now = DateTime.now();

      final recruitment = RecruitmentModel(
        id: '',
        circleId: widget.circleId,
        circleName: circle?.circleName ?? '',
        universityName: circle?.universityName ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: 'open',
        targetYears: _parseTags(_targetYearsController.text),
        welcomeTags: _parseTags(_welcomeTagsController.text),
        requiredTags: _parseTags(_requiredTagsController.text),
        activityDaysText: _activityDaysController.text.trim(),
        feeText: _feeController.text.trim(),
        applicationMethod: _applicationMethod,
        capacity: int.tryParse(_capacityController.text.trim()),
        deadline: _deadline,
        createdAt: now,
        updatedAt: now,
      );

      await firestoreService.createRecruitment(recruitment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('募集を作成しました'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('作成に失敗しました: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('募集を作成'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(4.w),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'タイトル *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'タイトルを入力してください' : null,
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: '説明 *'),
              maxLines: 5,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '説明を入力してください' : null,
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _targetYearsController,
              decoration: const InputDecoration(
                  labelText: '対象学年', hintText: 'カンマ区切り 例: 1年生,2年生'),
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _welcomeTagsController,
              decoration: const InputDecoration(
                  labelText: '歓迎タグ', hintText: 'カンマ区切り 例: 初心者歓迎,兼サーOK'),
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _requiredTagsController,
              decoration: const InputDecoration(
                  labelText: '必須タグ', hintText: 'カンマ区切り 例: Flutter,デザイン'),
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _activityDaysController,
              decoration:
                  const InputDecoration(labelText: '活動日', hintText: '例: 週2回(水・金)'),
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _feeController,
              decoration:
                  const InputDecoration(labelText: '費用', hintText: '例: 年会費1000円'),
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _capacityController,
              decoration:
                  const InputDecoration(labelText: '定員', hintText: '未入力なら定員なし'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              initialValue: _applicationMethod,
              decoration: const InputDecoration(labelText: '応募方法'),
              items: const [
                DropdownMenuItem(value: 'dm', child: Text('DMで問い合わせ')),
                DropdownMenuItem(value: 'form', child: Text('フォーム応募')),
                DropdownMenuItem(value: 'event', child: Text('イベント経由')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _applicationMethod = v);
              },
            ),
            SizedBox(height: 2.h),
            ListTile(
              title: const Text('締切'),
              subtitle: Text(_deadline != null
                  ? DateFormat('yyyy/MM/dd').format(_deadline!)
                  : '設定なし'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDeadline,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _isLoading ? null : _createRecruitment,
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
      ),
    );
  }
}
