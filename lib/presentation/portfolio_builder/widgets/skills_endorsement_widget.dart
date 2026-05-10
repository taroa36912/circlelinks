import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SkillsEndorsementWidget extends StatefulWidget {
  final List<Map<String, dynamic>> skills;
  final Function(String) onRequestEndorsement;
  final Future<void> Function(String) onAddSkill;
  final Function(Map<String, dynamic>) onEditSkill;
  final Function(Map<String, dynamic>) onDeleteSkill;

  const SkillsEndorsementWidget({
    super.key,
    required this.skills,
    required this.onRequestEndorsement,
    required this.onAddSkill,
    required this.onEditSkill,
    required this.onDeleteSkill,
  });

  @override
  State<SkillsEndorsementWidget> createState() =>
      _SkillsEndorsementWidgetState();
}

class _SkillsEndorsementWidgetState extends State<SkillsEndorsementWidget> {
  final TextEditingController _skillController = TextEditingController();
  String _selectedCategory = 'Technical';

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'star',
                color: AppTheme.warning,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Skills & Endorsements',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: _showAddSkillDialog,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: colorScheme.primary,
                  size: 6.w,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildSkillCategories(),
        ],
      ),
    );
  }

  Widget _buildSkillCategories() {
    final groupedSkills = _groupSkillsByCategory();

    return Column(
      children: groupedSkills.entries.map((entry) {
        final category = entry.key;
        final skills = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Text(
                category,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getCategoryColor(category),
                    ),
              ),
            ),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: skills.map((skill) => _buildSkillChip(skill)).toList(),
            ),
            SizedBox(height: 2.h),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSkillChip(Map<String, dynamic> skill) {
    final theme = Theme.of(context);
    final endorsementCount = skill['endorsements'] as int? ?? 0;
    final category = skill['category'] as String? ?? 'Technical';
    final categoryColor = _getCategoryColor(category);

    return InkWell(
      onTap: () => _showSkillActions(skill),
      borderRadius: BorderRadius.circular(6.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: categoryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6.w),
          border: Border.all(
            color: categoryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              skill['name'] as String? ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: categoryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (endorsementCount > 0) ...[
              SizedBox(width: 2.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Text(
                  '$endorsementCount',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSkillActions(Map<String, dynamic> skill) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                margin: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'edit',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                title: const Text('編集'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onEditSkill(skill);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.error,
                  size: 24,
                ),
                title: const Text('削除'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDeleteSkill(skill);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'thumb_up',
                  color: AppTheme.success,
                  size: 24,
                ),
                title: const Text('推薦を依頼'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onRequestEndorsement(skill['name'] as String? ?? '');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupSkillsByCategory() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final skill in widget.skills) {
      final category = skill['category'] as String? ?? 'Technical';
      grouped.putIfAbsent(category, () => []).add(skill);
    }

    return grouped;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technical':
        return AppTheme.primary;
      case 'leadership':
        return AppTheme.secondary;
      case 'creative':
        return AppTheme.success;
      case 'communication':
        return AppTheme.warning;
      default:
        return AppTheme.primary;
    }
  }

  void _showAddSkillDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Skill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _skillController,
              decoration: const InputDecoration(
                labelText: 'Skill Name',
                hintText: 'e.g., Flutter Development',
              ),
            ),
            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: ['Technical', 'Leadership', 'Creative', 'Communication']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'Technical';
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_skillController.text.isNotEmpty) {
                await widget.onAddSkill(_skillController.text);
                _skillController.clear();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Add Skill'),
          ),
        ],
      ),
    );
  }
}
