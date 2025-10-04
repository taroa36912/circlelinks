import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/about_section_widget.dart';
import './widgets/circle_header_widget.dart';
import './widgets/event_timeline_widget.dart';
import './widgets/member_grid_widget.dart';
import './widgets/project_opportunities_widget.dart';

class CircleProfile extends StatefulWidget {
  const CircleProfile({super.key});

  @override
  State<CircleProfile> createState() => _CircleProfileState();
}

class _CircleProfileState extends State<CircleProfile>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isMember = false;
  bool _isFollowing = false;
  final bool _isLoading = false;

  // Mock data for the circle
  final Map<String, dynamic> _circleData = {
    "id": 1,
    "name": "Tokyo University Football Circle",
    "university": "Tokyo University",
    "coverImage":
        "https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    "memberCount": 45,
    "activityType": "Sports",
    "establishedYear": 2018,
    "description":
        """Welcome to Tokyo University Football Circle! We are a passionate group of students who love football and believe in the power of teamwork, dedication, and friendship. Our circle welcomes players of all skill levels, from beginners to experienced athletes.

We focus on improving our technical skills, physical fitness, and tactical understanding of the game while building lasting friendships and memories. Join us for regular training sessions, friendly matches, and exciting tournaments throughout the year.""",
    "schedule": {
      "day": "Tuesday & Thursday",
      "time": "18:00 - 20:00",
      "location": "University Sports Ground"
    },
    "requirements": [
      "Open to all Tokyo University students",
      "Regular attendance at training sessions",
      "Participation in circle events and matches",
      "Monthly membership fee: ¥3,000",
      "Own football boots and training gear"
    ],
    "activities": [
      {"name": "Weekly Training", "icon": "sports_soccer"},
      {"name": "Inter-University Matches", "icon": "emoji_events"},
      {"name": "Social Gatherings", "icon": "celebration"},
      {"name": "Summer Training Camp", "icon": "nature"},
    ],
    "contact": {
      "email": "football.circle@todai.ac.jp",
      "phone": "+81-90-1234-5678",
      "website": "www.todai-football.jp"
    }
  };

  final List<Map<String, dynamic>> _members = [
    {
      "id": 1,
      "name": "Takeshi Yamamoto",
      "profileImage":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "role": "Captain",
      "year": 3,
      "skills": ["Leadership", "Strategy", "Motivation"]
    },
    {
      "id": 2,
      "name": "Yuki Tanaka",
      "profileImage":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "role": "Vice Captain",
      "year": 2,
      "skills": ["Organization", "Communication", "Planning"]
    },
    {
      "id": 3,
      "name": "Hiroshi Sato",
      "profileImage":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "role": "Treasurer",
      "year": 4,
      "skills": ["Finance", "Accounting", "Management"]
    },
    {
      "id": 4,
      "name": "Mei Watanabe",
      "profileImage":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "role": "PR Manager",
      "year": 1,
      "skills": ["Social Media", "Design", "Photography"]
    },
    {
      "id": 5,
      "name": "Kenji Nakamura",
      "profileImage":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "role": "Coach Assistant",
      "year": 3,
      "skills": ["Training", "Tactics", "Fitness"]
    },
    {
      "id": 6,
      "name": "Sakura Kimura",
      "profileImage":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "role": "Event Coordinator",
      "year": 2,
      "skills": ["Event Planning", "Logistics", "Creativity"]
    }
  ];

  final List<Map<String, dynamic>> _events = [
    {
      "id": 1,
      "title": "Inter-University Championship Final",
      "description":
          "The biggest match of the season against Waseda University. Come support our team!",
      "date": "2025-01-15",
      "time": "14:00",
      "location": "Tokyo Stadium",
      "attendeeCount": 38,
      "cost": "¥500",
      "paymentStatus": "paid",
      "images": [
        "https://images.unsplash.com/photo-1574629810360-7efbbe195018?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
        "https://images.unsplash.com/photo-1551698618-1dfe5d97d256?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3"
      ]
    },
    {
      "id": 2,
      "title": "New Year Training Camp",
      "description":
          "3-day intensive training camp to prepare for the new season. Includes accommodation and meals.",
      "date": "2025-01-20",
      "time": "09:00",
      "location": "Hakone Training Center",
      "attendeeCount": 42,
      "cost": "¥15,000",
      "paymentStatus": "pending",
      "images": [
        "https://images.unsplash.com/photo-1526232761682-d26e03ac148e?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3"
      ]
    },
    {
      "id": 3,
      "title": "Welcome Party 2024",
      "description":
          "Annual welcome party for new members. Great food, games, and networking!",
      "date": "2024-12-15",
      "time": "19:00",
      "location": "University Hall",
      "attendeeCount": 35,
      "images": [
        "https://images.unsplash.com/photo-1530103862676-de8c9debad1d?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
        "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
        "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3"
      ]
    }
  ];

  final List<Map<String, dynamic>> _projects = [
    {
      "id": 1,
      "title": "University Sports Festival Organization",
      "description":
          "Collaborate with multiple sports circles to organize the annual university sports festival. We need help with event planning, logistics, and promotion.",
      "partnerCircle": "Basketball Circle & Tennis Club",
      "type": "Event",
      "status": "Open",
      "duration": "3 months",
      "teamSize": 8,
      "deadline": "2025-02-28",
      "requiredSkills": ["Event Planning", "Marketing", "Logistics", "Design"]
    },
    {
      "id": 2,
      "title": "Circle Promotional Video Production",
      "description":
          "Create an engaging promotional video to attract new members. Looking for creative minds with video editing and storytelling skills.",
      "partnerCircle": "Media Production Circle",
      "type": "Design",
      "status": "In Progress",
      "duration": "1 month",
      "teamSize": 5,
      "deadline": "2025-01-31",
      "requiredSkills": [
        "Video Editing",
        "Storytelling",
        "Creative Writing",
        "Photography"
      ]
    },
    {
      "id": 3,
      "title": "Mobile App Development for Circle Management",
      "description":
          "Develop a mobile application to help manage circle activities, member communication, and event scheduling.",
      "partnerCircle": "Computer Science Circle",
      "type": "Development",
      "status": "Open",
      "duration": "6 months",
      "teamSize": 6,
      "deadline": "2025-06-30",
      "requiredSkills": [
        "Flutter",
        "Mobile Development",
        "UI/UX Design",
        "Project Management"
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CircleHeaderWidget(
              circleData: _circleData,
              isMember: _isMember,
              onJoinPressed: _handleJoinCircle,
              onFollowPressed: _handleFollowCircle,
              onSharePressed: _handleShareCircle,
            ),
          ];
        },
        body: Column(
          children: [
            // Tab Bar
            Container(
              color: AppTheme.lightTheme.colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                indicatorColor: AppTheme.lightTheme.colorScheme.primary,
                indicatorWeight: 3,
                labelColor: AppTheme.lightTheme.colorScheme.primary,
                unselectedLabelColor:
                    AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                labelStyle: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle:
                    AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: "About"),
                  Tab(text: "Members"),
                  Tab(text: "Events"),
                  Tab(text: "Projects"),
                ],
              ),
            ),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // About Tab
                  AboutSectionWidget(circleData: _circleData),

                  // Members Tab
                  MemberGridWidget(
                    members: _members,
                    onMemberTap: _handleMemberTap,
                  ),

                  // Events Tab
                  EventTimelineWidget(
                    events: _events,
                    onEventTap: _handleEventTap,
                  ),

                  // Projects Tab
                  ProjectOpportunitiesWidget(
                    projects: _projects,
                    onProjectTap: _handleProjectTap,
                    onApplyPressed: _handleApplyToProject,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleJoinCircle() {
    if (_isLoading) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Join Circle",
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to join ${_circleData["name"]}?",
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Membership Requirements:",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "• Regular attendance at meetings\n• Monthly fee: ¥3,000\n• Participation in events",
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isMember = true;
                _isFollowing = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Successfully joined ${_circleData["name"]}!"),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            child: const Text("Join Circle"),
          ),
        ],
      ),
    );
  }

  void _handleFollowCircle() {
    setState(() {
      _isFollowing = !_isFollowing;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFollowing
              ? "Now following ${_circleData["name"]}"
              : "Unfollowed ${_circleData["name"]}",
        ),
        backgroundColor: _isFollowing
            ? AppTheme.success
            : AppTheme.lightTheme.colorScheme.outline,
      ),
    );
  }

  void _handleShareCircle() {
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
                  Text(
                    "Share Circle",
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShareOption("link", "Copy Link"),
                      _buildShareOption("message", "Message"),
                      _buildShareOption("email", "Email"),
                      _buildShareOption("more_horiz", "More"),
                    ],
                  ),
                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(String iconName, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Shared via $label")),
        );
      },
      child: Column(
        children: [
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _handleMemberTap(Map<String, dynamic> member) {
    Navigator.pushNamed(context, '/portfolio-builder');
  }

  void _handleEventTap(Map<String, dynamic> event) {
    Navigator.pushNamed(context, '/event-details');
  }

  void _handleProjectTap(Map<String, dynamic> project) {
    // Show project details modal
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
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project["title"] as String,
                      style:
                          AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      project["description"] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleApplyToProject(project);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 6.h),
                      ),
                      child: const Text("Apply to Project"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleApplyToProject(Map<String, dynamic> project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Apply to Project"),
        content: Text("Submit your application for '${project["title"]}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text("Application submitted for '${project["title"]}'"),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }
}
