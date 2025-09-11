import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MemberGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  final Function(Map<String, dynamic>) onMemberTap;

  const MemberGridWidget({
    super.key,
    required this.members,
    required this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 3.w,
        childAspectRatio: 0.85,
      ),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return _buildMemberCard(context, member);
      },
    );
  }

  Widget _buildMemberCard(BuildContext context, Map<String, dynamic> member) {
    return GestureDetector(
      onTap: () => onMemberTap(member),
      onLongPress: () => _showContactOptions(context, member),
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
          children: [
            // Profile Image
            Container(
              margin: EdgeInsets.all(3.w),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomImageWidget(
                      imageUrl: member["profileImage"] as String,
                      width: double.infinity,
                      height: 15.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Role Badge
                  if (member["role"] != null &&
                      (member["role"] as String).isNotEmpty)
                    Positioned(
                      top: 2.w,
                      right: 2.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getRoleColor(member["role"] as String),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          member["role"] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Member Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      member["name"] as String,
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    // Year
                    Text(
                      "${member["year"]}年生",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Skills
                    if (member["skills"] != null)
                      Expanded(
                        child: Wrap(
                          spacing: 1.w,
                          runSpacing: 0.5.h,
                          children:
                              ((member["skills"] as List).take(3)).map((skill) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.3.h),
                              decoration: BoxDecoration(
                                color: AppTheme
                                    .lightTheme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                skill as String,
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme
                                      .onPrimaryContainer,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'leader':
      case 'リーダー':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'treasurer':
      case '会計':
        return AppTheme.success;
      case 'pr':
      case '広報':
        return AppTheme.secondary;
      case 'designer':
      case 'デザイナー':
        return AppTheme.warning;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  void _showContactOptions(BuildContext context, Map<String, dynamic> member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomImageWidget(
                          imageUrl: member["profileImage"] as String,
                          width: 12.w,
                          height: 12.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member["name"] as String,
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              member["role"] as String? ?? "",
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactButton(
                          context,
                          CustomIconWidget(
                            iconName: 'message',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                          "Message",
                          () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildContactButton(
                          context,
                          CustomIconWidget(
                            iconName: 'email',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                          "Email",
                          () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildContactButton(
                          context,
                          CustomIconWidget(
                            iconName: 'person_add',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                          "Connect",
                          () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(
      BuildContext context, Widget icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            icon,
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
