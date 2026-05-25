import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class JoinedCirclesScreen extends ConsumerStatefulWidget {
  const JoinedCirclesScreen({super.key});

  @override
  ConsumerState<JoinedCirclesScreen> createState() =>
      _JoinedCirclesScreenState();
}

class _JoinedCirclesScreenState extends ConsumerState<JoinedCirclesScreen> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = ref.read(firebaseAuthServiceProvider).currentUser?.uid;
  }

  // 自分が所属している（admin or member）サークルを取得するStream
  Stream<List<CircleModel>> _getJoinedCirclesStream(String userId) {
    return FirebaseFirestore.instance
        .collectionGroup('members')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap<List<CircleModel>>((snapshot) async {
          final circleIds = snapshot.docs
              .map((doc) => doc.reference.parent.parent?.id)
              .whereType<String>()
              .toList();

          if (circleIds.isEmpty) return [];

          try {
            final circlesSnapshot = await FirebaseFirestore.instance
                .collection('circles')
                .where(FieldPath.documentId, whereIn: circleIds.take(30).toList())
                .get();

            final circles = circlesSnapshot.docs
                .map((doc) => CircleModel.fromFirestore(doc))
                .toList();

            circles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return circles;
          } catch (e) {
            print("🔥 ERROR in fetching joined circle details: $e");
            return [];
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('所属サークル')),
        body: const Center(child: Text('ログインが必要です')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '所属サークル一覧',
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
    return StreamBuilder<List<CircleModel>>(
      stream: _getJoinedCirclesStream(_currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // ⬇️ 修正箇所: Text を SelectableText に変更 ⬇️
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: SelectableText(
                'エラーが発生しました。以下のリンクをコピーしてブラウザで開いてください:\n\n${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        // ⬆️ 修正ここまで ⬆️
        
        final circles = snapshot.data ?? [];

        if (circles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off, size: 15.w, color: Colors.grey),
                SizedBox(height: 2.h),
                const Text('現在所属しているサークルはありません'),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.circleDiscovery);
                  },
                  child: const Text('サークルを探す'),
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
                leading: SafeAvatarWidget(
                  imageUrl: circle.profileImageUrl,
                  radius: 20,
                  fallback: const Icon(Icons.group),
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
                  Navigator.pushNamed(
                    context,
                    AppRoutes.circleProfile,
                    arguments: {'circleId': circle.id},
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