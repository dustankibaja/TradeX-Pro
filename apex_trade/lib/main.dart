import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'features/engine_status/engine_status_screen.dart';
import 'features/desktop_onboarding/desktop_onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform != TargetPlatform.windows) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bg0,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const EmtifizeApp());
}

/// Single-purpose private DEMO bot console. No fabricated trading features.
class EmtifizeApp extends StatelessWidget {
  const EmtifizeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emtifize AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: defaultTargetPlatform == TargetPlatform.windows
          ? const DesktopOnboardingScreen()
          : const EngineStatusScreen(),
    );
  }
}
