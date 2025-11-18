import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart'; 
import '../../routes/app_routes.dart';
import '../../core/models/user_model.dart';

class AppMenuDrawer extends ConsumerStatefulWidget {
  const AppMenuDrawer({super.key});

  @override
  ConsumerState<AppMenuDrawer> createState() => _AppMenuDrawerState();
}

class _AppMenuDrawerState extends ConsumerState<AppMenuDrawer> {
  CircleModel? _myCircleData;
  UserModel? _myUserData;
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
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
      return;
    }
    _currentUser = user;

    final firestoreService = ref.read(firestoreServiceProvider);
    
    try {
      final userData = await firestoreService.getUser(user.uid);
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
      }
      print("Drawer: データ取得エラー $e");
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
    // ⬇️ 修正: ここにあった Navigator.pop(context) を削除しました (二重pop防止)
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
    
    final bool hasCircle = _myCircleData != null;
    final String displayName = _myUserData?.userName ?? _currentUser?.email ?? 'ゲスト';
    final String? profileImageUrl = _myUserData?.profileImageUrl;

    return Drawer(
      width: 75.w, 
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(theme, displayName, profileImageUrl, hasCircle),
          
          if (_isLoading) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          ] else ...[
            
            // ⬇️ --- 復活: DM一覧 (共通) --- ⬇️
            _buildMenuSection(theme, "メッセージ"),
            _buildMenuItem(
              theme,
              icon: Icons.chat_bubble_outline,
              title: "DM一覧",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.dmList); 
              },
            ),
            // ⬆️ ---------------------- ⬆️

            if (hasCircle) ...[
              // --- ✅ サークル作成済みのメニュー ---
              _buildMenuSection(theme, "サークル機能"),
              _buildMenuItem(
                theme,
                icon: Icons.admin_panel_settings_outlined, 
                title: "サークル管理",
                onTap: () {
                  Navigator.pop(context); 
                  Navigator.pushNamed(context, AppRoutes.myCirclesList);
                },
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
                title: "サークル間コネクション",
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
                icon: Icons.add_business_outlined, 
                title: "サークルを登録する", // 👈 これが消えていたと言われたボタンです
                onTap: () {
                  Navigator.pop(context); 
                  Navigator.pushNamed(context, AppRoutes.circleRegistration); 
                },
              ),
            ],
          ],
          
          const Divider(),

          // --- アカウントと設定 (共通) ---
          _buildMenuSection(theme, "アカウントと設定"),
          _buildMenuItem(
            theme,
            icon: Icons.account_circle_outlined,
            title: "プロフィール設定",
            onTap: () {
              Navigator.pop(context); // ドロワーを閉じる (1回だけ)
              // ⬇️ プロフィール設定画面へ遷移 (現在はSnackBar)
              _showComingSoonSnackBar(); 
            },
          ),
          _buildMenuItem(
            theme,
            icon: Icons.notifications_outlined,
            title: "通知設定",
            onTap: () {
              Navigator.pop(context);
              _showComingSoonSnackBar();
            },
          ),
          
          _buildMenuSection(theme, "サポート"),
          _buildMenuItem(
            theme,
            icon: Icons.help_outline,
            title: "ヘルプ & サポート",
            onTap: () {
              Navigator.pop(context);
              _showComingSoonSnackBar();
            },
          ),
          
          const Divider(),

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

  // ... (Header, Section, Item ビルダーは変更なし) ...
  Widget _buildDrawerHeader(ThemeData theme, String displayName, String? profileImageUrl, bool hasCircle) {
    return UserAccountsDrawerHeader(
      accountName: Text(displayName, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w600,),),
      accountEmail: Text(_currentUser?.email ?? '', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.8),),),
      currentAccountPicture: CircleAvatar(
        backgroundColor: theme.colorScheme.onPrimary,
        backgroundImage: (profileImageUrl != null) ? NetworkImage(profileImageUrl) : null,
        child: (profileImageUrl == null) ? Icon(hasCircle ? Icons.group_outlined : Icons.person_outline, size: 40, color: theme.colorScheme.primary,) : null,
      ),
      decoration: BoxDecoration(color: theme.colorScheme.primary,),
      onDetailsPressed: () {
        Navigator.pop(context); 
        _showComingSoonSnackBar(); 
      },
    );
  }
  Widget _buildMenuSection(ThemeData theme, String title) {
    return Padding(padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h), child: Text(title.toUpperCase(), style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7), fontWeight: FontWeight.w600, letterSpacing: 0.8,),),);
  }
  Widget _buildMenuItem(ThemeData theme, {required IconData icon, required String title, required VoidCallback onTap, bool isDestructive = false,}) {
    final color = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    return ListTile(leading: Icon(icon, color: color, size: 24), title: Text(title, style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w500,),), trailing: (isDestructive || icon == Icons.logout) ? null : Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant), onTap: onTap,);
  }
}