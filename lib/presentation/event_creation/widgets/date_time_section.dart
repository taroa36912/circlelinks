import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/app_export.dart';

class DateTimeSection extends StatefulWidget {
  final List<DateTime> selectedDates;
  final Function(List<DateTime>) onDatesChanged;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final Function(TimeOfDay?) onStartTimeChanged;
  final Function(TimeOfDay?) onEndTimeChanged;

  const DateTimeSection({
    super.key,
    required this.selectedDates,
    required this.onDatesChanged,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  State<DateTimeSection> createState() => _DateTimeSectionState();
}

class _DateTimeSectionState extends State<DateTimeSection> {
  DateTime _focusedDay = DateTime.now();
  bool _showCalendar = false;

  final List<Map<String, dynamic>> conflictingEvents = [
    {
      'title': '定期練習',
      'date': DateTime.now().add(const Duration(days: 3)),
      'time': '18:00-20:00',
    },
    {
      'title': '他サークル合同イベント',
      'date': DateTime.now().add(const Duration(days: 7)),
      'time': '19:00-22:00',
    },
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '日時設定',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _showCalendar = !_showCalendar),
                  icon: CustomIconWidget(
                    iconName:
                        _showCalendar ? 'keyboard_arrow_up' : 'calendar_month',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  label: Text(
                    _showCalendar ? '閉じる' : 'カレンダー',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Multiple Date Proposals
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
                        '複数の候補日を提案できます',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'メンバーが投票して最適な日程を決定します',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // Selected Dates Display
            if (widget.selectedDates.isNotEmpty) ...[
              Text(
                '選択された候補日 (${widget.selectedDates.length})',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
              ),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: widget.selectedDates.map((date) {
                  return Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${date.month}/${date.day}(${_getWeekdayName(date.weekday)})',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        SizedBox(width: 1.w),
                        GestureDetector(
                          onTap: () {
                            final updatedDates =
                                List<DateTime>.from(widget.selectedDates);
                            updatedDates.remove(date);
                            widget.onDatesChanged(updatedDates);
                          },
                          child: CustomIconWidget(
                            iconName: 'close',
                            color: AppTheme
                                .lightTheme.colorScheme.onPrimaryContainer,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 2.h),
            ],

            // Calendar
            if (_showCalendar) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TableCalendar<String>(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) =>
                      widget.selectedDates.any((date) => isSameDay(date, day)),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle:
                        Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                    leftChevronIcon: CustomIconWidget(
                      iconName: 'chevron_left',
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
                    rightChevronIcon: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    selectedDecoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: AppTheme.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  eventLoader: (day) {
                    return conflictingEvents
                        .where((event) => isSameDay(event['date'], day))
                        .map((event) => event['title'] as String)
                        .toList();
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() => _focusedDay = focusedDay);

                    final updatedDates =
                        List<DateTime>.from(widget.selectedDates);
                    if (updatedDates
                        .any((date) => isSameDay(date, selectedDay))) {
                      updatedDates
                          .removeWhere((date) => isSameDay(date, selectedDay));
                    } else {
                      updatedDates.add(selectedDay);
                    }
                    widget.onDatesChanged(updatedDates);
                  },
                ),
              ),
              SizedBox(height: 2.h),
            ],

            // Time Selection
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, true),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'schedule',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '開始時間',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                              Text(
                                widget.startTime?.format(context) ?? '選択してください',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: widget.startTime != null
                                          ? AppTheme.textPrimary
                                          : AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, false),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'schedule',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '終了時間',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                              Text(
                                widget.endTime?.format(context) ?? '選択してください',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: widget.endTime != null
                                          ? AppTheme.textPrimary
                                          : AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Conflict Detection
            if (_hasConflicts()) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'warning',
                          color: AppTheme.warning,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '日程の競合があります',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.warning,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    ..._getConflictingEvents().map((event) => Padding(
                          padding: EdgeInsets.only(bottom: 0.5.h),
                          child: Text(
                            '• ${event['title']} (${event['time']})',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (widget.startTime ?? const TimeOfDay(hour: 18, minute: 0))
          : (widget.endTime ?? const TimeOfDay(hour: 20, minute: 0)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              hourMinuteTextColor: AppTheme.textPrimary,
              dayPeriodTextColor: AppTheme.textPrimary,
              dialHandColor: AppTheme.lightTheme.colorScheme.primary,
              dialBackgroundColor: AppTheme.surfaceVariant,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStartTime) {
        widget.onStartTimeChanged(picked);
      } else {
        widget.onEndTimeChanged(picked);
      }
    }
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[weekday - 1];
  }

  bool _hasConflicts() {
    return widget.selectedDates.any((date) =>
        conflictingEvents.any((event) => isSameDay(event['date'], date)));
  }

  List<Map<String, dynamic>> _getConflictingEvents() {
    return conflictingEvents
        .where((event) =>
            widget.selectedDates.any((date) => isSameDay(event['date'], date)))
        .toList();
  }
}
