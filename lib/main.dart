import 'package:cost_snap/features/screens/loading_screen.dart';
import 'package:cost_snap/features/screens/main_screen.dart';
import 'package:cost_snap/theme/theme.dart';
import 'package:cost_snap/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/screens/onbarding_screen.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const CostSnap());
}

class CostSnap extends StatelessWidget {
  const CostSnap({super.key});

  static const _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeTransitionBuilder(),
      TargetPlatform.windows: FadeTransitionBuilder(),
      TargetPlatform.macOS: FadeTransitionBuilder(),
      TargetPlatform.linux: FadeTransitionBuilder(),
    },
  );

  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) await prefs.setBool('isFirstLaunch', false);
    await Future.delayed(AppConstants.splashDelay);
    return isFirstLaunch;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CostSnap',
      theme: lightTheme.copyWith(pageTransitionsTheme: _pageTransitionsTheme),
      darkTheme:
          darkTheme.copyWith(pageTransitionsTheme: _pageTransitionsTheme),
      themeMode: ThemeMode.system,
      home: FutureBuilder<bool>(
        future: _checkFirstLaunch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FlutterNativeSplash.remove();
          });
          return snapshot.hasData && snapshot.data!
              ? const OnboardingScreen()
              : const MainScreen();
        },
      ),
    );
  }
}

class FadeTransitionBuilder extends PageTransitionsBuilder {
  const FadeTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}
