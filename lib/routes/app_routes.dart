import 'package:flutter/material.dart'; // 👈 ここのタイプミスを修正 (package.flutter -> package:flutter)
import '../presentation/event_creation/event_creation.dart';
import '../presentation/circle_profile/circle_profile.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/event_details/event_details.dart';
import '../presentation/circle_discovery/circle_discovery.dart';
import '../presentation/circle_registration/circle_registration.dart';
import '../presentation/connections/connections.dart';
import '../presentation/chat/chat.dart';
import '../presentation/portfolio_builder/portfolio_builder.dart';
import '../presentation/my_page/my_page_screen.dart'; // マイページ画面

class AppRoutes {
  // 既存のルート
  static const String initial = '/';
  static const String eventCreation = '/event-creation';
  static const String circleProfile = '/circle-profile';
  static const String login = '/login-screen';
  static const String eventDetails = '/event-details';
  static const String circleDiscovery = '/circle-discovery';
  static const String circleRegistration = '/circle-registration';
  static const String connections = '/connections';
  static const String chat = '/chat';
  
  // 新規追加
  static const String portfolioBuilder = '/portfolio-builder';
  static const String myPage = '/my-page';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    login: (context) => const LoginScreen(),
    
    // メイン機能
    circleDiscovery: (context) => const CircleDiscovery(),
    circleProfile: (context) => const CircleProfile(),
    circleRegistration: (context) => const CircleRegistration(),

    // 新規追加
    myPage: (context) => const MyPageScreen(),
    portfolioBuilder: (context) => const PortfolioBuilder(),
    
    // サブ機能
    eventCreation: (context) => const EventCreation(),
    eventDetails: (context) => const EventDetails(),
    connections: (context) => const Connections(),
    chat: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      // 既存の引数処理を維持
      return ChatScreen(connectionId: args?['connectionId'] ?? '');
    },
  };
}