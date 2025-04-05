import 'package:cost_snap/features/screens/loading_screen.dart';
import 'package:cost_snap/features/screens/main_screen.dart';
import 'package:cost_snap/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:gap/gap.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _startApp() async {
    // Show loading screen immediately
    Get.to(() => LoadingScreen(),
        transition: Transition.fadeIn, duration: Duration(milliseconds: 500));
    // Wait 1.5 seconds (adjust as needed)
    await Future.delayed(Duration(milliseconds: 1500));
    // Navigate to HomeScreen, replacing all previous screens
    Get.offAll(
      () => MainScreen(),
      transition: Transition.fadeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/cs icon 2.png',
          height: 50,
          width: 50,
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Image.asset(
                'assets/images/onb_1.png',
                width: 450,
                height: 450,
                fit: BoxFit.cover,
              ),

              DefaultTextStyle(
                style: csTextTheme().displayLarge!.copyWith(fontSize: 45),
                child: AnimatedTextKit(
                  repeatForever: false,
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
              // Text(
              //   'Never lose track of your Expenses Again',
              //   style: csTextTheme().displayLarge?.copyWith(fontSize: 35),
              //   // textAlign: TextAlign.center,
              // ),
              // Gap(10),
              // Text(
              //   'Take a pic, add the price, then watch savings unfold',
              //   style: csTextTheme()
              //       .bodyLarge
              //       ?.copyWith(color: AppColors.textSecondary),
              //   textAlign: TextAlign.center,
              // ),
              Gap(35),
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 24),
        child: ElevatedButton(
          onPressed: _startApp,
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 75)),
          child: Text(
            'Get Started',
            style:
                csTextTheme().labelLarge?.copyWith(color: AppColors.background),
          ),
        ),
      ),
    );
  }
}
