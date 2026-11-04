import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  // Make sure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode — trading apps are portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make status bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF111827),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    // ProviderScope wraps the whole app
    // This enables Riverpod state management everywhere
    const ProviderScope(
      child: ApexTradeApp(),
    ),
  );
}

class ApexTradeApp extends ConsumerWidget {
  const ApexTradeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get our router from Riverpod
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // App identity
      title: 'Emtifize AI Demo',
      debugShowCheckedModeBanner: false,

      // Our premium dark theme
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,

      // GoRouter handles all navigation
      routerConfig: router,
    );
  }
}