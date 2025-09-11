import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdvancedOptionsSection extends StatefulWidget {
  final bool autoCreatePhotoAlbum;
  final Function(bool) onAutoCreatePhotoAlbumChanged;
  final bool enableCollaborationPosting;
  final Function(bool) onEnableCollaborationPostingChanged;
  final List<String> notificationPreferences;
  final Function(List<String>) onNotificationPreferencesChanged;
  final bool isExpanded;
  final Function(bool) onExpandedChanged;

  const AdvancedOptionsSection({
    super.key,
    required this.autoCreatePhotoAlbum,
    required this.onAutoCreatePhotoAlbumChanged,
    required this.enableCollaborationPosting,
    required this.onEnableCollaborationPostingChanged,
    required this.notificationPreferences,
    required this.onNotificationPreferencesChanged,
    required this.isExpanded,
    required this.onExpandedChanged,
  });

  @override
  State<AdvancedOptionsSection> createState() => _AdvancedOptionsSectionState();
}

class _AdvancedOptionsSectionState extends State<AdvancedOptionsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  final List<Map<String, dynamic>> notificationOptions = [
    {
      'id': 'event_created',
      'name': 'イベント作成通知',
      'description': 'イベントが作成されたときに通知',
      'icon': 'event',
    },
    {
      'id': 'rsvp_reminder',
      'name': 'RSVP締切リマインダー',
      'description': 'RSVP締切の24時間前に通知',
      'icon': 'schedule',
    },
    {
      'id': 'event_reminder',
      'name': 'イベント開始リマインダー',
      'description': 'イベント開始の1時間前に通知',
      'icon': 'alarm',
    },
    {
      'id': 'payment_reminder',
      'name': '支払いリマインダー',
      'description': '未払いメンバーへの支払い催促',
      'icon': 'payment',
    },
    {
      'id': 'photo_upload',
      'name': '写真アップロード通知',
      'description': '新しい写真がアップロードされたときに通知',
      'icon': 'photo_camera',
    },
  ];

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
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          // Header with expand/collapse button
          GestureDetector(
            onTap: () {
              final newExpanded = !widget.isExpanded;
              widget.onExpandedChanged(newExpanded);

              if (newExpanded) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'tune',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '詳細オプション',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: widget.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: CustomIconWidget(
                      iconName: 'expand_more',
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
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
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: AppTheme.outline.withValues(alpha: 0.3),
                    height: 1,
                  ),
                  SizedBox(height: 3.h),

                  // Photo Album Auto-Creation
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: widget.autoCreatePhotoAlbum
                          ? AppTheme.lightTheme.colorScheme.primaryContainer
                              .withValues(alpha: 0.3)
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.autoCreatePhotoAlbum
                            ? AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3)
                            : AppTheme.outline,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: widget.autoCreatePhotoAlbum
                                ? AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1)
                                : AppTheme.outline.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'photo_library',
                            color: widget.autoCreatePhotoAlbum
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.textSecondary,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '写真アルバム自動作成',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                              Text(
                                'イベント終了後に共有写真アルバムを自動作成',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: widget.autoCreatePhotoAlbum,
                          onChanged: widget.onAutoCreatePhotoAlbumChanged,
                          activeColor: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Collaboration Posting
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: widget.enableCollaborationPosting
                          ? AppTheme.lightTheme.colorScheme.secondaryContainer
                              .withValues(alpha: 0.3)
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.enableCollaborationPosting
                            ? AppTheme.lightTheme.colorScheme.secondary
                                .withValues(alpha: 0.3)
                            : AppTheme.outline,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: widget.enableCollaborationPosting
                                ? AppTheme.lightTheme.colorScheme.secondary
                                    .withValues(alpha: 0.1)
                                : AppTheme.outline.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'handshake',
                            color: widget.enableCollaborationPosting
                                ? AppTheme.lightTheme.colorScheme.secondary
                                : AppTheme.textSecondary,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'コラボレーション投稿',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                              Text(
                                '他サークルとの合同イベントとして掲示板に投稿',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: widget.enableCollaborationPosting,
                          onChanged: widget.onEnableCollaborationPostingChanged,
                          activeColor:
                              AppTheme.lightTheme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Notification Preferences
                  Text(
                    '通知設定',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  SizedBox(height: 1.h),

                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.tertiaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.tertiary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'info',
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              size: 18,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'メンバーに送信する通知を選択',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.tertiary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '選択した通知のみがメンバーに送信されます',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Notification Options List
                  Column(
                    children: notificationOptions.map((option) {
                      final isSelected =
                          widget.notificationPreferences.contains(option['id']);

                      return Container(
                        margin: EdgeInsets.only(bottom: 1.h),
                        child: GestureDetector(
                          onTap: () => _toggleNotificationOption(option['id']),
                          child: Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.success.withValues(alpha: 0.1)
                                  : AppTheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.success
                                    : AppTheme.outline,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: option['icon'],
                                  color: isSelected
                                      ? AppTheme.success
                                      : AppTheme.textSecondary,
                                  size: 20,
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option['name'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: isSelected
                                                  ? AppTheme.textPrimary
                                                  : AppTheme.textSecondary,
                                            ),
                                      ),
                                      Text(
                                        option['description'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                CustomIconWidget(
                                  iconName: isSelected
                                      ? 'check_box'
                                      : 'check_box_outline_blank',
                                  color: isSelected
                                      ? AppTheme.success
                                      : AppTheme.textSecondary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Selected Notifications Summary
                  if (widget.notificationPreferences.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '有効な通知 (${widget.notificationPreferences.length})',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.success,
                                    ),
                          ),
                          SizedBox(height: 1.h),
                          Wrap(
                            spacing: 1.w,
                            runSpacing: 0.5.h,
                            children:
                                widget.notificationPreferences.map((optionId) {
                              final option = notificationOptions.firstWhere(
                                (opt) => opt['id'] == optionId,
                              );
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.success.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  option['name'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.success,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleNotificationOption(String optionId) {
    final updatedPreferences =
        List<String>.from(widget.notificationPreferences);
    if (updatedPreferences.contains(optionId)) {
      updatedPreferences.remove(optionId);
    } else {
      updatedPreferences.add(optionId);
    }
    widget.onNotificationPreferencesChanged(updatedPreferences);
  }
}
