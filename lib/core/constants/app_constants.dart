import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'HelpDesk D4TI';
  static const String appVersion = '1.0.0';

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 24.0;

  // Colors
  static const Color primaryNavy = Color(0xFF042C53);
  static const Color primaryBlue = Color(0xFF185FA5);
  static const Color accentGold = Color(0xFFFAC775);
  static const Color background = Color(0xFFF1EFE8);

  static const Color success = Color(0xFF4CAF50);
  static const Color danger = Color(0xFFE57373);
  static const Color purple = Color(0xFF9575CD);

  // Ticket Status
  static const List<String> ticketStatuses = [
    'pending',
    'assigned',
    'in_progress',
    'forwarded',
    'resolved',
    'closed',
  ];

  // Ticket Categories
  static const List<String> ticketCategories = [
    'Akun',
    'Jaringan',
    'Hardware',
    'Aplikasi',
    'Lainnya',
  ];
}