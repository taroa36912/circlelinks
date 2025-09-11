import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import './achievement_card_widget.dart';

class PortfolioSectionWidget extends StatefulWidget {
  final String title;
  final String icon;
  final Color color;
  final List<Map<String, dynamic>> items;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final Function(Map<String, dynamic>) onItemTap;
  final Function(Map<String, dynamic>) onItemShare;
  final Function(Map<String, dynamic>) onRequestVerification;
  final VoidCallback onAddNew;

  const PortfolioSectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onItemTap,
    required this.onItemShare,
    required this.onRequestVerification,
    required this.onAddNew,
  });

  @override
  State<PortfolioSectionWidget> createState() => _PortfolioSectionWidgetState();
}

class _PortfolioSectionWidgetState extends State<PortfolioSectionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(PortfolioSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      widget.isExpanded
          ? _animationController.forward()
          : _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
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
        children: [
          _buildSectionHeader(context),
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value,
                  child: child,
                ),
              );
            },
            child: _buildSectionContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: widget.onToggleExpanded,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.05),
          borderRadius: widget.isExpanded
              ? BorderRadius.vertical(top: Radius.circular(4.w))
              : BorderRadius.circular(4.w),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: CustomIconWidget(
                iconName: widget.icon,
                color: widget.color,
                size: 6.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${widget.items.length} items',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: widget.onAddNew,
              icon: CustomIconWidget(
                iconName: 'add',
                color: widget.color,
                size: 5.w,
              ),
              style: IconButton.styleFrom(
                backgroundColor: widget.color.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            AnimatedRotation(
              turns: widget.isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: CustomIconWidget(
                iconName: 'keyboard_arrow_down',
                color: colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context) {
    if (widget.items.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: widget.items.map((item) {
          return AchievementCardWidget(
            achievement: item,
            onTap: () => widget.onItemTap(item),
            onShare: () => widget.onItemShare(item),
            onRequestVerification: () => widget.onRequestVerification(item),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: CustomIconWidget(
              iconName: widget.icon,
              color: widget.color.withValues(alpha: 0.5),
              size: 12.w,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'No ${widget.title.toLowerCase()} yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add your first ${widget.title.toLowerCase().substring(0, widget.title.length - 1)} to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ElevatedButton.icon(
            onPressed: widget.onAddNew,
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 4.w,
            ),
            label: Text(
                'Add ${widget.title.substring(0, widget.title.length - 1)}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
