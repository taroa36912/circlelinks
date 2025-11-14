import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart'; // app_export.dart (RiverpodとServiceを含む)

class AppMenuDrawer extends ConsumerStatefulWidget {
  const AppMenuDrawer({super.key});

  @override
  ConsumerState<AppMenuDrawer> createState() => _AppMenuDrawerState();
}

class _AppMenuDrawerState extends ConsumerState<AppMenuDrawer> {
  CircleModel? _myCircleData;
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() { _isLoading = true; });
    
    final authService = ref.read(firebaseAuthServiceProvider);
    final user = authService.currentUser;
    if (user == null) {
      setState(() { _isLoading = false; });
      // ログイン画面に戻す
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
      return;
    }
    _currentUser = user;

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      // ログインユーザーIDに紐づくサークル情報を取得
      final circle = await firestoreService.getCircle(user.uid); 
      if (mounted) {
        setState(() {
          _myCircleData = circle; // 👈 サークルがあればセット、なければ null のまま
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
      // サークルが存在しないのはエラーではないので、ログ出力のみ
      print("Drawer: サークル情報はまだ登録されていません。 $e");
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
    // ドロワーが開いている場合、スナックバーの前にドロワーを閉じる
    Navigator.pop(context); 
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
    
    // サークル情報（_myCircleData）が null かどうかで表示を切り替える
    final bool hasCircle = _myCircleData != null;
    final String displayName = _myCircleData?.circleName ?? _currentUser?.email ?? 'ゲスト';
    final String? profileImageUrl = _myCircleData?.profileImageUrl;

    return Drawer(
      width: 75.w,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // --- 1. プロフィールヘッダー ---
          _buildDrawerHeader(theme, displayName, profileImageUrl, hasCircle),
          
          // ⬇️ --- 修正: サークル作成済みかどうかでメニューを切り替え --- ⬇️

          if (_isLoading) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          ] else if (hasCircle) ...[
            // --- ✅ サークル作成済みのメニュー ---
            _buildMenuSection(theme, "サークル機能"),
            _buildMenuItem(
              theme,
              icon: Icons.group_outlined,
              title: "所属サークル一覧",
              onTap: _showComingSoonSnackBar, // TODO: '/my-circles' ページを実装
            ),
            _buildMenuItem(
              theme,
              icon: Icons.work_outline,
              title: "Myポートフォリオ",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.portfolioBuilder); 
              },
            ),
            _buildMenuItem(
              theme,
              icon: Icons.people_outline,
              title: "コネクション管理",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.connections);
              },
            ),
            _buildMenuItem(
              theme,
              icon: Icons.add_circle_outline,
              title: "イベント作成",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.eventCreation);
              },
            ),

          ] else ...[
            // --- ❌ サークル未作成のメニュー ---
            _buildMenuSection(theme, "はじめに"),
            _buildMenuItem(
              theme,
              icon: Icons.add_business_outlined, // 別のアイコン
              title: "サークルを登録する",
              onTap: () {
                Navigator.pop(context); // ドロワーを閉じる
                Navigator.pushNamed(context, AppRoutes.circleRegistration); // サークル登録画面へ
              },
            ),
            _buildMenuItem(
              theme,
              icon: Icons.search,
              title: "既存のサークルに参加", // 将来的な機能
              onTap: _showComingSoonSnackBar,
            ),
          ],
          
          // --- ⬆️ 修正ここまで ⬆️ ---

          const Divider(),

          // --- 3. アプリ設定 (共通) ---
          _buildMenuSection(theme, "設定"),
          _buildMenuItem(
            theme,
            icon: Icons.notifications_outlined,
            title: "通知設定",
            onTap: _showComingSoonSnackBar,
          ),
          
          // --- 4. サポート (共通) ---
          _buildMenuSection(theme, "サポート"),
          _buildMenuItem(
            theme,
            icon: Icons.help_outline,
            title: "ヘルプ & サポート",
            onTap: _showComingSoonSnackBar,
          ),
          
          const Divider(),

          // --- 5. アカウント操作 (共通) ---
          _buildMenuItem(
            theme,
            icon: Icons.logout,
            title: "ログアウト",
            onTap: _handleLogout,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(ThemeData theme, String displayName, String? profileImageUrl, bool hasCircle) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        displayName,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      accountEmail: Text(
        _currentUser?.email ?? '',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onPrimary.withOpacity(0.8),
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: theme.colorScheme.onPrimary,
        backgroundImage: (profileImageUrl != null) ? NetworkImage(profileImageUrl) : null,
        child: (profileImageUrl == null) 
          ? Icon(
              // サークル未作成の場合はアカウントアイコン、作成済みの場合はグループアイコン
              hasCircle ? Icons.group_outlined : Icons.person_outline, 
              size: 40,
              color: theme.colorScheme.primary,
            ) 
          : null,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
      ),
      onDetailsPressed: () {
        // --- アカウント設定画面へ遷移 ---
        Navigator.pop(context); // ドロワーを閉じる
        _showComingSoonSnackBar(); // TODO: '/account-settings' ページを実装
        // Navigator.pushNamed(context, '/account-settings');
      },
    );
  }
  
  // セクションヘッダー
  Widget _buildMenuSection(ThemeData theme, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // メニュー項目
  Widget _buildMenuItem(ThemeData theme, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: (isDestructive || icon == Icons.logout) 
        ? null 
        : Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}