import 'package:flutter/material.dart';
import '../../core/app_export.dart'; // app_export.dart
// これから作成するマイページ画面
import '../my_page/my_page_screen.dart'; 
// 既存のサークル一覧画面
import '../circle_discovery/circle_discovery.dart'; 

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0; // 現在選択されているタブのインデックス

  // タブで切り替える画面のリスト
  final List<Widget> _pages = [
    const CircleDiscovery(), // 0: サークル一覧
    const MyPageScreen(),    // 1: マイページ (ステップ2で作成)
    // TODO: 将来的にチャット画面などを追加
    // const ChatListScreen(), // 2: チャット
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // 状態を保持したままタブを切り替える
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search), // CustomIconWidgetを使ってもOK
            label: 'サークル一覧',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // CustomIconWidgetを使ってもOK
            label: 'マイページ',
          ),
          // TODO: 将来的にチャットなどを追加
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.chat_bubble_outline),
          //   label: 'チャット',
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.lightTheme.colorScheme.primary, // テーマから色を指定
        unselectedItemColor: Colors.grey, // テーマから色を指定
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // タブが3つ以上でも固定
      ),
    );
  }
}