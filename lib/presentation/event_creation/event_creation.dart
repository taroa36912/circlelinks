import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/advanced_options_section.dart';
import './widgets/attendance_settings_section.dart';
import './widgets/date_time_section.dart';
import './widgets/event_basics_section.dart';
import './widgets/location_section.dart';
import './widgets/payment_section.dart';

class EventCreation extends StatefulWidget {
  const EventCreation({super.key});

  @override
  State<EventCreation> createState() => _EventCreationState();
}

class _EventCreationState extends State<EventCreation> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  // Form State
  String _selectedCategory = '';
  List<DateTime> _selectedDates = [];
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  LatLng? _selectedLocation;
  DateTime? _rsvpDeadline;
  int? _capacityLimit;
  List<String> _attendanceOptions = ['attending', 'not_attending'];
  double? _costPerPerson;
  bool _payPayEnabled = false;
  String _paymentMethod = 'cash';
  bool _autoCreatePhotoAlbum = true;
  bool _enableCollaborationPosting = false;
  List<String> _notificationPreferences = ['event_created', 'rsvp_reminder'];
  bool _advancedOptionsExpanded = false;

  // UI State
  bool _isDraftSaved = false;

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _setupAutoSave();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => _showCancelDialog(),
        icon: CustomIconWidget(
          iconName: 'close',
          color: AppTheme.textPrimary,
          size: 24,
        ),
      ),
      title: Text(
        'イベント作成',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
      ),
      actions: [
        if (_isDraftSaved) ...[
          Container(
            margin: EdgeInsets.only(right: 2.w),
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'check',
                  color: AppTheme.success,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  '下書き保存済み',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
        TextButton(
          onPressed: _isFormValid() ? _createEvent : null,
          child: Text(
            '作成',
            style: TextStyle(
              color: _isFormValid()
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Progress Indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: LinearProgressIndicator(
            value: _getFormProgress(),
            backgroundColor: AppTheme.outline.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),

        // Form Content
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: 10.h),
              children: [
                // Event Basics
                EventBasicsSection(
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: (category) {
                    setState(() => _selectedCategory = category);
                    _saveDraft();
                  },
                ),

                // Date & Time
                DateTimeSection(
                  selectedDates: _selectedDates,
                  onDatesChanged: (dates) {
                    setState(() => _selectedDates = dates);
                    _saveDraft();
                  },
                  startTime: _startTime,
                  endTime: _endTime,
                  onStartTimeChanged: (time) {
                    setState(() => _startTime = time);
                    _saveDraft();
                  },
                  onEndTimeChanged: (time) {
                    setState(() => _endTime = time);
                    _saveDraft();
                  },
                ),

                // Location
                LocationSection(
                  locationController: _locationController,
                  selectedLocation: _selectedLocation,
                  onLocationChanged: (location) {
                    setState(() => _selectedLocation = location);
                    _saveDraft();
                  },
                ),

                // Attendance Settings
                AttendanceSettingsSection(
                  rsvpDeadline: _rsvpDeadline,
                  onRsvpDeadlineChanged: (deadline) {
                    setState(() => _rsvpDeadline = deadline);
                    _saveDraft();
                  },
                  capacityLimit: _capacityLimit,
                  onCapacityLimitChanged: (limit) {
                    setState(() => _capacityLimit = limit);
                    _saveDraft();
                  },
                  attendanceOptions: _attendanceOptions,
                  onAttendanceOptionsChanged: (options) {
                    setState(() => _attendanceOptions = options);
                    _saveDraft();
                  },
                ),

                // Payment
                PaymentSection(
                  costPerPerson: _costPerPerson,
                  onCostChanged: (cost) {
                    setState(() => _costPerPerson = cost);
                    _saveDraft();
                  },
                  payPayEnabled: _payPayEnabled,
                  onPayPayToggled: (enabled) {
                    setState(() => _payPayEnabled = enabled);
                    _saveDraft();
                  },
                  paymentMethod: _paymentMethod,
                  onPaymentMethodChanged: (method) {
                    setState(() => _paymentMethod = method);
                    _saveDraft();
                  },
                ),

                // Advanced Options
                AdvancedOptionsSection(
                  autoCreatePhotoAlbum: _autoCreatePhotoAlbum,
                  onAutoCreatePhotoAlbumChanged: (enabled) {
                    setState(() => _autoCreatePhotoAlbum = enabled);
                    _saveDraft();
                  },
                  enableCollaborationPosting: _enableCollaborationPosting,
                  onEnableCollaborationPostingChanged: (enabled) {
                    setState(() => _enableCollaborationPosting = enabled);
                    _saveDraft();
                  },
                  notificationPreferences: _notificationPreferences,
                  onNotificationPreferencesChanged: (preferences) {
                    setState(() => _notificationPreferences = preferences);
                    _saveDraft();
                  },
                  isExpanded: _advancedOptionsExpanded,
                  onExpandedChanged: (expanded) {
                    setState(() => _advancedOptionsExpanded = expanded);
                  },
                ),

                // Smart Suggestions
                _buildSmartSuggestions(),

                // Preview Button
                _buildPreviewButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartSuggestions() {
    if (_selectedCategory.isEmpty) return const SizedBox.shrink();

    final suggestions = _getSmartSuggestions();
    if (suggestions.isEmpty) return const SizedBox.shrink();

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
                  iconName: 'lightbulb',
                  color: AppTheme.warning,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'おすすめ設定',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ...suggestions.map((suggestion) => Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: suggestion['icon'],
                        color: AppTheme.warning,
                        size: 18,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion['title'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                            Text(
                              suggestion['description'],
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
                      TextButton(
                        onPressed: () => _applySuggestion(suggestion),
                        child: Text(
                          '適用',
                          style: TextStyle(
                            color: AppTheme.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: ElevatedButton.icon(
        onPressed: _isFormValid() ? _showPreview : null,
        icon: CustomIconWidget(
          iconName: 'preview',
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          'プレビュー',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  bool _isFormValid() {
    return _titleController.text.isNotEmpty &&
        _selectedCategory.isNotEmpty &&
        _selectedDates.isNotEmpty &&
        _startTime != null &&
        _endTime != null;
  }

  double _getFormProgress() {
    int completedSections = 0;
    const int totalSections = 6;

    // Event Basics
    if (_titleController.text.isNotEmpty && _selectedCategory.isNotEmpty) {
      completedSections++;
    }

    // Date & Time
    if (_selectedDates.isNotEmpty && _startTime != null && _endTime != null) {
      completedSections++;
    }

    // Location
    if (_locationController.text.isNotEmpty) {
      completedSections++;
    }

    // Attendance Settings
    if (_rsvpDeadline != null) {
      completedSections++;
    }

    // Payment
    if (_paymentMethod.isNotEmpty) {
      completedSections++;
    }

    // Advanced Options (always considered complete)
    completedSections++;

    return completedSections / totalSections;
  }

  List<Map<String, dynamic>> _getSmartSuggestions() {
    final suggestions = <Map<String, dynamic>>[];

    switch (_selectedCategory) {
      case 'social':
        if (_costPerPerson == null) {
          suggestions.add({
            'icon': 'restaurant',
            'title': '懇親会の費用設定',
            'description': '一般的に3000-5000円程度が適切です',
            'action': 'set_cost',
            'value': 4000.0,
          });
        }
        if (_paymentMethod == 'cash') {
          suggestions.add({
            'icon': 'qr_code',
            'title': 'PayPay決済の利用',
            'description': '事前決済で当日の集金を簡素化',
            'action': 'enable_paypay',
            'value': true,
          });
        }
        break;
      case 'practice':
        if (_selectedLocation == null) {
          suggestions.add({
            'icon': 'school',
            'title': '大学施設の利用',
            'description': '体育館や音楽室の予約をお忘れなく',
            'action': 'suggest_location',
            'value': '大学第1体育館',
          });
        }
        break;
      case 'competition':
        if (!_autoCreatePhotoAlbum) {
          suggestions.add({
            'icon': 'photo_camera',
            'title': '写真アルバム作成',
            'description': '大会の記録を自動で整理',
            'action': 'enable_photo_album',
            'value': true,
          });
        }
        break;
    }

    return suggestions;
  }

  void _applySuggestion(Map<String, dynamic> suggestion) {
    switch (suggestion['action']) {
      case 'set_cost':
        setState(() => _costPerPerson = suggestion['value']);
        break;
      case 'enable_paypay':
        setState(() {
          _paymentMethod = 'paypay';
          _payPayEnabled = true;
        });
        break;
      case 'suggest_location':
        _locationController.text = suggestion['value'];
        break;
      case 'enable_photo_album':
        setState(() => _autoCreatePhotoAlbum = true);
        break;
    }
    _saveDraft();
  }

  void _loadDraft() {
    // Simulate loading draft from local storage
    // In a real app, this would load from SharedPreferences or local database
  }

  void _setupAutoSave() {
    _titleController.addListener(_saveDraft);
    _descriptionController.addListener(_saveDraft);
    _locationController.addListener(_saveDraft);
  }

  void _saveDraft() {
    // Simulate saving draft to local storage
    setState(() => _isDraftSaved = true);

    // Reset the indicator after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isDraftSaved = false);
      }
    });
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('イベント作成をキャンセル'),
        content: const Text('入力した内容は下書きとして保存されます。よろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('続行'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _showPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'イベントプレビュー',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.textPrimary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: _buildEventPreview(),
              ),
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _createEvent();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'このイベントを作成',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventPreview() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Title and Category
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryName(_selectedCategory),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme
                              .lightTheme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              _titleController.text,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (_descriptionController.text.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                _descriptionController.text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            SizedBox(height: 3.h),

            // Date and Time
            _buildPreviewRow(
              'schedule',
              '日時',
              _selectedDates.isNotEmpty
                  ? '${_selectedDates.length}つの候補日 • ${_startTime?.format(context)} - ${_endTime?.format(context)}'
                  : '未設定',
            ),

            // Location
            if (_locationController.text.isNotEmpty)
              _buildPreviewRow('location_on', '場所', _locationController.text),

            // Cost
            if (_costPerPerson != null && _costPerPerson! > 0)
              _buildPreviewRow(
                  'yen', '費用', '¥${_costPerPerson!.toStringAsFixed(0)} / 人'),

            // RSVP Deadline
            if (_rsvpDeadline != null)
              _buildPreviewRow(
                'event_available',
                'RSVP締切',
                '${_rsvpDeadline!.year}年${_rsvpDeadline!.month}月${_rsvpDeadline!.day}日',
              ),

            // Capacity
            if (_capacityLimit != null)
              _buildPreviewRow('people', '定員', '$_capacityLimit人'),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String iconName, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String categoryId) {
    const categoryNames = {
      'social': '懇親会',
      'meeting': '会議',
      'practice': '練習',
      'performance': '発表',
      'competition': '大会',
      'workshop': 'ワークショップ',
      'volunteer': 'ボランティア',
      'other': 'その他',
    };
    return categoryNames[categoryId] ?? categoryId;
  }

  Future<void> _createEvent() async {
    if (!_isFormValid()) return;

    try {
      // Simulate API call to create event
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 2.w),
              const Text('イベントが作成されました！'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigate to event details
      Navigator.pushReplacementNamed(context, '/event-details');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'error',
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 2.w),
              const Text('エラーが発生しました。もう一度お試しください。'),
            ],
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
    }
  }
}
