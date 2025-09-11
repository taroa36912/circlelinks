import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CircleHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> circleData;
  final bool isMember;
  final VoidCallback onJoinPressed;
  final VoidCallback onFollowPressed;
  final VoidCallback onSharePressed;

  const CircleHeaderWidget({
    super.key,
    required this.circleData,
    required this.isMember,
    required this.onJoinPressed,
    required this.onFollowPressed,
    required this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 35.h,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomIconWidget(
            iconName: 'arrow_back_ios_new',
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: onSharePressed,
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomIconWidget(
              iconName: 'share',
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        SizedBox(width: 2.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover Image
            CustomImageWidget(
              imageUrl: circleData["coverImage"] as String,
              width: double.infinity,
              height: 35.h,
              fit: BoxFit.cover,
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Content Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Circle Name
                    Text(
                      circleData["name"] as String,
                      style: AppTheme.lightTheme.textTheme.headlineMedium
                          ?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    // University Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        circleData["university"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Stats Row
                    Row(
                      children: [
                        _buildStatItem(
                          CustomIconWidget(
                            iconName: 'people',
                            color: Colors.white,
                            size: 16,
                          ),
                          "${circleData["memberCount"]} members",
                        ),
                        SizedBox(width: 4.w),
                        _buildStatItem(
                          CustomIconWidget(
                            iconName: 'category',
                            color: Colors.white,
                            size: 16,
                          ),
                          circleData["activityType"] as String,
                        ),
                        SizedBox(width: 4.w),
                        _buildStatItem(
                          CustomIconWidget(
                            iconName: 'calendar_today',
                            color: Colors.white,
                            size: 16,
                          ),
                          "Est. ${circleData["establishedYear"]}",
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: isMember ? null : onJoinPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isMember
                                  ? AppTheme
                                      .lightTheme.colorScheme.surfaceContainerHighest
                                  : AppTheme.lightTheme.colorScheme.primary,
                              foregroundColor: isMember
                                  ? AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant
                                  : Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              isMember ? "Member" : "Join Circle",
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: isMember
                                    ? AppTheme
                                        .lightTheme.colorScheme.onSurfaceVariant
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton(
                            onPressed: onFollowPressed,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Colors.white, width: 1.5),
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Follow",
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(Widget icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(width: 1.w),
        Text(
          text,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
