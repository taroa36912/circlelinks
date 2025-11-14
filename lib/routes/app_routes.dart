import 'package:flutter/material.dart';
import '../presentation/event_creation/event_creation.dart';
import '../presentation/circle_profile/circle_profile.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/event_details/event_details.dart';
import '../presentation/circle_discovery/circle_discovery.dart';
import '../presentation/circle_registration/circle_registration.dart';
import '../presentation/connections/connections.dart';
import '../presentation/chat/chat.dart';
import '../presentation/portfolio_builder/portfolio_builder.dart';
import '../presentation/my_page/my_page_screen.dart'; // MyPage (旧)
import '../presentation/sign_up_screen/sign_up_screen.dart'; // 👈 新規追加

class AppRoutes {
  // 既存のルート
  static const String initial = '/';
  static const String eventCreation = '/event-creation';
  static const String circleProfile = '/circle-profile';
  static const String login = '/login-screen'; // 👈 '/login' ではなく '/login-screen'
  static const String eventDetails = '/event-details';
  static const String circleDiscovery = '/circle-discovery';
  static const String circleRegistration = '/circle-registration';
  static const String connections = '/connections';
  static const String chat = '/chat';
  
  static const String portfolioBuilder = '/portfolio-builder';
  
  // ⬇️ 修正 ⬇️
  static const String myPage = '/my-page'; // Drawerがこれに代わる
  static const String signup = '/signup';   // 👈 新規追加

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(), // 👈 新規追加
    
    // メイン機能
    circleDiscovery: (context) => const CircleDiscovery(),
    circleProfile: (context) => const CircleProfile(),
    circleRegistration: (context) => const CircleRegistration(), // サークル作成画面として

    // ⬇️ 'myPage' はDrawerになったので、このルートは削除してもよい (今回は残します)
    myPage: (context) => const MyPageScreen(), 
    portfolioBuilder: (context) => const PortfolioBuilder(),
    
    // サブ機能
    eventCreation: (context) => const EventCreation(),
    eventDetails: (context) => const EventDetails(),
    connections: (context) => const Connections(),
    chat: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return ChatScreen(connectionId: args?['connectionId'] ?? '');
    },
  };
}