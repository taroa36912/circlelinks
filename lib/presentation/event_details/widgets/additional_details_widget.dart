import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdditionalDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final List<Map<String, dynamic>> photos;
  final List<Map<String, dynamic>> expenses;

  const AdditionalDetailsWidget({
    super.key,
    required this.eventData,
    required this.photos,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPhotoAlbumSection(),
        SizedBox(height: 2.h),
        _buildExpenseBreakdownSection(),
        SizedBox(height: 2.h),
        _buildOrganizerContactSection(),
      ],
    );
  }

  Widget _buildPhotoAlbumSection() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'photo_library',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Shared Photos',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _viewAllPhotos(),
                  child: Text('View All (${photos.length})'),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            photos.isEmpty ? _buildEmptyPhotoState() : _buildPhotoGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPhotoState() {
    return Container(
      height: 20.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'add_a_photo',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(
              'No photos yet',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 0.5.h),
            TextButton(
              onPressed: () => _addPhotos(),
              child: Text('Add Photos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    final displayPhotos = photos.take(6).toList();

    return SizedBox(
      height: 20.h,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2.w,
          mainAxisSpacing: 1.h,
          childAspectRatio: 1,
        ),
        itemCount: displayPhotos.length > 5 ? 6 : displayPhotos.length,
        itemBuilder: (context, index) {
          if (index == 5 && photos.length > 6) {
            return _buildMorePhotosIndicator();
          }
          return _buildPhotoThumbnail(displayPhotos[index]);
        },
      ),
    );
  }

  Widget _buildPhotoThumbnail(Map<String, dynamic> photo) {
    return GestureDetector(
      onTap: () => _viewPhoto(photo),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomImageWidget(
          imageUrl: photo['url'] as String? ?? '',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMorePhotosIndicator() {
    final remainingCount = photos.length - 5;

    return GestureDetector(
      onTap: () => _viewAllPhotos(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '+$remainingCount',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseBreakdownSection() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'receipt_long',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Expense Breakdown',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '¥3,500 per person',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            ...expenses.map((expense) => _buildExpenseItem(expense)),
            Divider(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '¥${_calculateTotal()}',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(Map<String, dynamic> expense) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: expense['icon'] as String? ?? 'receipt',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              expense['name'] as String? ?? 'Expense',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
          Text(
            '¥${expense['amount']}',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizerContactSection() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'person',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Organizer',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      imageUrl: eventData['organizerAvatar'] as String? ?? '',
                      width: 15.w,
                      height: 15.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventData['organizerName'] as String? ??
                            'Event Organizer',
                        style: AppTheme.lightTheme.textTheme.titleMedium,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        eventData['organizerRole'] as String? ??
                            'Circle Leader',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _contactOrganizer('message'),
                      icon: CustomIconWidget(
                        iconName: 'message',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _contactOrganizer('call'),
                      icon: CustomIconWidget(
                        iconName: 'phone',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTotal() {
    int total = 0;
    for (final expense in expenses) {
      total += (expense['amount'] as int? ?? 0);
    }
    return total.toString();
  }

  void _viewAllPhotos() {
    // Navigate to photo gallery screen
    // Note: This method needs BuildContext to show SnackBar
    // Implementation should be handled by parent widget
  }

  void _viewPhoto(Map<String, dynamic> photo) {
    // Show photo in full screen
    // Note: This method needs BuildContext to show SnackBar
    // Implementation should be handled by parent widget
  }

  void _addPhotos() {
    // Open photo picker
    // Note: This method needs BuildContext to show SnackBar
    // Implementation should be handled by parent widget
  }

  void _contactOrganizer(String method) {
    // Note: This method needs BuildContext to show SnackBar
    // Implementation should be handled by parent widget
  }
}