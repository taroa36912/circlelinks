import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProjectOpportunitiesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> projects;
  final Function(Map<String, dynamic>) onProjectTap;
  final Function(Map<String, dynamic>) onApplyPressed;

  const ProjectOpportunitiesWidget({
    super.key,
    required this.projects,
    required this.onProjectTap,
    required this.onApplyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(4.w),
      itemCount: projects.length,
      separatorBuilder: (context, index) => SizedBox(height: 3.h),
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(context, project);
      },
    );
  }

  Widget _buildProjectCard(BuildContext context, Map<String, dynamic> project) {
    return GestureDetector(
      onTap: () => onProjectTap(project),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow
                  .withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Icon
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: _getProjectTypeColor(project["type"] as String),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: _getProjectTypeIcon(project["type"] as String),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  // Project Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project["title"] as String,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          project["partnerCircle"] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(project["status"] as String),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      project["status"] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              // Project Description
              Text(
                project["description"] as String,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              // Required Skills
              if (project["requiredSkills"] != null) ...[
                Text(
                  "Required Skills:",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: ((project["requiredSkills"] as List).take(4))
                      .map((skill) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color:
                            AppTheme.lightTheme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        skill as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme
                              .lightTheme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 2.h),
              ],
              // Project Details
              Row(
                children: [
                  _buildDetailChip(
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    project["duration"] as String,
                  ),
                  SizedBox(width: 3.w),
                  _buildDetailChip(
                    CustomIconWidget(
                      iconName: 'people',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    "${project["teamSize"]} members",
                  ),
                  const Spacer(),
                  if (project["deadline"] != null)
                    Text(
                      "Due: ${_formatDeadline(project["deadline"] as String)}",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 3.h),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onProjectTap(project),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "View Details",
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          (project["status"] as String).toLowerCase() == "open"
                              ? () => onApplyPressed(project)
                              : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _getApplyButtonText(project["status"] as String),
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildDetailChip(Widget icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(width: 1.w),
        Text(
          text,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getProjectTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'design':
        return AppTheme.secondary;
      case 'marketing':
        return AppTheme.warning;
      case 'development':
        return AppTheme.success;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getProjectTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return 'event';
      case 'design':
        return 'palette';
      case 'marketing':
        return 'campaign';
      case 'development':
        return 'code';
      default:
        return 'work';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return AppTheme.success;
      case 'in progress':
        return AppTheme.warning;
      case 'closed':
        return AppTheme.lightTheme.colorScheme.outline;
      case 'completed':
        return AppTheme.lightTheme.colorScheme.primary;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getApplyButtonText(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return "Apply Now";
      case 'in progress':
        return "In Progress";
      case 'closed':
        return "Closed";
      case 'completed':
        return "Completed";
      default:
        return "Apply";
    }
  }

  String _formatDeadline(String dateString) {
    final deadline = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;

    if (difference == 0) {
      return "Today";
    } else if (difference == 1) {
      return "Tomorrow";
    } else if (difference > 0) {
      return "${difference}d left";
    } else {
      return "Overdue";
    }
  }
}
