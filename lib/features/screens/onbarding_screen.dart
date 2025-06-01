import 'package:animated_text_kit/animated_text_kit.dart';
//
import 'package:cost_snap/theme/theme.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/const.dart';
import 'notification_prompt_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    Get.off(() => const NotificationPromptScreen());
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
                    .copyWith(fontSize: screenWidth * 0.2),
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
                onPressed: _completeOnboarding,
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
