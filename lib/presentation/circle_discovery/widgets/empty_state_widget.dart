import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const EmptyStateWidget({
    super.key,
    this.title = 'No circles found',
    this.description =
        'Try adjusting your filters or search terms to find more circles.',
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20.w),
                ),
                child: CustomIconWidget(
                  iconName: 'search_off',
                  color: colorScheme.onSurfaceVariant,
                  size: 20.w,
                ),
              ),

              SizedBox(height: 4.h),

              // Title
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 2.h),

              // Description
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              if (actionText != null && onActionPressed != null) ...[
                SizedBox(height: 4.h),
                ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  ),
                  child: Text(actionText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
