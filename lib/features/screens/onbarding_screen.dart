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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/cs icon 2.png',
          height: 40,
          width: 40,
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                // Wrap Image.asset in Expanded to prevent overflow
                child: Image.asset(
                  'assets/images/onb_1.png',
                  fit: BoxFit
                      .contain, // Changed to contain for proportional scaling
                  width: double.infinity, // Use full available width
                ),
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
              Gap(25),
              ElevatedButton(
                onPressed: _startApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size(double.infinity, 75),
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
