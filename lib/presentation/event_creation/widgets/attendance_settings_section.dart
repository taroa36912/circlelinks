import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AttendanceSettingsSection extends StatefulWidget {
  final DateTime? rsvpDeadline;
  final Function(DateTime?) onRsvpDeadlineChanged;
  final int? capacityLimit;
  final Function(int?) onCapacityLimitChanged;
  final List<String> attendanceOptions;
  final Function(List<String>) onAttendanceOptionsChanged;

  const AttendanceSettingsSection({
    super.key,
    required this.rsvpDeadline,
    required this.onRsvpDeadlineChanged,
    required this.capacityLimit,
    required this.onCapacityLimitChanged,
    required this.attendanceOptions,
    required this.onAttendanceOptionsChanged,
  });

  @override
  State<AttendanceSettingsSection> createState() =>
      _AttendanceSettingsSectionState();
}

class _AttendanceSettingsSectionState extends State<AttendanceSettingsSection> {
  final TextEditingController _capacityController = TextEditingController();

  final List<Map<String, dynamic>> availableOptions = [
    {
      'id': 'attending',
      'name': '参加',
      'icon': 'check_circle',
      'color': AppTheme.success,
      'required': true,
    },
    {
      'id': 'not_attending',
      'name': '不参加',
      'icon': 'cancel',
      'color': AppTheme.error,
      'required': true,
    },
    {
      'id': 'undecided',
      'name': '未定',
      'icon': 'help',
      'color': AppTheme.warning,
      'required': false,
    },
    {
      'id': 'attending_late',
      'name': '遅刻参加',
      'icon': 'schedule',
      'color': AppTheme.lightTheme.colorScheme.secondary,
      'required': false,
    },
    {
      'id': 'first_party_only',
      'name': '1次会のみ',
      'icon': 'looks_one',
      'color': AppTheme.lightTheme.colorScheme.primary,
      'required': false,
    },
    {
      'id': 'second_party_only',
      'name': '2次会のみ',
      'icon': 'looks_two',
      'color': AppTheme.lightTheme.colorScheme.primary,
      'required': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.capacityLimit != null) {
      _capacityController.text = widget.capacityLimit.toString();
    }
  }

  @override
  void dispose() {
    _capacityController.dispose();
    super.dispose();
  }

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
              '出席設定',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
            ),
            SizedBox(height: 3.h),

            // RSVP Deadline
            GestureDetector(
              onTap: () => _selectRsvpDeadline(context),
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'event_available',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RSVP締切日',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                          ),
                          Text(
                            widget.rsvpDeadline != null
                                ? '${widget.rsvpDeadline!.year}年${widget.rsvpDeadline!.month}月${widget.rsvpDeadline!.day}日'
                                : '締切日を設定してください',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: widget.rsvpDeadline != null
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'chevron_right',
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // Capacity Limit
            TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '定員制限',
                hintText: '例：30',
                prefixIcon: Icon(
                  Icons.people_rounded,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                suffixText: '人',
                helperText: '空欄の場合は制限なし',
              ),
              onChanged: (value) {
                final capacity = int.tryParse(value);
                widget.onCapacityLimitChanged(capacity);
              },
            ),
            SizedBox(height: 3.h),

            // Attendance Options
            Text(
              '出席オプション',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
            ),
            SizedBox(height: 1.h),

            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'info',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 18,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'メンバーが選択できる出席オプション',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '「参加」と「不参加」は必須オプションです',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // Options List
            Column(
              children: availableOptions.map((option) {
                final isSelected =
                    widget.attendanceOptions.contains(option['id']);
                final isRequired = option['required'] as bool;

                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  child: GestureDetector(
                    onTap:
                        isRequired ? null : () => _toggleOption(option['id']),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (option['color'] as Color).withValues(alpha: 0.1)
                            : AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (option['color'] as Color)
                              : AppTheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: option['icon'],
                            color: isSelected
                                ? (option['color'] as Color)
                                : AppTheme.textSecondary,
                            size: 20,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              option['name'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? AppTheme.textPrimary
                                        : AppTheme.textSecondary,
                                  ),
                            ),
                          ),
                          if (isRequired) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '必須',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ] else ...[
                            CustomIconWidget(
                              iconName: isSelected
                                  ? 'check_box'
                                  : 'check_box_outline_blank',
                              color: isSelected
                                  ? (option['color'] as Color)
                                  : AppTheme.textSecondary,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Selected Options Summary
            if (widget.attendanceOptions.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '選択されたオプション (${widget.attendanceOptions.length})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    Wrap(
                      spacing: 1.w,
                      runSpacing: 0.5.h,
                      children: widget.attendanceOptions.map((optionId) {
                        final option = availableOptions.firstWhere(
                          (opt) => opt['id'] == optionId,
                        );
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: (option['color'] as Color)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            option['name'],
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: option['color'] as Color,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectRsvpDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          widget.rsvpDeadline ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              headerBackgroundColor: AppTheme.lightTheme.colorScheme.primary,
              headerForegroundColor: Colors.white,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return AppTheme.textPrimary;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.lightTheme.colorScheme.primary;
                }
                return null;
              }),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onRsvpDeadlineChanged(picked);
    }
  }

  void _toggleOption(String optionId) {
    final updatedOptions = List<String>.from(widget.attendanceOptions);
    if (updatedOptions.contains(optionId)) {
      updatedOptions.remove(optionId);
    } else {
      updatedOptions.add(optionId);
    }
    widget.onAttendanceOptionsChanged(updatedOptions);
  }
}
