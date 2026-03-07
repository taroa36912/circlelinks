import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class CircleManagementScreen extends ConsumerStatefulWidget {
  final CircleModel circle;

  const CircleManagementScreen({
    super.key,
    required this.circle,
  });

  @override
  ConsumerState<CircleManagementScreen> createState() => _CircleManagementScreenState();
}

class _CircleManagementScreenState extends ConsumerState<CircleManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _circleNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _memberCountController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _circleNameController = TextEditingController(text: widget.circle.circleName);
    _descriptionController = TextEditingController(text: widget.circle.description);
    _memberCountController = TextEditingController(text: widget.circle.memberCount.toString());
  }

  @override
  void dispose() {
    _circleNameController.dispose();
    _descriptionController.dispose();
    _memberCountController.dispose();
    super.dispose();
  }

  Future<void> _updateCircle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    try {
      final updatedCircle = widget.circle.copyWith(
        circleName: _circleNameController.text.trim(),
        description: _descriptionController.text.trim(),
        memberCount: int.tryParse(_memberCountController.text.trim()) ?? 0,
        updatedAt: DateTime.now(),
      );

      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateCircle(updatedCircle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('サークル情報を更新しました')),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新に失敗しました: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.circle.circleName} の管理'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⬇️ --- 新規追加: サークル間コネクションボタン --- ⬇️
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // コネクション管理画面へ遷移 (circleIdを渡す)
                    Navigator.pushNamed(
                      context,
                      AppRoutes.connections,
                      arguments: {'circleId': widget.circle.id}, // 👈 自分のサークルIDを渡す
                    );
                  },
                  icon: const Icon(Icons.people_outline),
                  label: const Text('サークル間コネクション管理'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              // ⬆️ ------------------------------------------- ⬆️

              // --- DMへの導線 ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.circleDmList,
                      arguments: {'circleId': widget.circle.id},
                    );
                  },
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('このサークルへのDMを確認する'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              
              SizedBox(height: 4.h),
              const Divider(),
              SizedBox(height: 2.h),
              
              Text(
                '基本情報の編集',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 3.h),

              TextFormField(
                controller: _circleNameController,
                decoration: const InputDecoration(labelText: 'サークル名'),
                validator: (value) => value!.isEmpty ? '入力してください' : null,
              ),
              SizedBox(height: 2.h),

              TextFormField(
                controller: _memberCountController,
                decoration: const InputDecoration(labelText: 'メンバー数'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 2.h),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '活動内容'),
                maxLines: 5,
              ),

              SizedBox(height: 4.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateCircle,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Text('変更を保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}