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
import '../presentation/circle_admin/circle_management_screen.dart';
import '../presentation/circle_admin/circle_dm_list_screen.dart';
import '../presentation/circle_admin/my_circles_list_screen.dart';
import '../presentation/dm_chat/dm_chat_screen.dart';
import '../presentation/dm_list/dm_list_screen.dart';
import '../core/models/circle_model.dart';
import '../presentation/profile_settings/profile_settings_screen.dart';
import '../presentation/event_management/event_management_screen.dart'; // New
import '../presentation/event/qr_scan_screen.dart'; // New
import '../presentation/event/event_list_screen.dart';
import '../presentation/login_screen/forgot_password_screen.dart';
import '../presentation/profile/portfolio_screen.dart'; // New
import '../presentation/joined_circles/joined_circles_screen.dart'; // New
import '../presentation/bulletin_board/project_list_screen.dart';
import '../presentation/bulletin_board/project_creation_screen.dart';
import '../presentation/bulletin_board/project_details_screen.dart';
import '../presentation/recruitment/recruitment_list_screen.dart';
import '../presentation/recruitment/recruitment_creation_screen.dart';
import '../presentation/recruitment/recruitment_details_screen.dart';
import '../presentation/recruitment/recruitment_management_screen.dart';
import '../presentation/recruitment/recruitment_applications_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String eventCreation = '/event-creation';
  static const String circleProfile = '/circle-profile';
  static const String login = '/login-screen';
  static const String forgotPassword = '/forgot-password';
  static const String eventDetails = '/event-details';
  static const String circleDiscovery = '/circle-discovery';
  static const String circleRegistration = '/circle-registration';
  static const String connections = '/connections';
  static const String chat = '/chat';

  static const String portfolioBuilder = '/portfolio-builder';
  static const String myPage = '/my-page';
  static const String signup = '/signup';
  static const String dmChat = '/dm-chat';
  static const String dmList = '/dm-list';

  static const String myCirclesList = '/my-circles-list';
  static const String circleManagement = '/circle-management';
  static const String circleDmList = '/circle-dm-list';
  static const String profileSettings = '/profile-settings';
  static const String eventManagement = '/event-management'; // New
  static const String eventList = '/event-list';
  static const String qrScan = '/qr-scan'; // New
  static const String portfolio = '/portfolio'; // New
  static const String joinedCircles = '/joined-circles'; // New
  static const String projectList = '/project-list';
  static const String projectCreation = '/project-creation';
  static const String projectDetails = '/project-details';
  static const String recruitmentList = '/recruitments';
  static const String recruitmentCreation = '/recruitment-creation';
  static const String recruitmentDetails = '/recruitment-details';
  static const String recruitmentManagement = '/recruitment-management';
  static const String recruitmentApplications = '/recruitment-applications';

  static const String circleAdmin = myCirclesList;

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    login: (context) => const LoginScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    signup: (context) => const SignupScreen(),

    circleDiscovery: (context) => const CircleDiscovery(),
    circleProfile: (context) => const CircleProfile(),
    circleRegistration: (context) => const CircleRegistration(),

    myPage: (context) => const MyPageScreen(),
    portfolioBuilder: (context) => const PortfolioBuilder(),

    dmList: (context) => const DmListScreen(),

    myCirclesList: (context) => const MyCirclesListScreen(),

    circleManagement: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final circle = args?['circle'] as CircleModel;
      return CircleManagementScreen(circle: circle);
    },

    circleDmList: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return CircleDmListScreen(circleId: args?['circleId'] ?? '');
    },

    dmChat: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return DmChatScreen(
        dmChannelId: args?['dmChannelId'] ?? '',
        recipientName: args?['recipientName'] ?? 'チャット',
        // ⬇️ 修正: isCircleAdmin を引数から受け取るように追加
        isCircleAdmin: args?['isCircleAdmin'] ?? false,
      );
    },

    profileSettings: (context) => const ProfileSettingsScreen(),
    eventCreation: (context) => const EventCreation(),
    eventDetails: (context) => const EventDetails(),
    eventManagement: (context) => const EventManagementScreen(), // New
    eventList: (context) => const EventListScreen(),
    qrScan: (context) => const QRScanScreen(), // New
    portfolio: (context) => const PortfolioScreen(), // New
    joinedCircles: (context) => const JoinedCirclesScreen(), // New
    projectList: (context) => const ProjectListScreen(),
    projectCreation: (context) => const ProjectCreationScreen(),
    projectDetails: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return ProjectDetailsScreen(projectId: args?['projectId'] ?? '');
    },

    // ⬇️ --- 修正: connections ルートを追加 (引数を受け取る) --- ⬇️
    connections: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      // サークル管理画面から circleId が渡される
      return Connections(circleId: args?['circleId'] ?? '');
    },
    // ⬆️ --------------------------------------------------- ⬆️

    chat: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return ChatScreen(connectionId: args?['connectionId'] ?? '');
    },

    recruitmentList: (context) => const RecruitmentListScreen(),
    recruitmentCreation: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return RecruitmentCreationScreen(circleId: args?['circleId'] ?? '');
    },
    recruitmentDetails: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return RecruitmentDetailsScreen(
          recruitmentId: args?['recruitmentId'] ?? '');
    },
    recruitmentManagement: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return RecruitmentManagementScreen(circleId: args?['circleId'] ?? '');
    },
    recruitmentApplications: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return RecruitmentApplicationsScreen(
        circleId: args?['circleId'] ?? '',
        recruitmentId: args?['recruitmentId'],
      );
    },
  };
}
