import 'package:flutter/material.dart';
import '../../core/app_export.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  // In a real app, we would query events where userId matches and status is attended.
  // Since FirestoreService doesn't have a specific "getAttendancesForUser" yet, 
  // we might need to add it or just mock it for now.
  // Actually, let's just show a placeholder or add the query to FirestoreService quickly.
  
  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(firebaseAuthServiceProvider);
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('活動ポートフォリオ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             // Placeholder for now as query is complex
             Text('User: ${user.email}'),
             const SizedBox(height: 20),
             const Text('実装予定: 参加イベント履歴の表示'),
             const Text('(Firestoreクエリの追加が必要)'),
          ],
        ),
      ),
    );
  }
}
