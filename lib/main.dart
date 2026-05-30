import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider untuk theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://eqhsyyewpdgfxcbjxcas.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxaHN5eWV3cGRnZnhjYmp4Y2FzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk5NTI2NjEsImV4cCI6MjA5NTUyODY2MX0.SlsTbaJ2J-qO5jicd7yDqJI0x--MKDVYg4x2kqZLwtk',
  );

  timeago.setLocaleMessages('id', timeago.IdMessages());
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'E-Ticketing Helpdesk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}