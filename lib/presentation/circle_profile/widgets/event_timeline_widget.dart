import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EventTimelineWidget extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final Function(Map<String, dynamic>) onEventTap;

  const EventTimelineWidget({
    super.key,
    required this.events,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(4.w),
      itemCount: events.length,
      separatorBuilder: (context, index) => SizedBox(height: 3.h),
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(context, event);
      },
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
    final isUpcoming =
        DateTime.parse(event["date"] as String).isAfter(DateTime.now());

    return GestureDetector(
      onTap: () => onEventTap(event),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            if (event["images"] != null && (event["images"] as List).isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    CustomImageWidget(
                      imageUrl: (event["images"] as List).first as String,
                      width: double.infinity,
                      height: 20.h,
                      fit: BoxFit.cover,
                    ),
                    // Status Badge
                    Positioned(
                      top: 3.w,
                      left: 3.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: isUpcoming
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isUpcoming ? "Upcoming" : "Past",
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: isUpcoming
                                ? Colors.white
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    // Photo Count
                    if (!isUpcoming && event["images"] != null)
                      Positioned(
                        top: 3.w,
                        right: 3.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'photo_library',
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                "${(event["images"] as List).length}",
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            // Event Details
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Time
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        _formatEventDate(event["date"] as String),
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (event["time"] != null)
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'access_time',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              event["time"] as String,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // Event Title
                  Text(
                    event["title"] as String,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  // Event Description
                  if (event["description"] != null)
                    Text(
                      event["description"] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 2.h),
                  // Event Stats
                  Row(
                    children: [
                      // Attendance
                      _buildStatChip(
                        CustomIconWidget(
                          iconName: 'people',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        "${event["attendeeCount"]} attending",
                      ),
                      SizedBox(width: 3.w),
                      // Location
                      if (event["location"] != null)
                        Expanded(
                          child: _buildStatChip(
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                            event["location"] as String,
                          ),
                        ),
                    ],
                  ),
                  // Payment Status (for upcoming events)
                  if (isUpcoming && event["cost"] != null) ...[
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'payments',
                            color: AppTheme.success,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            "Cost: ${event["cost"]}",
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: _getPaymentStatusColor(
                                  event["paymentStatus"] as String?),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event["paymentStatus"] as String? ?? "Pending",
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(Widget icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(width: 1.w),
        Flexible(
          child: Text(
            text,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatEventDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return "Today";
    } else if (difference == 1) {
      return "Tomorrow";
    } else if (difference == -1) {
      return "Yesterday";
    } else if (difference > 0 && difference <= 7) {
      return "In $difference days";
    } else if (difference < 0 && difference >= -7) {
      return "${difference.abs()} days ago";
    } else {
      return "${date.month}/${date.day}";
    }
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return AppTheme.success;
      case 'pending':
        return AppTheme.warning;
      case 'overdue':
        return AppTheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }
}
