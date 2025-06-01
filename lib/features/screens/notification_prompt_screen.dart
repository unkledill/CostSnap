import 'package:cost_snap/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../service/notification_service.dart';
import 'main_screen.dart';

class NotificationPromptScreen extends StatefulWidget {
  const NotificationPromptScreen({super.key});

  @override
  _NotificationPromptScreenState createState() =>
      _NotificationPromptScreenState();
}

class _NotificationPromptScreenState extends State<NotificationPromptScreen> {
  bool _notificationsEnabled = true;

  Future<void> _saveNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);

    final notificationService = NotificationService();
    await notificationService.requestPermissions();
    if (_notificationsEnabled) {
      await notificationService.scheduleDailyNotification();
    }

    Get.off(() => const MainScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Stay Engaged with CostSnap!',
                style: csTextTheme().headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Turn on fun daily reminders to snap prices and track deals!',
                style: csTextTheme().bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SwitchListTile(
                title: Text(
                  'Enable Fun Notifications',
                  style: csTextTheme().bodyLarge,
                ),
                subtitle: Text(
                  'Get daily reminders to snap prices!',
                  style: csTextTheme().bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                value: _notificationsEnabled,
                activeColor: AppColors.accent,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveNotificationPreference,
                child: Text(
                  'Continue',
                  style: csTextTheme().labelLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
