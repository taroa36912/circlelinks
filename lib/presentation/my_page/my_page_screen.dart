import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart'; 
import '../../core/models/user_model.dart'; // 👈 追加

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  CircleModel? _myCircleData;
  UserModel? _myUserData; // 👈 追加: ユーザー情報
  bool _isLoading = true;
  final String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    
    final authService = ref.read(firebaseAuthServiceProvider);
    final user = authService.currentUser;
    if (user == null) {
      setState(() { _isLoading = false; });
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      return;
    }

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      
      // 1. ユーザー情報を取得
      final userData = await firestoreService.getUser(user.uid);
      // 2. サークル情報を取得 (存在しない場合は null になる)
      final circleData = await firestoreService.getCircle(user.uid);

      if (mounted) {
        setState(() {
          _myUserData = userData;
          _myCircleData = circleData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        // サークルがないのは正常な場合もあるので、エラー表示は控えめに
        print("MyPage: データ取得エラー $e");
      }
    }
  }

  Future<void> _handleLogout() async {
    final authService = ref.read(firebaseAuthServiceProvider);
    try {
      await authService.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login, (Route<dynamic> route) => false
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログアウトに失敗しました: $e')),
        );
      }
    }
  }

  void _showComingSoonSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('この機能は現在準備中です'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'マイページ',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMenu(theme), // 👈 エラー画面ではなく、常にメニューを表示
    );
  }

  Widget _buildMenu(ThemeData theme) {
    // サークル作成済みかどうか
    final bool hasCircle = _myCircleData != null;

    return ListView(
      children: [
        // --- 1. プロフィールヘッダー ---
        _buildProfileHeader(theme),
        
        // --- 2. サークル機能 (分岐) ---
        if (hasCircle) ...[
           // ✅ サークル作成済みの場合
          _buildMenuSection(theme, "サークル活動"),
           _buildMenuItem(
             theme,
             icon: Icons.admin_panel_settings_outlined, // 管理アイコン
             title: "サークル管理",
             subtitle: "サークル情報の編集・DM確認",
             onTap: () {
               Navigator.pushNamed(context, AppRoutes.myCirclesList);
             },
           ),
           _buildMenuItem(
             theme,
             icon: Icons.campaign_outlined,
             title: "募集管理",
             subtitle: "新規メンバー募集の作成・管理",
             onTap: () {
               if (_myCircleData != null) {
                 Navigator.pushNamed(context, AppRoutes.recruitmentManagement,
                     arguments: {'circleId': _myCircleData!.id});
               }
             },
           ),
           _buildMenuItem(
            theme,
            icon: Icons.group_outlined,
            title: "所属サークル一覧", // 将来的に複数サークル対応
            onTap: _showComingSoonSnackBar,
          ),
        ] else ...[
           // ❌ サークル未作成の場合
          _buildMenuSection(theme, "サークル"),
          _buildMenuItem(
            theme,
            icon: Icons.add_business_outlined,
            title: "サークルを登録する",
            subtitle: "新しいサークルを作成・管理します",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.circleRegistration);
            },
          ),
        ],

        // --- 共通メニュー ---
        _buildMenuItem(
          theme,
          icon: Icons.work_outline,
          title: "Myポートフォリオ",
          onTap: () {
             Navigator.pushNamed(context, AppRoutes.portfolioBuilder); 
          },
        ),
         _buildMenuItem(
          theme,
          icon: Icons.people_outline,
          title: "コネクション管理", // ここに追加
          onTap: () {
             Navigator.pushNamed(context, AppRoutes.connections); 
          },
        ),

        // --- 3. 設定 ---
        _buildMenuSection(theme, "アカウントと設定"),
        _buildMenuItem(
          theme,
          icon: Icons.account_circle_outlined,
          title: "プロフィール設定", // 👈 ここでユーザー名などを変更
          subtitle: "ユーザー名・メールアドレスの変更",
          onTap: () {
             // TODO: プロフィール編集画面へ
             _showComingSoonSnackBar(); 
          },
        ),
        _buildMenuItem(
          theme,
          icon: Icons.notifications_outlined,
          title: "通知設定",
          onTap: _showComingSoonSnackBar,
        ),

        // --- 4. サポート ---
        _buildMenuSection(theme, "サポート"),
        _buildMenuItem(
          theme,
          icon: Icons.help_outline,
          title: "ヘルプ & サポート",
          onTap: _showComingSoonSnackBar,
        ),
        _buildMenuItem(
          theme,
          icon: Icons.privacy_tip_outlined,
          title: "プライバシーポリシー",
          onTap: _showComingSoonSnackBar,
        ),

        // --- 5. アカウント操作 ---
        _buildMenuSection(theme, ""),
        _buildMenuItem(
          theme,
          icon: Icons.logout,
          title: "ログアウト",
          isDestructive: true,
          onTap: _handleLogout,
        ),

        _buildAppVersion(theme),
        SizedBox(height: 4.h),
      ],
    );
  }

  // プロフィールヘッダー
  Widget _buildProfileHeader(ThemeData theme) {
    final authService = ref.read(firebaseAuthServiceProvider);
    final currentUser = authService.currentUser;

    // 表示優先順位: UserModel > CircleModel > Auth情報
    final String displayName = _myUserData?.userName ?? 
                               _myCircleData?.circleName ?? 
                               currentUser?.displayName ?? 
                               currentUser?.email?.split('@').first ?? 
                               'ゲスト';
                               
    final String email = currentUser?.email ?? '';
    final String? imageUrl = _myUserData?.profileImageUrl ?? _myCircleData?.profileImageUrl;

    return InkWell(
      onTap: () {
         // プロフィール編集へ
         _showComingSoonSnackBar();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(6.w),
        color: theme.colorScheme.surface,
        child: Row(
          children: [
            SafeAvatarWidget(
              imageUrl: imageUrl,
              radius: 8.w,
              backgroundColor: theme.colorScheme.outline.withOpacity(0.3),
              fallback: Icon(Icons.person, size: 8.w, color: Colors.grey),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (email.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(ThemeData theme, String title) {
    if (title.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(6.w, 3.h, 6.w, 1.h),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMenuItem(ThemeData theme, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    return Material(
      color: theme.colorScheme.surface,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: !isDestructive
            ? Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant)
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildAppVersion(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      alignment: Alignment.center,
      child: Text(
        'App Version: $_appVersion',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}