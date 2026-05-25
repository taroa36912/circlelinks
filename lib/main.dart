import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://hynvsvxoonoytskfsqlx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh5bnZzdnhvb25veXRza2ZzcWx4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5NjUwMDQsImV4cCI6MjA4ODU0MTAwNH0.92jOQ0-rcp6ZLShdUc3A5xRu5W5qjGvTPM7doZt8ftU',
  );

  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    // Replace with the actual LINE Channel ID before release.
    await LineSDK.instance.setup("2008357841").catchError((e) {
      print("LINE SDK Setup Error: $e");
    });

    Stripe.publishableKey = 'pk_test_51TTIwnBleRjLMsIdW0gGeiVECiXZXTKmiNkXQNK73eR2WvSHwkJhQnB4wSAExZ5ohYdQ3Bt8H4OhDwnafX3SPMsZ00537Q9eK5';
    await Stripe.instance.applySettings();
  }

  bool hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!hasShownError) {
      hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        hasShownError = false;
      });

      return CustomErrorWidget(
        errorDetails: details,
      );
    }
    return SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'circlelink',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        builder: (context, child) {
          if (child == null) return const SizedBox.shrink();

          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child,
          );
        },
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.initial,
      );
    });
  }
}
