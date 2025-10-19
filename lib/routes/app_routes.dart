import 'package:flutter/material.dart';
import '../presentation/event_creation/event_creation.dart';
import '../presentation/circle_profile/circle_profile.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/event_details/event_details.dart';
import '../presentation/circle_discovery/circle_discovery.dart';
import '../presentation/circle_registration/circle_registration.dart';
import '../presentation/connections/connections.dart';
import '../presentation/chat/chat.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String portfolioBuilder = '/portfolio-builder';
  static const String eventCreation = '/event-creation';
  static const String circleProfile = '/circle-profile';
  static const String login = '/login-screen';
  static const String eventDetails = '/event-details';
  static const String circleDiscovery = '/circle-discovery';
  static const String circleRegistration = '/circle-registration';
  static const String connections = '/connections';
  static const String chat = '/chat';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    eventCreation: (context) => const EventCreation(),
    circleProfile: (context) => const CircleProfile(),
    login: (context) => const LoginScreen(),
    eventDetails: (context) => const EventDetails(),
    circleDiscovery: (context) => const CircleDiscovery(),
    circleRegistration: (context) => const CircleRegistration(),
    connections: (context) => const Connections(),
    chat: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return ChatScreen(connectionId: args?['connectionId'] ?? '');
    },
    // TODO: Add your other routes here
  };
}
