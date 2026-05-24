import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/user_model.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_tab_bar.dart';
import './widgets/export_options_widget.dart';
import './widgets/portfolio_header_widget.dart';
import './widgets/portfolio_section_widget.dart';
import './widgets/skills_endorsement_widget.dart';

final portfolioUserProvider =
    StreamProvider.autoDispose.family<UserModel?, String>((ref, userId) {
  return ref.watch(firestoreServiceProvider).getUserStream(userId);
});

class PortfolioBuilder extends ConsumerStatefulWidget {
  const PortfolioBuilder({super.key});

  @override
  ConsumerState<PortfolioBuilder> createState() => _PortfolioBuilderState();
}

class _PortfolioBuilderState extends ConsumerState<PortfolioBuilder>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _activeTabIndex = 0;

  final Map<String, bool> _expandedSections = {
    'leadership': true,
    'events': false,
    'projects': false,
    'skills': false,
  };

  // Mock data for portfolio
  final Map<String, dynamic> _portfolioData = {
    'userName': 'Takeshi Yamamoto',
    'university': 'Tokyo University',
    'major': 'Computer Science',
    'completionPercentage': 75.0,
    'leadership': [
      {
        'id': '1',
        'title': 'Circle President',
        'organization': 'Programming Circle',
        'description':
            'Led a team of 25 members in organizing coding workshops and hackathons. Increased membership by 40% and secured sponsorship from 3 tech companies.',
        'category': 'leadership',
        'date': '2024-04-01',
        'duration': '8 months',
        'impactScore': 9,
        'isVerified': true,
      },
      {
        'id': '2',
        'title': 'Event Coordinator',
        'organization': 'Student Council',
        'description':
            'Coordinated university-wide cultural festival with over 2000 attendees. Managed budget of ¥500,000 and collaborated with 15 different circles.',
        'category': 'leadership',
        'date': '2023-10-15',
        'duration': '3 months',
        'impactScore': 8,
        'isVerified': true,
      },
    ],
    'events': [
      {
        'id': '3',
        'title': 'Tech Conference 2024',
        'organization': 'Programming Circle',
        'description':
            'Organized annual tech conference with 200+ participants. Featured 8 industry speakers and 12 student presentations.',
        'category': 'event',
        'date': '2024-03-15',
        'duration': '1 day',
        'impactScore': 9,
        'isVerified': true,
      },
      {
        'id': '4',
        'title': 'Coding Bootcamp',
        'organization': 'Programming Circle',
        'description':
            'Conducted 5-day intensive coding bootcamp for beginners. Taught Flutter development to 30 students with 95% completion rate.',
        'category': 'event',
        'date': '2024-01-20',
        'duration': '5 days',
        'impactScore': 7,
        'isVerified': false,
      },
    ],
    'projects': [
      {
        'id': '5',
        'title': 'CircleLink Mobile App',
        'organization': 'Programming Circle',
        'description':
            'Developed comprehensive Flutter application for university circle management. Features include event scheduling, payment tracking, and portfolio building.',
        'category': 'project',
        'date': '2024-02-01',
        'duration': '6 months',
        'impactScore': 10,
        'isVerified': false,
      },
      {
        'id': '6',
        'title': 'AI Study Assistant',
        'organization': 'AI Research Lab',
        'description':
            'Built machine learning model to help students with exam preparation. Achieved 85% accuracy in predicting study patterns.',
        'category': 'project',
        'date': '2023-11-01',
        'duration': '4 months',
        'impactScore': 8,
        'isVerified': true,
      },
    ],
    'skills': [
      {
        'name': 'Flutter Development',
        'category': 'Technical',
        'endorsements': 12,
      },
      {
        'name': 'Leadership',
        'category': 'Leadership',
        'endorsements': 8,
      },
      {
        'name': 'Project Management',
        'category': 'Leadership',
        'endorsements': 6,
      },
      {
        'name': 'UI/UX Design',
        'category': 'Creative',
        'endorsements': 5,
      },
      {
        'name': 'Public Speaking',
        'category': 'Communication',
        'endorsements': 7,
      },
      {
        'name': 'Machine Learning',
        'category': 'Technical',
        'endorsements': 4,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final firebaseUser = ref.watch(firebaseAuthServiceProvider).currentUser;

    if (firebaseUser == null) {
      return Scaffold(
        backgroundColor: colorScheme.surfaceContainerHighest,
        body: const Center(child: Text('ログインが必要です')),
      );
    }

    final userAsync = ref.watch(portfolioUserProvider(firebaseUser.uid));

    return userAsync.when(
      loading: () => Scaffold(
        backgroundColor: colorScheme.surfaceContainerHighest,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: colorScheme.surfaceContainerHighest,
        body: Center(child: Text('ユーザー情報を取得できませんでした: $error')),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: colorScheme.surfaceContainerHighest,
            body: const Center(child: Text('ユーザー情報が見つかりません')),
          );
        }

        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerHighest,
          // 👇 ここを Column から NestedScrollView に変更しました
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: PortfolioHeaderWidget(
                    userName: user.userName,
                    university:
                        user.university ?? _portfolioData['university'] as String,
                    major: user.major ?? _portfolioData['major'] as String,
                    profileImageUrl: user.profileImageUrl,
                    completionPercentage:
                        _portfolioData['completionPercentage'] as double,
                    onEditProfile: () => _showEditProfileDialog(user),
                    onClose: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.myPage, (_) => false);
                      }
                    },
                  ),
                ),
              ];
            },
            body: CustomTabBar(
              tabs: const ['Portfolio', 'Skills'],
              tabViews: [
                _buildPortfolioTab(user),
                _buildSkillsTab(user),
              ],
              variant: CustomTabBarVariant.pills,
              onTabChanged: (index) {
                // Handle tab change if needed
                setState(() {
                  _activeTabIndex = index;
                });
              },
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showExportOptions,
            icon: CustomIconWidget(
              iconName: 'download',
              color: Colors.white,
              size: 5.w,
            ),
            label: const Text('Export'),
            backgroundColor: colorScheme.primary,
          ),
        );
      },
    );
  }

  Widget _buildPortfolioTab(UserModel user) {
    final leadership = _achievementItems(user, 'leadership');
    final events = _achievementItems(user, 'events');
    final projects = _achievementItems(user, 'projects');

    return RefreshIndicator(
      onRefresh: _refreshPortfolio,
      child: SingleChildScrollView(
        primary: _activeTabIndex == 0,
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            _buildCustomMenuSection(user),
            SizedBox(height: 2.h),
            PortfolioSectionWidget(
              title: 'Leadership Roles',
              icon: 'groups',
              color: AppTheme.primary,
              items: leadership,
              isExpanded: _expandedSections['leadership'] ?? false,
              onToggleExpanded: () => _toggleSection('leadership'),
              onItemTap: (achievement) =>
                  _editAchievement(user, 'leadership', achievement),
              onItemShare: _shareAchievement,
              onRequestVerification: _requestVerification,
              onAddNew: () => _addNewAchievement(user, 'leadership'),
            ),
            PortfolioSectionWidget(
              title: 'Event Organization',
              icon: 'event',
              color: AppTheme.secondary,
              items: events,
              isExpanded: _expandedSections['events'] ?? false,
              onToggleExpanded: () => _toggleSection('events'),
              onItemTap: (achievement) =>
                  _editAchievement(user, 'events', achievement),
              onItemShare: _shareAchievement,
              onRequestVerification: _requestVerification,
              onAddNew: () => _addNewAchievement(user, 'event'),
            ),
            PortfolioSectionWidget(
              title: 'Project Contributions',
              icon: 'work',
              color: AppTheme.success,
              items: projects,
              isExpanded: _expandedSections['projects'] ?? false,
              onToggleExpanded: () => _toggleSection('projects'),
              onItemTap: (achievement) =>
                  _editAchievement(user, 'projects', achievement),
              onItemShare: _shareAchievement,
              onRequestVerification: _requestVerification,
              onAddNew: () => _addNewAchievement(user, 'project'),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _achievementItems(UserModel user, String key) {
    final savedItems = user.portfolioAchievements
        .where((item) => _achievementSectionKey(item) == key)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    if (savedItems.isNotEmpty) {
      return savedItems;
    }

    return ((_portfolioData[key] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>())
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  List<Map<String, dynamic>> _achievementListForUser(UserModel user) {
    if (user.portfolioAchievements.isNotEmpty) {
      return user.portfolioAchievements
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return [
      ..._achievementItems(user, 'leadership'),
      ..._achievementItems(user, 'events'),
      ..._achievementItems(user, 'projects'),
    ];
  }

  String _achievementSectionKey(Map<String, dynamic> achievement) {
    final category = achievement['category'] as String? ?? '';
    if (category == 'event') return 'events';
    if (category == 'project') return 'projects';
    return 'leadership';
  }

  List<Map<String, dynamic>> _skillItems(UserModel user) {
    if (user.portfolioSkills.isNotEmpty) {
      return user.portfolioSkills
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return ((_portfolioData['skills'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>())
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Widget _buildCustomMenuSection(UserModel user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visibleItems = [...user.portfolioItems]
      ..sort((a, b) => a.order.compareTo(b.order));
    final menuItems = visibleItems.where((item) => item.isVisible).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'dashboard_customize',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'My Portfolio',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showPortfolioMenuEditor(user),
                icon: CustomIconWidget(
                  iconName: 'edit',
                  color: colorScheme.primary,
                  size: 18,
                ),
                label: const Text('メニューを編集'),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (menuItems.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Text(
                '表示中のメニュー項目はありません。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Wrap(
              spacing: 3.w,
              runSpacing: 1.5.h,
              children: menuItems.map(_buildPortfolioMenuItem).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPortfolioMenuItem(PortfolioItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => _openPortfolioItem(item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42.w,
        constraints: const BoxConstraints(minHeight: 76),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: item.iconName,
                  color: colorScheme.onPrimary,
                  size: 22,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                item.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsTab(UserModel user) {
    final skills = _skillItems(user);

    return SingleChildScrollView(
      primary: _activeTabIndex == 1,
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SkillsEndorsementWidget(
            skills: skills,
            onRequestEndorsement: _requestEndorsement,
            onAddSkill: (skillName) => _addNewSkill(user, skillName),
            onEditSkill: (skill) => _editSkill(user, skill),
            onDeleteSkill: (skill) => _deleteSkill(user, skill),
          ),
          SizedBox(height: 2.h),
          _buildEndorsementRequests(),
        ],
      ),
    );
  }

  Widget _buildEndorsementRequests() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.warning,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Endorsement Requests',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildEndorsementRequestItem(
            'Yuki Tanaka wants you to endorse Flutter Development',
            'Programming Circle',
            () => _handleEndorsementRequest('accept'),
            () => _handleEndorsementRequest('decline'),
          ),
          _buildEndorsementRequestItem(
            'Hiroshi Sato wants you to endorse Leadership',
            'Student Council',
            () => _handleEndorsementRequest('accept'),
            () => _handleEndorsementRequest('decline'),
          ),
        ],
      ),
    );
  }

  Widget _buildEndorsementRequestItem(
    String request,
    String organization,
    VoidCallback onAccept,
    VoidCallback onDecline,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            organization,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  child: const Text('Decline'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  child: const Text('Endorse'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSections[section] = !(_expandedSections[section] ?? false);
    });
  }

  Future<void> _openPortfolioItem(PortfolioItem item) async {
    final rawUrl = item.url.trim();
    final normalizedUrl =
        rawUrl.startsWith(RegExp(r'https?://')) ? rawUrl : 'https://$rawUrl';
    final uri = Uri.tryParse(normalizedUrl);

    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URLが正しくありません')),
      );
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('リンクを開けませんでした')),
      );
    }
  }

  void _showPortfolioMenuEditor(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PortfolioMenuEditorSheet(
        user: user,
        onSave: _savePortfolioItems,
      ),
    );
  }

  Future<void> _savePortfolioItems(
    UserModel user,
    List<PortfolioItem> items,
  ) async {
    final normalizedItems = <PortfolioItem>[
      for (var i = 0; i < items.length; i++) items[i].copyWith(order: i),
    ];

    await ref.read(firestoreServiceProvider).updateUser(
          user.copyWith(
            portfolioItems: normalizedItems,
            updatedAt: DateTime.now(),
          ),
        );
    ref.invalidate(portfolioUserProvider(user.id));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ポートフォリオメニューを保存しました')),
      );
    }
  }

  Future<void> _refreshPortfolio() async {
    final user = ref.read(firebaseAuthServiceProvider).currentUser;
    if (user != null) {
      ref.invalidate(portfolioUserProvider(user.uid));
    }
  }

  Future<void> _editAchievement(
    UserModel user,
    String sectionKey,
    Map<String, dynamic> achievement,
  ) async {
    final updatedAchievement = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _buildEditAchievementDialog(achievement),
    );

    if (updatedAchievement == null) return;

    final achievements = _achievementListForUser(user);
    final index = achievements
        .indexWhere((item) => item['id'] == updatedAchievement['id']);
    if (index >= 0) {
      achievements[index] = {
        ...updatedAchievement,
        'category': _categoryFromSectionKey(sectionKey),
      };
      try {
        await _saveAchievements(user, achievements);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Achievement updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  Widget _buildEditAchievementDialog(Map<String, dynamic> achievement) {
    final titleController =
        TextEditingController(text: achievement['title'] as String? ?? '');
    final descriptionController = TextEditingController(
        text: achievement['description'] as String? ?? '');
    final organizationController = TextEditingController(
        text: achievement['organization'] as String? ?? '');

    return AlertDialog(
      title: const Text('Edit Achievement'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: organizationController,
              decoration: const InputDecoration(
                labelText: 'Organization',
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              {
                ...achievement,
                'title': titleController.text.trim(),
                'organization': organizationController.text.trim(),
                'description': descriptionController.text.trim(),
              },
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _shareAchievement(Map<String, dynamic> achievement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 1.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(0.5.h),
              ),
            ),
            const Text(
              'Share Achievement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption('link', 'Copy Link'),
                _buildShareOption('message', 'Message'),
                _buildShareOption('email', 'Email'),
                _buildShareOption('more_horiz', 'More'),
              ],
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(String icon, String label) {
    return Column(
      children: [
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 6.w,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _requestVerification(Map<String, dynamic> achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Verification'),
        content: Text(
          'Request verification for "${achievement['title']}" from ${achievement['organization']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification request sent')),
              );
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewAchievement(UserModel user, String category) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final organizationController = TextEditingController();

    final newAchievement = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New ${category.capitalize()}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: organizationController,
                decoration: const InputDecoration(
                  labelText: 'Organization',
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'title': titleController.text.trim(),
                  'organization': organizationController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'category': category,
                  'date': DateTime.now().toString().substring(0, 10),
                  'duration': '1 month',
                  'impactScore': 5,
                  'isVerified': false,
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    titleController.dispose();
    descriptionController.dispose();
    organizationController.dispose();

    if (newAchievement == null) return;

    final achievements = [
      ..._achievementListForUser(user),
      newAchievement,
    ];
    try {
      await _saveAchievements(user, achievements);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${category.capitalize()} added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _saveAchievements(
    UserModel user,
    List<Map<String, dynamic>> achievements,
  ) async {
    await ref.read(firestoreServiceProvider).updateUser(
          user.copyWith(
            portfolioAchievements: achievements,
            updatedAt: DateTime.now(),
          ),
        );
    ref.invalidate(portfolioUserProvider(user.id));
  }

  String _categoryFromSectionKey(String sectionKey) {
    if (sectionKey == 'events') return 'event';
    if (sectionKey == 'projects') return 'project';
    return 'leadership';
  }

  void _requestEndorsement(String skillName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Endorsement'),
        content: Text(
            'Request endorsement for "$skillName" from your circle members?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Endorsement request sent to circle members')),
              );
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewSkill(UserModel user, String skillName) async {
    final skills = _skillItems(user);
    skills.add({
      'name': skillName,
      'category': 'Technical',
      'endorsements': 0,
    });

    try {
      await _saveSkills(user, skills);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skill added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _editSkill(
    UserModel user,
    Map<String, dynamic> skill,
  ) async {
    final nameController =
        TextEditingController(text: skill['name'] as String? ?? '');
    var selectedCategory = skill['category'] as String? ?? 'Technical';
    final categories = ['Technical', 'Leadership', 'Creative', 'Communication'];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Skill'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Skill Name'),
              ),
              SizedBox(height: 2.h),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedCategory = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(context, {
                  ...skill,
                  'name': name,
                  'category': selectedCategory,
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    if (result == null) return;

    final skills = _skillItems(user);
    final index = skills.indexWhere(
      (item) =>
          item['name'] == skill['name'] &&
          item['category'] == skill['category'],
    );
    if (index >= 0) {
      skills[index] = result;
      try {
        await _saveSkills(user, skills);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  Future<void> _deleteSkill(
    UserModel user,
    Map<String, dynamic> skill,
  ) async {
    final skills = _skillItems(user)
      ..removeWhere(
        (item) =>
            item['name'] == skill['name'] &&
            item['category'] == skill['category'],
      );
    try {
      await _saveSkills(user, skills);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _saveSkills(
    UserModel user,
    List<Map<String, dynamic>> skills,
  ) async {
    await ref.read(firestoreServiceProvider).updateUser(
          user.copyWith(
            portfolioSkills: skills,
            updatedAt: DateTime.now(),
          ),
        );
    ref.invalidate(portfolioUserProvider(user.id));
  }

  void _handleEndorsementRequest(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Endorsement ${action}ed')),
    );
  }

  void _showEditProfileDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => PortfolioProfileEditorDialog(
        user: user,
        fallbackUniversity: _portfolioData['university'] as String,
        fallbackMajor: _portfolioData['major'] as String,
        onSave: _saveProfile,
      ),
    );
  }

  Future<void> _saveProfile({
    required UserModel user,
    required String userName,
    required String university,
    required String major,
    Uint8List? imageBytes,
    File? imageFile,
  }) async {
    final storageService = ref.read(firebaseStorageServiceProvider);
    final firestoreService = ref.read(firestoreServiceProvider);
    var profileImageUrl = user.profileImageUrl;

    if (imageBytes != null) {
      final path = storageService.generateImagePath(user.id, 'portfolio');
      profileImageUrl =
          await storageService.uploadImage(bytes: imageBytes, path: path);
    } else if (!kIsWeb && imageFile != null) {
      final path = storageService.generateImagePath(user.id, 'portfolio');
      profileImageUrl =
          await storageService.uploadImage(imageFile: imageFile, path: path);
    }

    await firestoreService.updateUser(
      user.copyWith(
        userName: userName,
        profileImageUrl: profileImageUrl,
        university: university,
        major: major,
        updatedAt: DateTime.now(),
      ),
    );
    ref.invalidate(portfolioUserProvider(user.id));
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ExportOptionsWidget(
        portfolioData: _portfolioData,
        onClose: () => Navigator.pop(context),
      ),
    );
  }
}

class PortfolioProfileEditorDialog extends StatefulWidget {
  final UserModel user;
  final String fallbackUniversity;
  final String fallbackMajor;
  final Future<void> Function({
    required UserModel user,
    required String userName,
    required String university,
    required String major,
    Uint8List? imageBytes,
    File? imageFile,
  }) onSave;

  const PortfolioProfileEditorDialog({
    super.key,
    required this.user,
    required this.fallbackUniversity,
    required this.fallbackMajor,
    required this.onSave,
  });

  @override
  State<PortfolioProfileEditorDialog> createState() =>
      _PortfolioProfileEditorDialogState();
}

class _PortfolioProfileEditorDialogState
    extends State<PortfolioProfileEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _universityController;
  late final TextEditingController _majorController;
  Uint8List? _imageBytes;
  File? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.userName);
    _universityController = TextEditingController(
      text: widget.user.university ?? widget.fallbackUniversity,
    );
    _majorController = TextEditingController(
      text: widget.user.major ?? widget.fallbackMajor,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _isSaving ? null : _pickImage,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _imageBytes != null
                      ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                      : (widget.user.profileImageUrl != null &&
                              widget.user.profileImageUrl!.trim().isNotEmpty
                          ? CustomImageWidget(
                              imageUrl: widget.user.profileImageUrl!,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: CustomIconWidget(
                                iconName: 'add_a_photo',
                                color: colorScheme.onSurfaceVariant,
                                size: 32,
                              ),
                            )),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _universityController,
              decoration: const InputDecoration(labelText: 'University'),
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _majorController,
              decoration: const InputDecoration(labelText: 'Major'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    if (!mounted) return;

    setState(() {
      _imageBytes = bytes;
      if (!kIsWeb) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final userName = _nameController.text.trim();
    final university = _universityController.text.trim();
    final major = _majorController.text.trim();

    if (userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名前を入力してください')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        user: widget.user,
        userName: userName,
        university: university,
        major: major,
        imageBytes: _imageBytes,
        imageFile: _imageFile,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('プロフィール保存に失敗しました: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class PortfolioMenuEditorSheet extends StatefulWidget {
  final UserModel user;
  final Future<void> Function(UserModel user, List<PortfolioItem> items) onSave;

  const PortfolioMenuEditorSheet({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<PortfolioMenuEditorSheet> createState() =>
      _PortfolioMenuEditorSheetState();
}

class _PortfolioMenuEditorSheetState extends State<PortfolioMenuEditorSheet> {
  static const List<String> _iconOptions = [
    'link',
    'code',
    'article',
    'work',
    'school',
    'alternate_email',
    'photo_camera',
    'video_library',
    'business_center',
    'language',
  ];

  late List<PortfolioItem> _items;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _items = [...widget.user.portfolioItems]
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 86.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
          child: Column(
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'メニューを編集',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '追加',
                    onPressed: _isSaving ? null : () => _openItemDialog(),
                    icon: CustomIconWidget(
                      iconName: 'add',
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Expanded(
                child: _items.isEmpty
                    ? Center(
                        child: Text(
                          '右上の + から項目を追加できます。',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ReorderableListView.builder(
                        itemCount: _items.length,
                        onReorder: _reorderItems,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return _buildEditableItem(item, index);
                        },
                      ),
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('キャンセル'),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('保存'),
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

  Widget _buildEditableItem(PortfolioItem item, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      key: ValueKey(item.id),
      margin: EdgeInsets.only(bottom: 1.h),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: item.iconName,
                  color: colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        item.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CustomIconWidget(
                      iconName: 'drag_handle',
                      color: colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Text(
                  '表示',
                  style: theme.textTheme.bodyMedium,
                ),
                Switch(
                  value: item.isVisible,
                  onChanged: (value) {
                    setState(() {
                      _items[index] = item.copyWith(isVisible: value);
                    });
                  },
                ),
                const Spacer(),
                IconButton(
                  tooltip: '編集',
                  onPressed: () => _openItemDialog(item: item, index: index),
                  icon: CustomIconWidget(
                    iconName: 'edit',
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                IconButton(
                  tooltip: '削除',
                  onPressed: () => _deleteItem(index),
                  icon: CustomIconWidget(
                    iconName: 'delete',
                    color: AppTheme.error,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _reorderItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  void _deleteItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _openItemDialog({PortfolioItem? item, int? index}) async {
    final titleController = TextEditingController(text: item?.title ?? '');
    final urlController = TextEditingController(text: item?.url ?? '');
    var selectedIcon = item?.iconName ?? _iconOptions.first;

    final result = await showDialog<PortfolioItem>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(item == null ? '項目を追加' : '項目を編集'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'タイトル'),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 2.h),
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        labelText: 'URL',
                        hintText: 'https://example.com',
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    SizedBox(height: 2.h),
                    DropdownButtonFormField<String>(
                      initialValue: selectedIcon,
                      decoration: const InputDecoration(labelText: 'アイコン'),
                      items: _iconOptions
                          .map(
                            (iconName) => DropdownMenuItem(
                              value: iconName,
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: iconName,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(iconName),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedIcon = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final url = urlController.text.trim();
                    if (title.isEmpty || url.isEmpty) {
                      return;
                    }

                    Navigator.pop(
                      context,
                      PortfolioItem(
                        id: item?.id ??
                            DateTime.now().microsecondsSinceEpoch.toString(),
                        title: title,
                        url: url,
                        iconName: selectedIcon,
                        isVisible: item?.isVisible ?? true,
                        order: item?.order ?? _items.length,
                      ),
                    );
                  },
                  child: const Text('反映'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    urlController.dispose();

    if (result == null) return;

    setState(() {
      if (index == null) {
        _items.add(result);
      } else {
        _items[index] = result;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSave(widget.user, _items);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}