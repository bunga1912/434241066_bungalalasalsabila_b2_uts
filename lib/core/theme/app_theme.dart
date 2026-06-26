import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: AppConstants.background,
      primaryColor: AppConstants.primaryNavy,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryBlue,
        primary: AppConstants.primaryNavy,
        secondary: AppConstants.accentGold,
        brightness: Brightness.light,
      ),

      fontFamily: 'Roboto',

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: AppConstants.primaryNavy,
        ),
        titleTextStyle: TextStyle(
          color: AppConstants.primaryNavy,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.radiusMedium,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryNavy,
          side: const BorderSide(
            color: AppConstants.primaryBlue,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.radiusMedium,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.radiusMedium,
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AppConstants.primaryBlue,
            width: 1.5,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.radiusMedium,
          ),
        ),
      ),
    );
    }
  }
