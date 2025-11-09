import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart'; // app_export.dart (RiverpodとServiceを含む)

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  String? _currentUserId;
  CircleModel? _myCircleData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyData();
  }

  Future<void> _loadMyData() async {
    setState(() { _isLoading = true; });
    
    final authService = ref.read(firebaseAuthServiceProvider);
    final user = authService.currentUser;
    if (user == null) {
      // もしユーザーがいない場合 (万が一)
      setState(() { _isLoading = false; });
      Navigator.of(context).pushReplacementNamed('/login'); // ログイン画面に戻す
      return;
    }

    _currentUserId = user.uid;
    
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      // 自分のAuth IDを元に自分のサークル情報を取得
      final circle = await firestoreService.getCircle(_currentUserId!);
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

  Future<void> _handleLogout() async {
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.signOut();
      
      if (mounted) {
        // ログイン画面に戻り、それまでの画面スタックをすべて削除
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login', (Route<dynamic> route) => false
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: _handleLogout,
          ),
        ],
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myCircleData == null
              ? _buildErrorState() // 自分のサークル情報が見つからない場合
              : _buildProfileView(theme),
    );
  }

  Widget _buildProfileView(ThemeData theme) {
    final circle = _myCircleData!;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 2.h),

            // プロフィールアイコン
            CircleAvatar(
              radius: 12.w,
              backgroundColor: theme.colorScheme.outline.withOpacity(0.3),
              backgroundImage: circle.profileImageUrl != null 
                  ? NetworkImage(circle.profileImageUrl!) 
                  : null,
              child: circle.profileImageUrl == null 
                  ? Icon(Icons.person, size: 12.w, color: Colors.grey)
                  : null,
            ),
            
            SizedBox(height: 1.h),
            
            // プロフィール編集ボタン
            TextButton.icon(
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('プロフィールを編集'),
              onPressed: () {
                // TODO: 編集画面 (例: '/edit-profile') へ遷移
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('（TODO: 編集画面へ遷移）')),
                );
              },
            ),

            SizedBox(height: 3.h),

            // ユーザー名 (サークル名)
            Text(
              circle.circleName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.5.h),
            Text(
              circle.universityName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),
            Divider(height: 1.h),
            SizedBox(height: 3.h),

            // --- 所属サークル情報 ---
            _buildInfoCard(
              theme,
              title: 'あなたのサークル情報',
              children: [
                _buildInfoRow(theme, Icons.info_outline, '説明', circle.description),
                _buildInfoRow(theme, Icons.people_outline, 'メンバー数', '${circle.memberCount}人'),
                _buildInfoRow(theme, Icons.category, 'カテゴリー', circle.category),
              ],
            ),

            SizedBox(height: 3.h),
            
            // --- ポートフォリオビルダーへの導線 ---
            _buildInfoCard(
              theme,
              title: 'ポートフォリオ',
              children: [
                ListTile(
                  leading: CustomIconWidget(iconName: 'work', color: theme.colorScheme.primary, size: 24),
                  title: const Text('ポートフォリオを編集・確認'),
                  subtitle: const Text('あなたの活動実績をまとめましょう'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // portfolio_builder.dart へのルート名
                    Navigator.pushNamed(context, '/portfolio-builder'); 
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, {required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant
                )),
                SizedBox(height: 0.2.h),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

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