import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
// ConnectionRequestModel

class CircleProfile extends ConsumerStatefulWidget {
  const CircleProfile({super.key});

  @override
  ConsumerState<CircleProfile> createState() => _CircleProfileState();
}

class _CircleProfileState extends ConsumerState<CircleProfile>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  CircleModel? _circle;
  String? _circleId;
  bool _didLoadData = false;

  User? _currentUser;
  bool _isOwner = false;

  // ⬇️ --- 新規: モード管理用 --- ⬇️
  bool _isSelectionMode = false;
  String? _sourceCircleId; // リクエスト元のサークルID
  CircleModel? _sourceCircle; // リクエスト元のサークル情報
  // ⬆️ ----------------------- ⬆️

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
    setState(() {
      _isLoading = true;
    });

    final authService = ref.read(firebaseAuthServiceProvider);
    _currentUser = authService.currentUser;
    if (_currentUser == null) {
      Navigator.pop(context);
      return;
    }

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null || args['circleId'] == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    _circleId = args['circleId'] as String;

    // ⬇️ --- 引数からモード情報を取得 --- ⬇️
    _isSelectionMode = args['isSelectionMode'] ?? false;
    _sourceCircleId = args['sourceCircleId'];
    // ⬆️ ---------------------------- ⬆️

    if (_currentUser!.uid == _circleId) {
      setState(() {
        _isOwner = true;
      });
    }

    final firestoreService = ref.read(firestoreServiceProvider);

    // ⬇️ 選択モードなら、送信元サークルの情報を取得しておく (リクエストデータ作成用) ⬇️
    if (_isSelectionMode && _sourceCircleId != null) {
      try {
        _sourceCircle = await firestoreService.getCircle(_sourceCircleId!);
      } catch (e) {
        print("送信元サークル情報の取得失敗: $e");
      }
    }
    // ⬆️ --------------------------------------------------------------- ⬆️

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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_circle == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        appBar: AppBar(title: const Text('サークルプロフィール')),
        body: const Center(child: Text('サークルが見つかりません')),
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
                      Image.network(_circle!.coverImageUrl!, fit: BoxFit.cover)
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
                            Colors.black.withOpacity(0.7)
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
                labelStyle: AppTheme.lightTheme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: AppTheme.lightTheme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w400),
                tabs: const [Tab(text: "About"), Tab(text: "Contact")],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildAboutTab(), _buildContactTab()],
              ),
            ),
          ],
        ),
      ),
      // ⬇️ --- FAB のロジック変更 --- ⬇️
      floatingActionButton: _buildFloatingActionButton(),
      // ⬆️ --------------------- ⬆️
    );
  }

  Widget? _buildFloatingActionButton() {
    // オーナーなら何も表示しない (編集ボタンなどを置く場所)
    if (_isOwner) return null;

    // 選択モードなら「リクエスト送信」ボタン
    if (_isSelectionMode) {
      return FloatingActionButton.extended(
        onPressed: _handleSendConnectionRequest,
        label: const Text('リクエスト送信'),
        icon: const Icon(Icons.send),
        backgroundColor: Colors.orange, // 色を変えて区別
        foregroundColor: Colors.white,
      );
    }

    // 通常モードなら「DMを送信」ボタン
    return FloatingActionButton.extended(
      onPressed: _handleSendDm,
      label: const Text('DMを送信'),
      icon: const Icon(Icons.message_outlined),
    );
  }

  // ... ( _buildAboutTab, _buildContactTab は変更なし) ...
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
                    'DM (ダイレクトメッセージ) について',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '「DMを送信」ボタンを押すと、このサークルの管理者と直接メッセージのやり取りを開始できます。',
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

  // ⬇️ --- サークル間コネクションリクエスト送信ロジック --- ⬇️
  Future<void> _handleSendConnectionRequest() async {
    if (_circle == null || _sourceCircleId == null || _sourceCircle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('情報が不足しているためリクエストを送信できません')),
      );
      return;
    }

    try {
      final firestoreService = ref.read(firestoreServiceProvider);

      // コネクションリクエストモデルの作成
      final request = ConnectionRequestModel(
        id: '', // Firestoreで自動生成される
        fromCircleId: _sourceCircleId!,
        toCircleId: _circle!.id,
        fromCircleName: _sourceCircle!.circleName,
        toCircleName: _circle!.circleName,
        fromUniversityName: _sourceCircle!.universityName,
        toUniversityName: _circle!.universityName,
        status: ConnectionStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestoreService.sendConnectionRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('コネクションリクエストを送信しました！'),
            backgroundColor: Colors.green,
          ),
        );
        // 送信後は一覧画面に戻る
        Navigator.pop(context); // プロフィールを閉じる
        Navigator.pop(context); // 一覧選択画面を閉じる
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('リクエスト送信に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // ⬆️ ---------------------------------------------- ⬆️

  Future<void> _handleSendDm() async {
    // ... (既存の個人DMロジック。変更なし) ...
    if (_currentUser == null || _circle == null) return;

    final String individualName = _currentUser!.displayName ??
        _currentUser!.email?.split('@').first ??
        'ゲストユーザー';

    final String? individualAvatarUrl = _currentUser!.photoURL;

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
        individualAvatarUrl: individualAvatarUrl,
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
          content: Text('DMの開始に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleShareCircle() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        // SingleChildScrollView で縦方向オーバーフローを防止
        child: SingleChildScrollView(
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
                // 下部は safe-area 分 (ホームインジケーター等) + 元の余白を合算
                padding: EdgeInsets.fromLTRB(
                  4.w,
                  0,
                  4.w,
                  MediaQuery.of(context).padding.bottom + 3.h,
                ),
                child: Column(
                  children: [
                    Text(
                      "サークルをシェア",
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption(String iconName, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (!mounted) return;
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
