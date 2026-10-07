import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/audio_player_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/navigation_provider.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HiveMuseApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class HiveMuseApp extends StatelessWidget {
  const HiveMuseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'HiveMuse - Sonic Journey',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        scrollBehavior: const AppScrollBehavior(),
        home: Consumer<NavigationProvider>(
          builder: (context, navProvider, child) {
            if (!navProvider.hasCompletedOnboarding) {
              return const OnboardingScreen();
            }
            return const MainShellScreen();
          },
        ),
      ),
    );
  }
}
