import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://eqhsyyewpdgfxcbjxcas.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxaHN5eWV3cGRnZnhjYmp4Y2FzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk5NTI2NjEsImV4cCI6MjA5NTUyODY2MX0.SlsTbaJ2J-qO5jicd7yDqJI0x--MKDVYg4x2kqZLwtk',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HelpDesk D4TI',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}