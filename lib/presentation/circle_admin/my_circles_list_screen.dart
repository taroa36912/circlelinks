import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class MyCirclesListScreen extends ConsumerStatefulWidget {
  const MyCirclesListScreen({super.key});

  @override
  ConsumerState<MyCirclesListScreen> createState() => _MyCirclesListScreenState();
}

class _MyCirclesListScreenState extends ConsumerState<MyCirclesListScreen> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = ref.read(firebaseAuthServiceProvider).currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('サークル管理')),
        body: const Center(child: Text('ログインが必要です')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '管理サークル一覧',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _buildCircleList(theme),
    );
  }

  Widget _buildCircleList(ThemeData theme) {
    final firestoreService = ref.read(firestoreServiceProvider);

    return StreamBuilder<List<CircleModel>>(
      stream: firestoreService.getMyCircles(_currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('エラー: ${snapshot.error}'));
        }
        
        final circles = snapshot.data ?? [];

        if (circles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group_off, size: 60, color: Colors.grey),
                SizedBox(height: 2.h),
                const Text('管理しているサークルがありません'),
                TextButton(
                  onPressed: () {
                    // サークル登録画面へ
                    Navigator.pushNamed(context, AppRoutes.circleRegistration);
                  },
                  child: const Text('サークルを新規登録する'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(4.w),
          itemCount: circles.length,
          itemBuilder: (context, index) {
            final circle = circles[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 2.h),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: circle.profileImageUrl != null
                      ? NetworkImage(circle.profileImageUrl!)
                      : null,
                  child: circle.profileImageUrl == null
                      ? const Icon(Icons.group)
                      : null,
                ),
                title: Text(
                  circle.circleName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(circle.universityName),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // 個別の管理画面へ遷移
                  Navigator.pushNamed(
                    context,
                    AppRoutes.circleManagement,
                    arguments: {'circle': circle}, // CircleModel全体を渡す
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}