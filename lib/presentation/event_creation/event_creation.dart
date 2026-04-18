import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/models/event_model.dart';
import './widgets/advanced_options_section.dart';
import './widgets/attendance_settings_section.dart';
import './widgets/date_time_section.dart';
import './widgets/event_basics_section.dart';
import './widgets/location_section.dart';
import './widgets/payment_section.dart';

class EventCreation extends ConsumerStatefulWidget {
  const EventCreation({super.key});

  @override
  ConsumerState<EventCreation> createState() => _EventCreationState();
}

class _EventCreationState extends ConsumerState<EventCreation> {
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
  String _visibility = 'public';
  List<CircleModel> _connectedCircles = [];
  final Set<String> _selectedAllowedCircleIds = {};
  bool _isSubmitting = false;

  // UI State
  bool _isDraftSaved = false;
  String? _circleId;
  List<CircleModel> _myAdminCircles = [];
  bool _isLoadingMyCircles = true;
  String? _loadedDraftKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_circleId != null) {
      return;
    }
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['circleId'] != null) {
      _circleId = args['circleId'] as String;
    }
    _ensureCircleContext();
  }

  @override
  void initState() {
    super.initState();
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
          onPressed: _saveDraft,
          child: Text(
            '下書き',
            style: TextStyle(
              color: AppTheme.lightTheme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
        ),
        TextButton(
          onPressed: (_isFormValid() && !_isSubmitting) ? _createEvent : null,
          child: Text(
            _isSubmitting ? '作成中...' : '作成',
            style: TextStyle(
              color: (_isFormValid() && !_isSubmitting)
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
                _buildOrganizerCircleSelector(),

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

                _buildVisibilitySection(),

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

  Future<void> _ensureCircleContext() async {
    final currentUser = ref.read(firebaseAuthServiceProvider).currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _myAdminCircles = [];
          _circleId = null;
          _isLoadingMyCircles = false;
          _connectedCircles = [];
          _selectedAllowedCircleIds.clear();
        });
      }
      return;
    }

    final circles = await ref
        .read(firestoreServiceProvider)
        .getMyCircles(currentUser.uid)
        .first;

    String? resolvedCircleId = _circleId;
    if (resolvedCircleId == null ||
        !circles.any((circle) => circle.id == resolvedCircleId)) {
      resolvedCircleId = circles.isNotEmpty ? circles.first.id : null;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _myAdminCircles = circles;
      _circleId = resolvedCircleId;
      _isLoadingMyCircles = false;
    });

    if (resolvedCircleId != null) {
      await _loadConnectedCircles(resolvedCircleId);
      await _loadDraft();
    } else {
      setState(() {
        _connectedCircles = [];
        _selectedAllowedCircleIds.clear();
      });
    }
  }

  Widget _buildOrganizerCircleSelector() {
    if (_isLoadingMyCircles) {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_myAdminCircles.isEmpty) {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        color: AppTheme.warning.withValues(alpha: 0.08),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  color: AppTheme.lightTheme.colorScheme.secondary),
              SizedBox(width: 2.w),
              const Expanded(
                child: Text('管理しているサークルがありません。先にサークルを作成してください。'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: DropdownButtonFormField<String>(
          value: _myAdminCircles.any((circle) => circle.id == _circleId)
              ? _circleId
              : null,
          decoration: const InputDecoration(
            labelText: '主催サークル *',
            border: OutlineInputBorder(),
          ),
          items: _myAdminCircles
              .map(
                (circle) => DropdownMenuItem<String>(
                  value: circle.id,
                  child: Text(circle.circleName),
                ),
              )
              .toList(),
          onChanged: (newId) async {
            if (newId == null || newId == _circleId) return;

            setState(() {
              _circleId = newId;
              _selectedAllowedCircleIds.clear();
              _connectedCircles = [];
            });

            await _loadConnectedCircles(newId);
            await _loadDraft();
            await _saveDraft();
          },
        ),
      ),
    );
  }

  Future<void> _loadConnectedCircles(String circleId) async {
    try {
      final service = ref.read(firestoreServiceProvider);
      final connections = await service.getApprovedConnections(circleId).first;
      final connectedCircleIds = connections
          .map(
              (c) => c.fromCircleId == circleId ? c.toCircleId : c.fromCircleId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final circles = await Future.wait(
        connectedCircleIds.map(service.getCircle),
      );

      if (mounted) {
        setState(() {
          _connectedCircles = circles.whereType<CircleModel>().toList();
          _selectedAllowedCircleIds
              .removeWhere((id) => !_connectedCircles.any((c) => c.id == id));
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _connectedCircles = [];
          _selectedAllowedCircleIds.clear();
        });
      }
    }
  }

  Widget _buildVisibilitySection() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '公開設定',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            RadioListTile<String>(
              title: const Text('公開'),
              subtitle: const Text('すべてのユーザーが参加依頼可能'),
              value: 'public',
              groupValue: _visibility,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _visibility = value;
                });
                _saveDraft();
              },
            ),
            RadioListTile<String>(
              title: const Text('非公開'),
              subtitle: const Text('選択したコネクション済みサークルのみ参加依頼可能'),
              value: 'private',
              groupValue: _visibility,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _visibility = value;
                });
                _saveDraft();
              },
            ),
            if (_visibility == 'private') ...[
              SizedBox(height: 1.h),
              if (_connectedCircles.isEmpty)
                const Text('コネクション済みサークルがありません。')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _connectedCircles
                      .map(
                        (circle) => FilterChip(
                          label: Text(circle.circleName),
                          selected:
                              _selectedAllowedCircleIds.contains(circle.id),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedAllowedCircleIds.add(circle.id);
                              } else {
                                _selectedAllowedCircleIds.remove(circle.id);
                              }
                            });
                            _saveDraft();
                          },
                        ),
                      )
                      .toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSmartSuggestions() {
    if (_selectedCategory.isEmpty) return SizedBox.shrink();

    final suggestions = _getSmartSuggestions();
    if (suggestions.isEmpty) return SizedBox.shrink();

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
    return _circleId != null &&
        _titleController.text.isNotEmpty &&
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

  String _draftStorageKey() =>
      'event_draft_${_circleId ?? ref.read(firebaseAuthServiceProvider).currentUser?.uid ?? 'default'}';

  Future<void> _loadDraft() async {
    final draftKey = _draftStorageKey();
    if (_loadedDraftKey == draftKey) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(draftKey);
    if (raw == null || raw.isEmpty) {
      _loadedDraftKey = draftKey;
      return;
    }

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _titleController.text = (data['title'] as String?) ?? '';
        _descriptionController.text = (data['description'] as String?) ?? '';
        _locationController.text = (data['location'] as String?) ?? '';
        _selectedCategory = (data['category'] as String?) ?? _selectedCategory;
        _selectedDates = ((data['selectedDates'] as List<dynamic>?) ?? const [])
            .map((e) => DateTime.parse(e.toString()))
            .toList();
        final start = data['startTime'] as String?;
        final end = data['endTime'] as String?;
        if (start != null && start.contains(':')) {
          final parts = start.split(':');
          _startTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 0,
              minute: int.tryParse(parts[1]) ?? 0);
        }
        if (end != null && end.contains(':')) {
          final parts = end.split(':');
          _endTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 0,
              minute: int.tryParse(parts[1]) ?? 0);
        }
        _visibility = (data['visibility'] as String?) ?? _visibility;
        _selectedAllowedCircleIds
          ..clear()
          ..addAll(((data['allowedCircleIds'] as List<dynamic>?) ?? const [])
              .map((e) => e.toString()));
        _costPerPerson = (data['costPerPerson'] as num?)?.toDouble();
        _paymentMethod = (data['paymentMethod'] as String?) ?? _paymentMethod;
        _payPayEnabled = (data['payPayEnabled'] as bool?) ?? _payPayEnabled;

        final savedCircleId = data['circleId'] as String?;
        if (savedCircleId != null &&
            _myAdminCircles.any((circle) => circle.id == savedCircleId)) {
          _circleId = savedCircleId;
        }
      });
    } catch (_) {
      // Keep creation flow usable even if draft format is stale.
    }

    _loadedDraftKey = draftKey;
  }

  void _setupAutoSave() {
    _titleController.addListener(_saveDraft);
    _descriptionController.addListener(_saveDraft);
    _locationController.addListener(_saveDraft);
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'category': _selectedCategory,
      'selectedDates': _selectedDates.map((d) => d.toIso8601String()).toList(),
      'startTime': _startTime == null
          ? null
          : '${_startTime!.hour}:${_startTime!.minute}',
      'endTime':
          _endTime == null ? null : '${_endTime!.hour}:${_endTime!.minute}',
      'visibility': _visibility,
      'allowedCircleIds': _selectedAllowedCircleIds.toList(),
      'circleId': _circleId,
      'costPerPerson': _costPerPerson,
      'paymentMethod': _paymentMethod,
      'payPayEnabled': _payPayEnabled,
      'savedAt': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_draftStorageKey(), jsonEncode(payload));

    if (!mounted) return;
    setState(() => _isDraftSaved = true);
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
            onPressed: () async {
              final navigator = Navigator.of(context);
              await _saveDraft();
              navigator.pop();
              navigator.pop();
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

            _buildPreviewRow(
              'visibility',
              '公開範囲',
              _visibility == 'public'
                  ? '公開（全ユーザー）'
                  : '非公開（${_selectedAllowedCircleIds.length}サークル）',
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
    if (_circleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Circle ID missing')));
      return;
    }
    if (_visibility == 'private' && _selectedAllowedCircleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('非公開イベントは公開先サークルを1つ以上選択してください')),
      );
      return;
    }

    try {
      setState(() => _isSubmitting = true);

      final firestoreService = ref.read(firestoreServiceProvider);

      final newEvent = EventModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        circleId: _circleId!,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory.isEmpty ? 'other' : _selectedCategory,
        startTime: _getDateWithTime(_selectedDates.first, _startTime!),
        endTime: _getDateWithTime(_selectedDates.first, _endTime!),
        location: _locationController.text,
        fee: _costPerPerson?.toInt() ?? 0,
        visibility: _visibility,
        allowedCircleIds: _visibility == 'public'
            ? const []
            : _selectedAllowedCircleIds.toList(),
        isDraft: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = FirebaseFirestore.instance
          .collection(FirestoreService.eventsCollection)
          .doc();
      final eventWithId = newEvent.copyWith(id: docRef.id);

      await firestoreService.createEvent(eventWithId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftStorageKey());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 2.w),
                const Text('イベントが作成されました！'),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Return to management screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('イベント作成に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  DateTime _getDateWithTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
