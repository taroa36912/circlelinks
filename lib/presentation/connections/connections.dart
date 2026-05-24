import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class Connections extends ConsumerStatefulWidget {
  // ⬇️ 引数でサークルIDを受け取るように変更 ⬇️
  final String circleId; 

  const Connections({
    super.key,
    required this.circleId,
  });

  @override
  ConsumerState<Connections> createState() => _ConnectionsState();
}

class _ConnectionsState extends ConsumerState<Connections>
    with TickerProviderStateMixin {
  late TabController _tabController;
  // String? _currentUserId; // 👈 widget.circleId を使うので不要

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // circleId が空ならエラー表示 (通常ありえない)
    if (widget.circleId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('コネクション')),
        body: const Center(child: Text('サークル情報がありません')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('コネクション管理'), // タイトル変更
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: '受信リクエスト'),
            Tab(text: '接続済みサークル'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReceivedRequestsTab(),
          _buildConnectedCirclesTab(),
        ],
      ),
      // ⬇️ 新規追加: コネクションリクエスト送信ボタン ⬇️
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // サークル一覧画面へ遷移 (選択モード)
          Navigator.pushNamed(
            context,
            AppRoutes.circleDiscovery,
            arguments: {
              'isSelectionMode': true, // 選択モードフラグ
              'sourceCircleId': widget.circleId, // リクエスト元サークルID
            },
          );
        },
        label: const Text('コネクションリクエスト'),
        icon: const Icon(Icons.add_link),
      ),
      // ⬆️ ------------------------------------- ⬆️
    );
  }

  Widget _buildReceivedRequestsTab() {
    final firestoreService = ref.read(firestoreServiceProvider);

    // widget.circleId を使用
    return StreamBuilder<List<ConnectionRequestModel>>(
      stream: firestoreService.getReceivedConnectionRequests(widget.circleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('エラーが発生しました: ${snapshot.error}'),
          );
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'inbox',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 64,
                ),
                SizedBox(height: 2.h),
                Text(
                  '受信リクエストがありません',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '他のサークルからのコネクションリクエストがここに表示されます',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(4.w),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRequestCard(request);
          },
        );
      },
    );
  }

  Widget _buildConnectedCirclesTab() {
    final firestoreService = ref.read(firestoreServiceProvider);

    // widget.circleId を使用
    return StreamBuilder<List<ConnectionRequestModel>>(
      stream: firestoreService.getApprovedConnections(widget.circleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('エラーが発生しました: ${snapshot.error}'),
          );
        }

        final connections = snapshot.data ?? [];

        if (connections.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'group',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 64,
                ),
                SizedBox(height: 2.h),
                Text(
                  '接続済みサークルがありません',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'コネクションが承認されると、ここに表示されます',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(4.w),
          itemCount: connections.length,
          itemBuilder: (context, index) {
            final connection = connections[index];
            return _buildConnectedCircleCard(connection);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(ConnectionRequestModel request) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 6.w,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: CustomIconWidget(
                    iconName: 'group',
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.fromCircleName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        request.fromUniversityName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '承認待ち',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'コネクションリクエストを受信しました。承認すると、このサークルとチャットができるようになります。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _declineRequest(request),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                    ),
                    child: const Text('却下'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveRequest(request),
                    child: const Text('承認'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedCircleCard(ConnectionRequestModel connection) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: ListTile(
        leading: CircleAvatar(
          radius: 6.w,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: CustomIconWidget(
            iconName: 'group',
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        title: Text(
          // 自分から見た相手の名前を表示
          (connection.fromCircleId == widget.circleId) 
              ? connection.toCircleName 
              : connection.fromCircleName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
           (connection.fromCircleId == widget.circleId) 
              ? connection.toUniversityName 
              : connection.fromUniversityName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.event, color: Colors.blue),
              tooltip: '合同イベントを作成',
              onPressed: () {
                final otherCircleId = connection.fromCircleId == widget.circleId
                    ? connection.toCircleId
                    : connection.fromCircleId;
                Navigator.pushNamed(
                  context,
                  AppRoutes.eventCreation,
                  arguments: {
                    'circleId': widget.circleId,
                    'mode': 'jointEvent',
                    'preselectedCoOrganizerCircleIds': [otherCircleId],
                  },
                );
              },
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '接続済み',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        onTap: () => _openChat(connection),
      ),
    );
  }

  Future<void> _approveRequest(ConnectionRequestModel request) async {
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateConnectionRequestStatus(
        request.id,
        ConnectionStatus.approved,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${request.fromCircleName} のリクエストを承認しました'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('承認に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _declineRequest(ConnectionRequestModel request) async {
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.deleteConnectionRequest(request.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${request.fromCircleName} のリクエストを却下しました'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('却下に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openChat(ConnectionRequestModel connection) {
    // 相手の情報を特定
    final isMeFrom = connection.fromCircleId == widget.circleId;
    final targetCircleName = isMeFrom ? connection.toCircleName : connection.fromCircleName;
    final targetUniversityName = isMeFrom ? connection.toUniversityName : connection.fromUniversityName;

    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'connectionId': connection.id,
        'circleName': targetCircleName,
        'universityName': targetUniversityName,
      },
    );
  }
}