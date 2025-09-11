import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AttendanceSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> attendees;
  final int totalCount;

  const AttendanceSectionWidget({
    super.key,
    required this.attendees,
    required this.totalCount,
  });

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
              children: [
                CustomIconWidget(
                  iconName: 'groups',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Attendees',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalCount going',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildAttendeesList(),
            SizedBox(height: 2.h),
            _buildAttendanceStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeesList() {
    return SizedBox(
      height: 15.w,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: attendees.length > 8 ? 8 : attendees.length,
        itemBuilder: (context, index) {
          if (index == 7 && attendees.length > 8) {
            return _buildMoreAttendeesIndicator();
          }
          return _buildAttendeeAvatar(attendees[index]);
        },
      ),
    );
  }

  Widget _buildAttendeeAvatar(Map<String, dynamic> attendee) {
    return Container(
      margin: EdgeInsets.only(right: 2.w),
      child: GestureDetector(
        onLongPress: () => _showAttendeeProfile(attendee),
        child: Stack(
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getStatusColor(
                      attendee['status'] as String? ?? 'attending'),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  imageUrl: attendee['avatar'] as String? ?? '',
                  width: 15.w,
                  height: 15.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: _getStatusColor(
                      attendee['status'] as String? ?? 'attending'),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreAttendeesIndicator() {
    final remainingCount = attendees.length - 7;
    return Container(
      width: 15.w,
      height: 15.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '+$remainingCount',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceStats() {
    final stats = _calculateAttendanceStats();

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Attending',
            stats['attending']!,
            AppTheme.lightTheme.colorScheme.tertiary,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Late',
            stats['late']!,
            AppTheme.warning,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'First Party',
            stats['firstParty']!,
            AppTheme.lightTheme.colorScheme.secondary,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Undecided',
            stats['undecided']!,
            AppTheme.lightTheme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'attending':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'late':
        return AppTheme.warning;
      case 'first_party':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'undecided':
        return AppTheme.lightTheme.colorScheme.outline;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  Map<String, int> _calculateAttendanceStats() {
    final stats = {
      'attending': 0,
      'late': 0,
      'firstParty': 0,
      'undecided': 0,
    };

    for (final attendee in attendees) {
      final status = attendee['status'] as String? ?? 'undecided';
      switch (status.toLowerCase()) {
        case 'attending':
          stats['attending'] = stats['attending']! + 1;
          break;
        case 'late':
          stats['late'] = stats['late']! + 1;
          break;
        case 'first_party':
          stats['firstParty'] = stats['firstParty']! + 1;
          break;
        default:
          stats['undecided'] = stats['undecided']! + 1;
      }
    }

    return stats;
  }

  void _showAttendeeProfile(Map<String, dynamic> attendee) {
    // This would typically show a profile modal or navigate to profile screen
    // For now, we'll show a simple snackbar
  }
}
