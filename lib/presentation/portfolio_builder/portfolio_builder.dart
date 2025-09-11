import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_tab_bar.dart';
import './widgets/export_options_widget.dart';
import './widgets/portfolio_header_widget.dart';
import './widgets/portfolio_section_widget.dart';
import './widgets/skills_endorsement_widget.dart';

class PortfolioBuilder extends StatefulWidget {
  const PortfolioBuilder({super.key});

  @override
  State<PortfolioBuilder> createState() => _PortfolioBuilderState();
}

class _PortfolioBuilderState extends State<PortfolioBuilder>
    with TickerProviderStateMixin {
  late TabController _tabController;
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

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: Column(
        children: [
          PortfolioHeaderWidget(
            userName: _portfolioData['userName'] as String,
            university: _portfolioData['university'] as String,
            major: _portfolioData['major'] as String,
            completionPercentage:
                _portfolioData['completionPercentage'] as double,
            onEditProfile: _showEditProfileDialog,
          ),
          Expanded(
            child: CustomTabBar(
              tabs: const ['Portfolio', 'Skills'],
              tabViews: [
                _buildPortfolioTab(),
                _buildSkillsTab(),
              ],
              variant: CustomTabBarVariant.pills,
              onTabChanged: (index) {
                // Handle tab change if needed
              },
            ),
          ),
        ],
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
  }

  Widget _buildPortfolioTab() {
    return RefreshIndicator(
      onRefresh: _refreshPortfolio,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            PortfolioSectionWidget(
              title: 'Leadership Roles',
              icon: 'groups',
              color: AppTheme.primary,
              items: _portfolioData['leadership'] as List<Map<String, dynamic>>,
              isExpanded: _expandedSections['leadership'] ?? false,
              onToggleExpanded: () => _toggleSection('leadership'),
              onItemTap: _editAchievement,
              onItemShare: _shareAchievement,
              onRequestVerification: _requestVerification,
              onAddNew: () => _addNewAchievement('leadership'),
            ),
            PortfolioSectionWidget(
              title: 'Event Organization',
              icon: 'event',
              color: AppTheme.secondary,
              items: _portfolioData['events'] as List<Map<String, dynamic>>,
              isExpanded: _expandedSections['events'] ?? false,
              onToggleExpanded: () => _toggleSection('events'),
              onItemTap: _editAchievement,
              onItemShare: _shareAchievement,
              onRequestVerification: _requestVerification,
              onAddNew: () => _addNewAchievement('event'),
            ),
            PortfolioSectionWidget(
              title: 'Project Contributions',
              icon: 'work',
              color: AppTheme.success,
              items: _portfolioData['projects'] as List<Map<String, dynamic>>,
              isExpanded: _expandedSections['projects'] ?? false,
              onToggleExpanded: () => _toggleSection('projects'),
              onItemTap: _editAchievement,
              onItemShare: _shareAchievement,
              onRequestVerification: _requestVerification,
              onAddNew: () => _addNewAchievement('project'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SkillsEndorsementWidget(
            skills: _portfolioData['skills'] as List<Map<String, dynamic>>,
            onRequestEndorsement: _requestEndorsement,
            onAddSkill: _addNewSkill,
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

  Future<void> _refreshPortfolio() async {
    // Simulate API call to refresh portfolio data
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Portfolio updated')),
      );
    }
  }

  void _editAchievement(Map<String, dynamic> achievement) {
    showDialog(
      context: context,
      builder: (context) => _buildEditAchievementDialog(achievement),
    );
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
            // Update achievement data
            setState(() {
              achievement['title'] = titleController.text;
              achievement['organization'] = organizationController.text;
              achievement['description'] = descriptionController.text;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Achievement updated')),
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

  void _addNewAchievement(String category) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final organizationController = TextEditingController();

    showDialog(
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
                final newAchievement = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'title': titleController.text,
                  'organization': organizationController.text,
                  'description': descriptionController.text,
                  'category': category,
                  'date': DateTime.now().toString().substring(0, 10),
                  'duration': '1 month',
                  'impactScore': 5,
                  'isVerified': false,
                };

                setState(() {
                  final categoryKey = category == 'leadership'
                      ? 'leadership'
                      : category == 'event'
                          ? 'events'
                          : 'projects';
                  (_portfolioData[categoryKey] as List<Map<String, dynamic>>)
                      .add(newAchievement);
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('${category.capitalize()} added successfully')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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

  void _addNewSkill(String skillName) {
    setState(() {
      (_portfolioData['skills'] as List<Map<String, dynamic>>).add({
        'name': skillName,
        'category': 'Technical',
        'endorsements': 0,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Skill added successfully')),
    );
  }

  void _handleEndorsementRequest(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Endorsement ${action}ed')),
    );
  }

  void _showEditProfileDialog() {
    final nameController =
        TextEditingController(text: _portfolioData['userName'] as String);
    final universityController =
        TextEditingController(text: _portfolioData['university'] as String);
    final majorController =
        TextEditingController(text: _portfolioData['major'] as String);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: universityController,
              decoration: const InputDecoration(labelText: 'University'),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: majorController,
              decoration: const InputDecoration(labelText: 'Major'),
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
              setState(() {
                _portfolioData['userName'] = nameController.text;
                _portfolioData['university'] = universityController.text;
                _portfolioData['major'] = majorController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
