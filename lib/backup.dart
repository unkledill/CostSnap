// // import 'package:cost_snap/theme/theme.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_native_splash/flutter_native_splash.dart';
// // import 'package:get/get.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'features/screens/main_screen.dart';
// // import 'features/screens/onbarding_screen.dart';

// // void main() {
// //   WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
// //   FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
// //   runApp(CostSnap());
// // }

// // class CostSnap extends StatelessWidget {
// //   const CostSnap({super.key});

// //   Future<bool> _checkFirstLaunch() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
// //     if (isFirstLaunch) await prefs.setBool('isFirstLaunch', false);
// //     await Future.delayed(Duration(seconds: 1));
// //     return isFirstLaunch;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GetMaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       title: 'CostSnap',
// //       theme: lightTheme.copyWith(
// //         pageTransitionsTheme: PageTransitionsTheme(
// //           builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
// //             TargetPlatform.values,
// //             value: (_) => const FadeForwardsPageTransitionsBuilder(),
// //           ),
// //         ),
// //       ),
// //       darkTheme: darkTheme.copyWith(
// //         pageTransitionsTheme: PageTransitionsTheme(
// //           builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
// //             TargetPlatform.values,
// //             value: (_) => const FadeForwardsPageTransitionsBuilder(),
// //           ),
// //         ),
// //       ),
// //       home: FutureBuilder<bool>(
// //         future: _checkFirstLaunch(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return Container();
// //           }

// //           WidgetsBinding.instance.addPostFrameCallback((_) {
// //             FlutterNativeSplash.remove();
// //           });
// //           if (snapshot.hasData && snapshot.data!) {
// //             return OnboardingScreen();
// //           }
// //           return MainScreen();
// //         },
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';

// class NumberTextInputFormatter extends TextInputFormatter {
//   final NumberFormat _formatter =
//       NumberFormat.decimalPattern('en_US'); // Comma separator

//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     if (newValue.text.isEmpty) {
//       return newValue;
//     }

//     // Remove non-numeric characters except decimal point
//     String cleaned = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
//     if (cleaned.isEmpty) {
//       return newValue.copyWith(text: '');
//     }

//     // Parse and format the number
//     double? value = double.tryParse(cleaned);
//     if (value == null) {
//       return oldValue; // Invalid input, revert to old value
//     }

//     String formatted = _formatter.format(value);
//     return newValue.copyWith(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//   }

//   // Utility to parse formatted string back to double
//   static double parse(String formatted) {
//     String cleaned = formatted.replaceAll(',', '');
//     return double.parse(cleaned);
//   }
// }

// // Scaffold(
// //       body: IndexedStack(
// //         index: _currentIndex,
// //         children: screens,
// //       ),
// //       bottomNavigationBar: BottomAppBar(
// //         color: Theme.of(context).colorScheme.onSurface,
// //         elevation: 8,
// //         shape: CircularNotchedRectangle(),
// //         notchMargin: 8.0,
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceAround,
// //           children: [
// //             _navBar(
// //               label: 'Home',
// //               activeIcon: 'assets/images/a.home.png',
// //               inactiveIcon: 'assets/images/in.home.png',
// //               index: 0,
// //               onTap: () => setState(() => _currentIndex = 0),
// //             ),
// //             SizedBox(width: 48),
// //             _navBar(
// //               label: 'Settings',
// //               activeIcon: 'assets/images/a.settings.png',
// //               inactiveIcon: 'assets/images/in.settings.png',
// //               index: 1,
// //               onTap: () => setState(() => _currentIndex = 1),
// //             ),
// //           ],
// //         ),
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         backgroundColor: AppColors.accent,
// //         shape: CircleBorder(),
// //         elevation: 0,
// //         onPressed: _addItem,
// //         child: Icon(CupertinoIcons.camera_fill),
// //       ),
// //       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
// //     );

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cost_snap/features/screens/loading_screen.dart';
import 'package:cost_snap/features/screens/main_screen.dart';
import 'package:cost_snap/theme/theme.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/const.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _startApp() async {
    Get.to(() => LoadingScreen(),
        transition: Transition.fadeIn, duration: Duration(milliseconds: 500));
    await Future.delayed(Duration(milliseconds: 1500));
    Get.offAll(
      () => MainScreen(),
      transition: Transition.fadeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/cs icon 2.png',
          height: screenWidth * 0.1,
          width: screenWidth * 0.1,
          color: AppColors.textPrimary,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.mediumSpacing),
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/images/onb_1.png',
                  fit: BoxFit.contain,
                ),
              ),
              DefaultTextStyle(
                style: csTextTheme()
                    .displayLarge!
                    .copyWith(fontSize: screenWidth * 0.1),
                child: AnimatedTextKit(
                  isRepeatingAnimation: false,
                  totalRepeatCount: 1,
                  pause: const Duration(seconds: 3),
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Snap. Tag. Track. Save',
                      speed: const Duration(milliseconds: 150),
                      curve: Curves.easeIn,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.largeSpacing),
              ElevatedButton(
                onPressed: _startApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size(double.infinity, screenWidth * 0.15),
                ),
                child: Text(
                  'Get Started',
                  style: csTextTheme()
                      .labelLarge
                      ?.copyWith(color: AppColors.background),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
