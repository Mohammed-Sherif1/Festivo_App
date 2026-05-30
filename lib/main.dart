import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers/app_providers.dart';
import 'firebase/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/customer/screens/customer_shell.dart';
import 'features/splash/splash_screen.dart';

class FestivoScrollBehavior extends ScrollBehavior {
  const FestivoScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: FestivoApp()));
}

class FestivoApp extends ConsumerWidget {
  const FestivoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => ScrollConfiguration(
        behavior: const FestivoScrollBehavior(),
        child: child!,
      ),
      home: const SplashScreenV2(),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomerShell();
  }
}

