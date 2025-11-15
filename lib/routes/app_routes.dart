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
import '../presentation/my_page/my_page_screen.dart';
import '../presentation/signup_screen/signup_screen.dart';
import '../presentation/circle_admin/circle_admin_screen.dart';
import '../presentation/dm_chat/dm_chat_screen.dart';
import '../presentation/dm_list/dm_list_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String eventCreation = '/event-creation';
  static const String circleProfile = '/circle-profile';
  static const String login = '/login-screen';
  static const String eventDetails = '/event-details';
  static const String circleDiscovery = '/circle-discovery';
  static const String circleRegistration = '/circle-registration';
  static const String connections = '/connections';
  static const String chat = '/chat';
  static const String portfolioBuilder = '/portfolio-builder';
  static const String myPage = '/my-page';
  static const String signup = '/signup';
  static const String circleAdmin = '/circle-admin';
  static const String dmChat = '/dm-chat';
  static const String dmList = '/dm-list';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),

    circleDiscovery: (context) => const CircleDiscovery(),
    circleProfile: (context) => const CircleProfile(),
    circleRegistration: (context) => const CircleRegistration(),

    myPage: (context) => const MyPageScreen(),
    portfolioBuilder: (context) => const PortfolioBuilder(),

    circleAdmin: (context) =>
        const CircleAdminScreen(),
    dmChat: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return DmChatScreen(
        dmChannelId: args?['dmChannelId'] ?? '',
        recipientName: args?['recipientName'] ?? 'チャット',
      );
    },

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
