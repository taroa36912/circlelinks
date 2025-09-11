import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/additional_details_widget.dart';
import './widgets/attendance_section_widget.dart';
import './widgets/comments_section_widget.dart';
import './widgets/event_header_widget.dart';
import './widgets/event_info_card_widget.dart';

class EventDetails extends StatefulWidget {
  const EventDetails({super.key});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  final ScrollController _scrollController = ScrollController();
  String _currentUserStatus = 'undecided';
  bool _showAdditionalDetails = false;

  // Mock event data
  final Map<String, dynamic> _eventData = {
    'id': 1,
    'title': 'Winter Circle Gathering 2024',
    'heroImage':
        'https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'date': 'December 15, 2024',
    'time': '18:00 - 22:00',
    'location': 'Shibuya Sky Lounge',
    'address': '2-24-12 Shibuya, Shibuya City, Tokyo',
    'description':
        '''Join us for an amazing evening of networking, delicious food, and great company. This event is perfect for meeting new people and strengthening existing relationships within our circle community.

We'll have a variety of activities including:
• Welcome drinks and appetizers
• Group networking sessions
• Traditional Japanese games
• Live music performance
• Photo booth with props
• Special dinner menu

Don't miss this opportunity to connect with fellow circle members and create lasting memories together!''',
    'organizerName': 'Tokyo University Photography Circle',
    'organizerAvatar':
        'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=400',
    'organizerRole': 'Circle Leader',
    'paymentStatus': 'pending',
    'amount': '¥3,500',
    'status': 'upcoming',
  };

  // Mock attendees data
  final List<Map<String, dynamic>> _attendees = [
    {
      'id': 1,
      'name': 'Yuki Tanaka',
      'avatar':
          'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400',
      'status': 'attending',
    },
    {
      'id': 2,
      'name': 'Hiroshi Sato',
      'avatar':
          'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=400',
      'status': 'late',
    },
    {
      'id': 3,
      'name': 'Sakura Yamamoto',
      'avatar':
          'https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg?auto=compress&cs=tinysrgb&w=400',
      'status': 'attending',
    },
    {
      'id': 4,
      'name': 'Kenji Nakamura',
      'avatar':
          'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400',
      'status': 'first_party',
    },
    {
      'id': 5,
      'name': 'Mei Chen',
      'avatar':
          'https://images.pexels.com/photos/1239288/pexels-photo-1239288.jpeg?auto=compress&cs=tinysrgb&w=400',
      'status': 'attending',
    },
    {
      'id': 6,
      'name': 'Takeshi Ito',
      'avatar':
          'https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=400',
      'status': 'undecided',
    },
    {
      'id': 7,
      'name': 'Aiko Suzuki',
      'avatar':
          'https://images.pexels.com/photos/1181519/pexels-photo-1181519.jpeg?auto=compress&cs=tinysrgb&w=400',
      'status': 'attending',
    },
    {
      'id': 8,
      'name': 'Ryota Kimura',
      'avatar':
          'https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg?auto=compress&cs=tinysrgb&w=400',
      'status': 'late',
    },
    {
      'id': 9,
      'name': 'Nana Watanabe',
      'avatar':
          'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400',
      'status': 'attending',
    },
    {
      'id': 10,
      'name': 'Daiki Hayashi',
      'avatar':
          'https://images.pexels.com/photos/1043473/pexels-photo-1043473.jpeg?auto=compress&cs=tinysrgb&w=400',
      'status': 'first_party',
    },
  ];

  // Mock photos data
  final List<Map<String, dynamic>> _photos = [
    {
      'id': 1,
      'url':
          'https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg?auto=compress&cs=tinysrgb&w=400',
      'uploadedBy': 'Yuki Tanaka',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': 2,
      'url':
          'https://images.pexels.com/photos/1267320/pexels-photo-1267320.jpeg?auto=compress&cs=tinysrgb&w=400',
      'uploadedBy': 'Sakura Yamamoto',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      'id': 3,
      'url':
          'https://images.pexels.com/photos/1395967/pexels-photo-1395967.jpeg?auto=compress&cs=tinysrgb&w=400',
      'uploadedBy': 'Hiroshi Sato',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
    },
  ];

  // Mock expenses data
  final List<Map<String, dynamic>> _expenses = [
    {
      'id': 1,
      'name': 'Venue Rental',
      'amount': 15000,
      'icon': 'location_on',
    },
    {
      'id': 2,
      'name': 'Food & Beverages',
      'amount': 25000,
      'icon': 'restaurant',
    },
    {
      'id': 3,
      'name': 'Entertainment',
      'amount': 8000,
      'icon': 'music_note',
    },
    {
      'id': 4,
      'name': 'Decorations',
      'amount': 3500,
      'icon': 'celebration',
    },
    {
      'id': 5,
      'name': 'Photography',
      'amount': 5000,
      'icon': 'camera_alt',
    },
  ];

  // Mock comments data
  final List<Map<String, dynamic>> _comments = [
    {
      'id': 1,
      'userName': 'Yuki Tanaka',
      'userAvatar':
          'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400',
      'content':
          'Really looking forward to this event! The venue looks amazing.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'likes': 5,
      'isLiked': false,
    },
    {
      'id': 2,
      'userName': 'Sakura Yamamoto',
      'userAvatar':
          'https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg?auto=compress&cs=tinysrgb&w=400',
      'content':
          'Should we bring anything special? Also, is there a dress code?',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'likes': 3,
      'isLiked': true,
    },
    {
      'id': 3,
      'userName': 'Hiroshi Sato',
      'userAvatar':
          'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=400',
      'content':
          'The menu looks fantastic! Can\'t wait to try the traditional dishes.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'likes': 2,
      'isLiked': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show additional details when user scrolls down significantly
    if (_scrollController.offset > 50.h && !_showAdditionalDetails) {
      setState(() => _showAdditionalDetails = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _refreshEventData,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            EventHeaderWidget(
              eventData: _eventData,
              onBackPressed: () => Navigator.pop(context),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  EventInfoCardWidget(eventData: _eventData),
                  AttendanceSectionWidget(
                    attendees: _attendees,
                    totalCount: _attendees.length,
                  ),
                  if (_showAdditionalDetails) ...[
                    AdditionalDetailsWidget(
                      eventData: _eventData,
                      photos: _photos,
                      expenses: _expenses,
                    ),
                    CommentsSectionWidget(
                      comments: _comments,
                      onCommentAdded: _addComment,
                    ),
                  ],
                  SizedBox(height: 20.h), // Space for bottom actions
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: ActionButtonsWidget(
        eventData: _eventData,
        currentUserStatus: _currentUserStatus,
        onStatusChanged: _updateUserStatus,
      ),
      floatingActionButton: _showAdditionalDetails
          ? null
          : FloatingActionButton.extended(
              onPressed: () => setState(() => _showAdditionalDetails = true),
              icon: CustomIconWidget(
                iconName: 'expand_more',
                color: Colors.white,
                size: 20,
              ),
              label: Text('More Details'),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
    );
  }

  Future<void> _refreshEventData() async {
    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event data updated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _updateUserStatus(String newStatus) {
    setState(() => _currentUserStatus = newStatus);

    // Update event data if needed
    _eventData['userStatus'] = newStatus;
  }

  void _addComment(String content) {
    final newComment = {
      'id': _comments.length + 1,
      'userName': 'Current User',
      'userAvatar':
          'https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg?auto=compress&cs=tinysrgb&w=400',
      'content': content,
      'timestamp': DateTime.now(),
      'likes': 0,
      'isLiked': false,
    };

    setState(() => _comments.insert(0, newComment));
  }
}
