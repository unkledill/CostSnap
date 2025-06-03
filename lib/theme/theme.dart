import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary =
      Color(0xFF4A90E2); // Soft Blue for primary elements
  static const Color background =
      Color(0xFFF5F6F5); // Light Gray for backgrounds
  static const Color accent = Color(0xFF50C878); // Teal for accents and buttons
  static const Color textPrimary =
      Color(0xFF212121); // Dark Gray for primary text
  static const Color textSecondary =
      Color(0xFF757575); // Medium Gray for secondary text
}

TextTheme csTextTheme() {
  return TextTheme(
    displaySmall: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      // Remove hardcoded color
    ),
    displayLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      // Remove hardcoded color
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      // Remove hardcoded color
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      // Remove hardcoded color
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      // Remove hardcoded color
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      // Remove hardcoded color
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      // Remove hardcoded color
    ),
  );
}

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    onPrimary: Colors.white,
    onSecondary: Colors.white, // Changed for better contrast
    surface: AppColors.background,
    onSurface: AppColors.textPrimary, // Primary text color for light mode
    outline: Colors.black45,
    primaryContainer: Color(0xFF757575), // AppColors.textSecondary
  ),
  textTheme: csTextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.background,
    titleTextStyle: csTextTheme().titleLarge?.copyWith(
          color: AppColors.textPrimary, // Explicit for app bar title
        ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.accent,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      textStyle: csTextTheme().bodyLarge?.copyWith(fontWeight: FontWeight.w500),
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor: const WidgetStatePropertyAll(Colors.white),
      elevation: const WidgetStatePropertyAll(4),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll(AppColors.textPrimary),
    ),
  ),
  iconTheme: const IconThemeData(
    color: AppColors.textPrimary,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: AppColors.textPrimary,
    textColor: AppColors.textPrimary, // Added for ListTile text
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: const Color(0xFF212121),
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    onPrimary: Colors.white,
    onSecondary: Colors.white, // Changed for better contrast
    surface: Color(0xFF212121),
    onSurface: AppColors.background, // Light gray text for dark mode
    primaryContainer: Color(0xFF424242), // Slightly lighter gray
    outline: AppColors.textSecondary,
  ),
  textTheme: csTextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF121212),
    titleTextStyle: csTextTheme().titleLarge?.copyWith(
          color: AppColors.background, // Light gray for app bar title
        ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.accent,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      textStyle: csTextTheme().bodyLarge?.copyWith(fontWeight: FontWeight.w500),
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF424242), // Adjusted for dark mode
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor: const WidgetStatePropertyAll(Color(0xFF424242)),
      elevation: const WidgetStatePropertyAll(4),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll(AppColors.background),
    ),
  ),
  iconTheme: const IconThemeData(
    color: AppColors.background,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: AppColors.background,
    textColor: AppColors.background, // Added for ListTile text
  ),
);
