import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CircleCardWidget extends StatelessWidget {
  final Map<String, dynamic> circleData;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CircleCardWidget({
    super.key,
    required this.circleData,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  CustomImageWidget(
                    imageUrl: circleData['coverImage'] as String? ?? '',
                    width: double.infinity,
                    height: 20.h,
                    fit: BoxFit.cover,
                  ),
                  // University Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        circleData['university'] as String? ?? '',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Verification Badge
                  if (circleData['isVerified'] == true)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomIconWidget(
                          iconName: 'verified',
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circle Name and Activity Type
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          circleData['name'] as String? ?? '',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getActivityTypeColor(
                              circleData['activityType'] as String? ?? ''),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: CustomIconWidget(
                          iconName: _getActivityTypeIcon(
                              circleData['activityType'] as String? ?? ''),
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.h),

                  // Description
                  Text(
                    circleData['description'] as String? ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 1.5.h),

                  // Member Count and Activity Level
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'people',
                        color: colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${circleData['memberCount'] ?? 0} members',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getActivityLevelColor(
                              circleData['activityLevel'] as String? ?? ''),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          circleData['activityLevel'] as String? ?? '',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.5.h),

                  // Skill Tags
                  if (circleData['skills'] != null &&
                      (circleData['skills'] as List).isNotEmpty)
                    Wrap(
                      spacing: 1.w,
                      runSpacing: 0.5.h,
                      children:
                          (circleData['skills'] as List).take(3).map((skill) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            skill as String,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityTypeColor(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'sports':
        return AppTheme.success;
      case 'cultural':
        return AppTheme.secondary;
      case 'academic':
        return AppTheme.primary;
      case 'volunteer':
        return AppTheme.warning;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getActivityTypeIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'sports':
        return 'sports_soccer';
      case 'cultural':
        return 'palette';
      case 'academic':
        return 'school';
      case 'volunteer':
        return 'volunteer_activism';
      default:
        return 'group';
    }
  }

  Color _getActivityLevelColor(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'high':
        return AppTheme.error;
      case 'medium':
        return AppTheme.warning;
      case 'low':
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }
}
