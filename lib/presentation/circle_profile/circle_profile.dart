import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class CircleProfile extends ConsumerStatefulWidget {
  const CircleProfile({super.key});

  @override
  ConsumerState<CircleProfile> createState() => _CircleProfileState();
}

class _CircleProfileState extends ConsumerState<CircleProfile>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isRequestSent = false;
  CircleModel? _circle;
  String? _circleId;
  bool _didLoadData = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _loadCircleData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadData) { 
      _loadCircleData();
      _didLoadData = true;
    }
  }

  void _loadCircleData() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['circleId'] != null) {
      _circleId = args['circleId'] as String;
      _fetchCircle();
    }
  }

  Future<void> _fetchCircle() async {
    if (_circleId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final circle = await firestoreService.getCircle(_circleId!);

      if (mounted) {
        setState(() {
          _circle = circle;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('サークル情報の取得に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_circle == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('サークルプロフィール'),
        ),
        body: const Center(
          child: Text('サークルが見つかりません'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 30.h,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _circle!.circleName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_circle!.coverImageUrl != null)
                      Image.network(
                        _circle!.coverImageUrl!,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.lightTheme.colorScheme.primary,
                              AppTheme.lightTheme.colorScheme.secondary,
                            ],
                          ),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _handleShareCircle,
                  icon: const Icon(Icons.share, color: Colors.white),
                ),
              ],
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
                  Tab(text: "Contact"),
                ],
              ),
            ),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // About Tab
                  _buildAboutTab(),

                  // Contact Tab
                  _buildContactTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isRequestSent ? null : _handleSendConnectionRequest,
        label: Text(_isRequestSent ? 'リクエスト送信済み' : 'コネクションリクエスト'),
        icon: Icon(_isRequestSent ? Icons.check : Icons.send),
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info
          Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '基本情報',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.school,
                          color: Theme.of(context).colorScheme.primary),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          _circle!.universityName,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.category,
                          color: Theme.of(context).colorScheme.primary),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          _circle!.category,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.people,
                          color: Theme.of(context).colorScheme.primary),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          '${_circle!.memberCount} メンバー',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  if (_circle!.isVerified) ...[
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Icon(Icons.verified, color: Colors.green),
                        SizedBox(width: 2.w),
                        Text(
                          '大学公認サークル',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Description
          Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '活動内容',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _circle!.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                ],
              ),
            ),
          ),

          if (_circle!.socialMediaLinks.isNotEmpty) ...[
            SizedBox(height: 2.h),

            // Social Media Links
            Card(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ソーシャルメディア',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 2.h),
                    ...List.generate(_circle!.socialMediaLinks.length, (index) {
                      final link = _circle!.socialMediaLinks[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Row(
                          children: [
                            Icon(Icons.link,
                                color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                link,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '連絡先情報',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.email,
                          color: Theme.of(context).colorScheme.primary),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          _circle!.email,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.school,
                          color: Theme.of(context).colorScheme.primary),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          _circle!.universityName,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.group,
                          color: Theme.of(context).colorScheme.primary),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          _circle!.circleName,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Connection Request Info
          Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'コネクションについて',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'コネクションリクエストを送信すると、このサークルとチャットができるようになります。お互いの活動について情報交換したり、共同イベントの企画などが可能です。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendConnectionRequest() async {
    if (_circle == null) return;

    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ログインが必要です'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get current user's circle information
      final currentUserCircle =
          await firestoreService.getCircle(currentUser.uid);
      if (currentUserCircle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('サークル情報が見つかりません'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create connection request
      final request = ConnectionRequestModel(
        id: '', // Will be set by Firestore
        fromCircleId: currentUser.uid,
        toCircleId: _circle!.id,
        fromCircleName: currentUserCircle.circleName,
        toCircleName: _circle!.circleName,
        fromUniversityName: currentUserCircle.universityName,
        toUniversityName: _circle!.universityName,
        status: ConnectionStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestoreService.sendConnectionRequest(request);

      setState(() {
        _isRequestSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('コネクションリクエストを送信しました'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('リクエストの送信に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                    "サークルをシェア",
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShareOption("link", "リンクをコピー"),
                      _buildShareOption("message", "メッセージ"),
                      _buildShareOption("email", "メール"),
                      _buildShareOption("more_horiz", "その他"),
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
          SnackBar(content: Text("$label でシェアしました")),
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
}
