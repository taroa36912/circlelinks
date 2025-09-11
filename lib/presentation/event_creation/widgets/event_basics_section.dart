import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EventBasicsSection extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const EventBasicsSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  State<EventBasicsSection> createState() => _EventBasicsSectionState();
}

class _EventBasicsSectionState extends State<EventBasicsSection> {
  final List<Map<String, dynamic>> categories = [
    {'id': 'social', 'name': '懇親会', 'icon': 'celebration'},
    {'id': 'meeting', 'name': '会議', 'icon': 'groups'},
    {'id': 'practice', 'name': '練習', 'icon': 'sports'},
    {'id': 'performance', 'name': '発表', 'icon': 'stage'},
    {'id': 'competition', 'name': '大会', 'icon': 'emoji_events'},
    {'id': 'workshop', 'name': 'ワークショップ', 'icon': 'school'},
    {'id': 'volunteer', 'name': 'ボランティア', 'icon': 'volunteer_activism'},
    {'id': 'other', 'name': 'その他', 'icon': 'more_horiz'},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'イベント基本情報',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
            ),
            SizedBox(height: 3.h),

            // Event Title
            TextField(
              controller: widget.titleController,
              decoration: InputDecoration(
                labelText: 'イベント名 *',
                hintText: '例：新歓コンパ、定期練習',
                prefixIcon: Icon(
                  Icons.event_rounded,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                counterText: '${widget.titleController.text.length}/50',
              ),
              maxLength: 50,
              onChanged: (value) => setState(() {}),
            ),
            SizedBox(height: 2.h),

            // Event Description
            TextField(
              controller: widget.descriptionController,
              decoration: InputDecoration(
                labelText: '詳細説明',
                hintText: 'イベントの詳細を入力してください...',
                prefixIcon: Icon(
                  Icons.description_rounded,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                counterText: '${widget.descriptionController.text.length}/500',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 500,
              onChanged: (value) => setState(() {}),
            ),
            SizedBox(height: 3.h),

            // Category Selection
            Text(
              'カテゴリー *',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
            ),
            SizedBox(height: 1.h),

            SizedBox(
              height: 6.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) => SizedBox(width: 2.w),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = widget.selectedCategory == category['id'];

                  return GestureDetector(
                    onTap: () => widget.onCategoryChanged(category['id']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primaryContainer
                            : AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: category['icon'],
                            color: isSelected
                                ? AppTheme
                                    .lightTheme.colorScheme.onPrimaryContainer
                                : AppTheme.textSecondary,
                            size: 18,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            category['name'],
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? AppTheme.lightTheme.colorScheme
                                              .onPrimaryContainer
                                          : AppTheme.textSecondary,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
