import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AchievementCardWidget extends StatelessWidget {
  final Map<String, dynamic> achievement;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onRequestVerification;

  const AchievementCardWidget({
    super.key,
    required this.achievement,
    required this.onTap,
    required this.onShare,
    required this.onRequestVerification,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isVerified = achievement['isVerified'] as bool? ?? false;
    final impactScore = achievement['impactScore'] as int? ?? 0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showActionBottomSheet(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                            achievement['category'] as String? ?? '')
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: CustomIconWidget(
                    iconName: _getCategoryIcon(
                        achievement['category'] as String? ?? ''),
                    color: _getCategoryColor(
                        achievement['category'] as String? ?? ''),
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement['title'] as String? ?? '',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(1.w),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'verified',
                                    color: AppTheme.success,
                                    size: 3.w,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    'Verified',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.success,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        achievement['organization'] as String? ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              achievement['description'] as String? ?? '',
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                _buildMetricChip(
                  context,
                  'Impact',
                  '$impactScore/10',
                  _getImpactColor(impactScore),
                ),
                SizedBox(width: 2.w),
                _buildMetricChip(
                  context,
                  'Duration',
                  achievement['duration'] as String? ?? '',
                  colorScheme.primary,
                ),
                const Spacer(),
                Text(
                  achievement['date'] as String? ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(
      BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(1.w),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'leadership':
        return AppTheme.primary;
      case 'event':
        return AppTheme.secondary;
      case 'project':
        return AppTheme.success;
      case 'skill':
        return AppTheme.warning;
      default:
        return AppTheme.primary;
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'leadership':
        return 'groups';
      case 'event':
        return 'event';
      case 'project':
        return 'work';
      case 'skill':
        return 'star';
      default:
        return 'achievement';
    }
  }

  Color _getImpactColor(int score) {
    if (score >= 8) return AppTheme.success;
    if (score >= 6) return AppTheme.warning;
    return AppTheme.error;
  }

  void _showActionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 1.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(0.5.h),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Share Achievement'),
              onTap: () {
                Navigator.pop(context);
                onShare();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'verified_user',
                color: AppTheme.success,
                size: 6.w,
              ),
              title: const Text('Request Verification'),
              onTap: () {
                Navigator.pop(context);
                onRequestVerification();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
