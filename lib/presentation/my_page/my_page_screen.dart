import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart'; // app_export.dart (RiverpodとServiceを含む)

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  CircleModel? _myCircleData;
  bool _isLoading = true;
  String _appVersion = '1.0.0'; // ダミーバージョン

  @override
  void initState() {
    super.initState();
    _loadMyData();
    _getAppVersion();
  }

  // アプリのバージョンを取得 (ダミー)
  // TODO: package_info_plus などを導入して動的に取得する
  void _getAppVersion() {
    // このデモでは固定値を表示
    // (PackageInfo.fromPlatform()).then((PackageInfo packageInfo) {
    //   setState(() {
    //     _appVersion = packageInfo.version;
    //   });
    // });
  }

  // 自分のサークル情報をロード
  Future<void> _loadMyData() async {
    setState(() { _isLoading = true; });
    
    final authService = ref.read(firebaseAuthServiceProvider);
    final user = authService.currentUser;
    if (user == null) {
      setState(() { _isLoading = false; });
      Navigator.of(context).pushNamedAndRemoveUntil('/login-screen', (route) => false);
      return;
    }

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final circle = await firestoreService.getCircle(user.uid);
      if (mounted) {
        setState(() {
          _myCircleData = circle;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('自分のサークル情報の取得に失敗しました: $e')),
        );
      }
    }
  }

  // ログアウト処理
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

  // TODO: 未実装機能用のダミーSnackBar
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
      backgroundColor: theme.colorScheme.surfaceContainerLowest, // 背景色を少し変更
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myCircleData == null
              ? _buildErrorState()
              : _buildMenu(theme),
    );
  }

  Widget _buildMenu(ThemeData theme) {
    return ListView(
      children: [
        // --- 1. プロフィール設定 ---
        _buildProfileHeader(theme),
        
        // --- 2. サークル機能 ---
        _buildMenuSection(theme, "サークル活動"),
        _buildMenuItem(
          theme,
          icon: Icons.group_outlined, // 'group' アイコンに変更
          title: "加入サークル一覧",
          subtitle: "あなたが所属・管理するサークル",
          onTap: () {
            // TODO: '/my-circles' ページを新規作成し、AppRoutesに追加する
            _showComingSoonSnackBar(); 
            // Navigator.pushNamed(context, '/my-circles'); 
          },
        ),
        _buildMenuItem(
          theme,
          icon: Icons.work_outline, // 'work' アイコンに変更
          title: "Myポートフォリオ",
          subtitle: "あなたの活動実績を編集・確認",
          onTap: () {
            // portfolio_builder.dart へのルート
            Navigator.pushNamed(context, AppRoutes.portfolioBuilder); 
          },
        ),

        // --- 3. アプリ設定 ---
        _buildMenuSection(theme, "設定"),
        _buildMenuItem(
          theme,
          icon: Icons.notifications_outlined, // 'notifications' アイコンに変更
          title: "通知設定",
          subtitle: "イベントやチャットの通知",
          onTap: _showComingSoonSnackBar,
        ),

        // --- 4. サポート ---
        _buildMenuSection(theme, "サポート"),
        _buildMenuItem(
          theme,
          icon: Icons.help_outline, // 'help' アイコンに変更
          title: "ヘルプ & サポート",
          subtitle: "使い方やFAQ",
          onTap: _showComingSoonSnackBar,
        ),
        _buildMenuItem(
          theme,
          icon: Icons.privacy_tip_outlined, // 'privacy' アイコンに変更
          title: "プライバシーポリシー",
          subtitle: "個人情報の取り扱いについて",
          onTap: _showComingSoonSnackBar,
        ),

        // --- 5. アカウント操作 ---
        _buildMenuSection(theme, "アカウント"),
        _buildMenuItem(
          theme,
          icon: Icons.logout,
          title: "ログアウト",
          isDestructive: true, // 赤色にする
          onTap: _handleLogout,
        ),

        // --- アプリバージョン ---
        _buildAppVersion(theme),
      ],
    );
  }

  // 1. プロフィール設定 (ヘッダー)
  Widget _buildProfileHeader(ThemeData theme) {
    return InkWell(
      onTap: () {
        // TODO: '/profile-settings' ページを新規作成し、AppRoutesに追加する
        _showComingSoonSnackBar();
        // Navigator.pushNamed(context, '/profile-settings');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(6.w),
        color: theme.colorScheme.surface,
        child: Row(
          children: [
            CircleAvatar(
              radius: 8.w,
              backgroundColor: theme.colorScheme.outline.withOpacity(0.3),
              backgroundImage: _myCircleData!.profileImageUrl != null
                  ? NetworkImage(_myCircleData!.profileImageUrl!)
                  : null,
              child: _myCircleData!.profileImageUrl == null
                  ? Icon(Icons.person, size: 8.w, color: Colors.grey)
                  : null,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _myCircleData!.circleName, // ユーザー名/サークル名
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _myCircleData!.email, // メールアドレス
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // メニューのセクションヘッダー
  Widget _buildMenuSection(ThemeData theme, String title) {
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

  // メニュー項目
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

  // アプリバージョン
  Widget _buildAppVersion(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      alignment: Alignment.center,
      child: Text(
        'App Version: $_appVersion',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  // エラー表示
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            SizedBox(height: 2.h),
            const Text(
              'サークル情報が見つかりません',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            const Text(
              'このアカウントに紐づくサークル情報が登録されていないようです。',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _handleLogout,
              child: const Text('ログアウトしてやり直す'),
            ),
          ],
        ),
      ),
    );
  }
}