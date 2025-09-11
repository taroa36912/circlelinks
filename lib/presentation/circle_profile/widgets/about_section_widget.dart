import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AboutSectionWidget extends StatelessWidget {
  final Map<String, dynamic> circleData;

  const AboutSectionWidget({
    super.key,
    required this.circleData,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description Section
          _buildSectionHeader("About Us", Icons.info_outline),
          SizedBox(height: 2.h),
          Text(
            circleData["description"] as String,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
          SizedBox(height: 4.h),

          // Meeting Schedule Section
          _buildSectionHeader("Meeting Schedule", Icons.schedule),
          SizedBox(height: 2.h),
          _buildScheduleCard(),
          SizedBox(height: 4.h),

          // Requirements Section
          _buildSectionHeader("Membership Requirements", Icons.checklist),
          SizedBox(height: 2.h),
          _buildRequirementsCard(),
          SizedBox(height: 4.h),

          // Activities Section
          _buildSectionHeader("Main Activities", Icons.sports_soccer),
          SizedBox(height: 2.h),
          _buildActivitiesGrid(),
          SizedBox(height: 4.h),

          // Contact Information
          _buildSectionHeader("Contact Information", Icons.contact_mail),
          SizedBox(height: 2.h),
          _buildContactCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon.toString().split('.').last,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        ),
        SizedBox(width: 2.w),
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard() {
    final schedule = circleData["schedule"] as Map<String, dynamic>? ?? {};

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'event',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                "Regular Meetings",
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildScheduleItem(
              "Day", schedule["day"] as String? ?? "Every Tuesday"),
          SizedBox(height: 1.h),
          _buildScheduleItem(
              "Time", schedule["time"] as String? ?? "18:00 - 20:00"),
          SizedBox(height: 1.h),
          _buildScheduleItem("Location",
              schedule["location"] as String? ?? "Student Center Room 201"),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20.w,
          child: Text(
            "$label:",
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsCard() {
    final requirements = circleData["requirements"] as List? ??
        [
          "Open to all university students",
          "Regular attendance at meetings",
          "Participation in circle events",
          "Monthly membership fee: ¥2,000"
        ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: requirements.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: entry.key < requirements.length - 1 ? 2.h : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: EdgeInsets.only(top: 1.h, right: 3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivitiesGrid() {
    final activities = circleData["activities"] as List? ??
        [
          {"name": "Weekly Practice", "icon": "sports_soccer"},
          {"name": "Tournament", "icon": "emoji_events"},
          {"name": "Social Events", "icon": "celebration"},
          {"name": "Training Camp", "icon": "nature"},
        ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 2.5,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index] as Map<String, dynamic>;
        return Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: activity["icon"] as String,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  activity["name"] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactCard() {
    final contact = circleData["contact"] as Map<String, dynamic>? ?? {};

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildContactItem(
            CustomIconWidget(
              iconName: 'email',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            "Email",
            contact["email"] as String? ?? "contact@circlelink.jp",
          ),
          SizedBox(height: 2.h),
          _buildContactItem(
            CustomIconWidget(
              iconName: 'phone',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            "Phone",
            contact["phone"] as String? ?? "+81-90-1234-5678",
          ),
          SizedBox(height: 2.h),
          _buildContactItem(
            CustomIconWidget(
              iconName: 'language',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            "Website",
            contact["website"] as String? ?? "www.circlelink.jp",
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(Widget icon, String label, String value) {
    return Row(
      children: [
        icon,
        SizedBox(width: 3.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
