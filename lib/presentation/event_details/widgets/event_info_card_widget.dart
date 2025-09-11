import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EventInfoCardWidget extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EventInfoCardWidget({
    super.key,
    required this.eventData,
  });

  @override
  State<EventInfoCardWidget> createState() => _EventInfoCardWidgetState();
}

class _EventInfoCardWidgetState extends State<EventInfoCardWidget> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateTimeSection(),
            SizedBox(height: 3.h),
            _buildLocationSection(),
            SizedBox(height: 3.h),
            _buildDescriptionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.eventData['date'] as String? ?? 'December 15, 2024',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              SizedBox(height: 0.5.h),
              Text(
                widget.eventData['time'] as String? ?? '18:00 - 22:00',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () => _addToCalendar(),
          icon: CustomIconWidget(
            iconName: 'add',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 16,
          ),
          label: Text(
            'Add to Calendar',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'location_on',
              color: AppTheme.lightTheme.colorScheme.onTertiaryContainer,
              size: 20,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.eventData['location'] as String? ?? 'Shibuya Sky Lounge',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              SizedBox(height: 0.5.h),
              Text(
                widget.eventData['address'] as String? ?? 'Shibuya, Tokyo',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () => _openDirections(),
          icon: CustomIconWidget(
            iconName: 'directions',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 16,
          ),
          label: Text(
            'Directions',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    final description = widget.eventData['description'] as String? ??
        'Join us for an amazing evening of networking, delicious food, and great company. This event is perfect for meeting new people and strengthening existing relationships within our circle community.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'description',
                  color: AppTheme.lightTheme.colorScheme.onSecondaryContainer,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'Description',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
          ],
        ),
        SizedBox(height: 2.h),
        AnimatedCrossFade(
          firstChild: Text(
            description,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            description,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          crossFadeState: _isDescriptionExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        if (description.length > 150) ...[
          SizedBox(height: 1.h),
          GestureDetector(
            onTap: () => setState(
                () => _isDescriptionExpanded = !_isDescriptionExpanded),
            child: Text(
              _isDescriptionExpanded ? 'Show less' : 'Show more',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _addToCalendar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event added to calendar'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openDirections() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening directions...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
