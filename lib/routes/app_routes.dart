import 'package:flutter/material.dart';
import '../presentation/event_creation/event_creation.dart';
import '../presentation/circle_profile/circle_profile.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/event_details/event_details.dart';
import '../presentation/circle_discovery/circle_discovery.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String portfolioBuilder = '/portfolio-builder';
  static const String eventCreation = '/event-creation';
  static const String circleProfile = '/circle-profile';
  static const String login = '/login-screen';
  static const String eventDetails = '/event-details';
  static const String circleDiscovery = '/circle-discovery';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    eventCreation: (context) => const EventCreation(),
    circleProfile: (context) => const CircleProfile(),
    login: (context) => const LoginScreen(),
    eventDetails: (context) => const EventDetails(),
    circleDiscovery: (context) => const CircleDiscovery(),
    // TODO: Add your other routes here
  };
}
