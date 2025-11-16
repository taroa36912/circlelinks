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
  // bool _isRequestSent = false; 
  CircleModel? _circle;
  String? _circleId;
  bool _didLoadData = false;
  
  CircleModel? _currentUserCircle; 
  User? _currentUser;
  bool _isOwner = false; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadData) { 
      _loadData(); 
      _didLoadData = true;
    }
  }
  
  void _loadData() async {
    setState(() { _isLoading = true; });
    
    final authService = ref.read(firebaseAuthServiceProvider);
    _currentUser = authService.currentUser;
    if (_currentUser == null) {
      Navigator.pop(context); 
      return;
    }

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null || args['circleId'] == null) {
      setState(() { _isLoading = false; });
      return; 
    }
    _circleId = args['circleId'] as String;
    
    if (_currentUser!.uid == _circleId) {
      setState(() { _isOwner = true; });
    }

    final firestoreService = ref.read(firestoreServiceProvider);
    try {
      _currentUserCircle = await firestoreService.getCircle(_currentUser!.uid);
    } catch (e) {
      print("DM送信者情報の取得に失敗 (サークル未登録の個人ユーザー): $e");
    }

    await _fetchCircle(firestoreService);
  }

  Future<void> _fetchCircle(FirestoreService firestoreService) async {
    if (_circleId == null) return;
    
    try {
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
                            Colors.black.withOpacity(0.7),
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
      floatingActionButton: _isOwner
          ? null 
          : FloatingActionButton.extended(
              onPressed: _handleSendDm,
              label: const Text('DMを送信'),
              icon: const Icon(Icons.message_outlined),
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
                  Text('基本情報', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600,),),
                  SizedBox(height: 2.h),
                  Row(children: [Icon(Icons.school, color: Theme.of(context).colorScheme.primary), SizedBox(width: 2.w), Expanded(child: Text(_circle!.universityName, style: Theme.of(context).textTheme.bodyLarge,),),],),
                  SizedBox(height: 1.h),
                  Row(children: [Icon(Icons.category, color: Theme.of(context).colorScheme.primary), SizedBox(width: 2.w), Expanded(child: Text(_circle!.category, style: Theme.of(context).textTheme.bodyLarge,),),],),
                  SizedBox(height: 1.h),
                  Row(children: [Icon(Icons.people, color: Theme.of(context).colorScheme.primary), SizedBox(width: 2.w), Expanded(child: Text('${_circle!.memberCount} メンバー', style: Theme.of(context).textTheme.bodyLarge,),),],),
                  if (_circle!.isVerified) ...[
                    SizedBox(height: 1.h),
                    Row(children: [Icon(Icons.verified, color: Colors.green), SizedBox(width: 2.w), Text('大学公認サークル', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.green, fontWeight: FontWeight.w600,),),],),
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
                  Text('活動内容', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600,),),
                  SizedBox(height: 2.h),
                  Text(_circle!.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6,),),
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
                    Text('ソーシャルメディア', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600,),),
                    SizedBox(height: 2.h),
                    ...List.generate(_circle!.socialMediaLinks.length, (index) {
                      final link = _circle!.socialMediaLinks[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Row(
                          children: [
                            Icon(Icons.link, color: Theme.of(context).colorScheme.primary), SizedBox(width: 2.w),
                            Expanded(child: Text(link, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline,),),),
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
                  Text('連絡先情報', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600,),),
                  SizedBox(height: 2.h),
                  Row(children: [Icon(Icons.email, color: Theme.of(context).colorScheme.primary), SizedBox(width: 2.w), Expanded(child: Text(_circle!.email, style: Theme.of(context).textTheme.bodyLarge,),),],),
                  SizedBox(height: 1.h),
                  Row(children: [Icon(Icons.school, color: Theme.of(context).colorScheme.primary), SizedBox(width: 2.w), Expanded(child: Text(_circle!.universityName, style: Theme.of(context).textTheme.bodyLarge,),),],),
                  SizedBox(height: 1.h),
                  Row(children: [Icon(Icons.group, color: Theme.of(context).colorScheme.primary), SizedBox(width: 2.w), Expanded(child: Text(_circle!.circleName, style: Theme.of(context).textTheme.bodyLarge,),),],),
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
                  Text('DM (ダイレクトメッセージ) について', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600,),), 
                  SizedBox(height: 2.h),
                  Text('「DMを送信」ボタンを押すと、このサークルの管理者と直接メッセージのやり取りを開始できます。', style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6,),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendDm() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('デバッグエラー: ユーザーが null です'), backgroundColor: Colors.red,));
      return;
    }
    if (_circle == null) {
      return;
    }
    
    // 自分のサークル情報（_currentUserCircle）は _loadData で取得済み
    final String individualName = _currentUserCircle?.circleName ?? 
                                _currentUser!.displayName ?? 
                                _currentUser!.email?.split('@').first ?? 
                                'ゲストユーザー';

    final String circleId = _circle!.id;
    final String circleName = _circle!.circleName;
    final String? circleAvatarUrl = _circle!.profileImageUrl;

    try {
      final firestoreService = ref.read(firestoreServiceProvider);

      final channelId = await firestoreService.getOrCreateDmChannel(
        individualId: _currentUser!.uid,
        circleId: circleId,
        individualName: individualName,
        circleName: circleName,
        circleAvatarUrl: circleAvatarUrl,
      );
      
      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.dmChat,
          arguments: {
            'dmChannelId': channelId,
            'recipientName': circleName, 
          },
        );
      }

    } catch (e) {      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('DMの開始に失敗しました: $e'), // 👈 'permission-denied' が表示される
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
                  SingleChildScrollView( 
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildShareOption("link", "リンクをコピー"),
                        SizedBox(width: 4.w), 
                        _buildShareOption("message", "メッセージ"),
                        SizedBox(width: 4.w), 
                        _buildShareOption("email", "メール"),
                        SizedBox(width: 4.w), 
                        _buildShareOption("more_horiz", "その他"),
                      ],
                    ),
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
          SizedBox( 
            width: 14.w, 
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall,
              textAlign: TextAlign.center, 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis, 
            ),
          ),
        ],
      ),
    );
  }
}