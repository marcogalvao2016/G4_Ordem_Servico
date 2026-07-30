import 'package:flutter/material.dart';

import 'core/database/database_service.dart';
import 'core/session/session_manager.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SessionManager.instance.initialize();
  await DatabaseService.instance.database;

  runApp(const G4OsApp());
}

class G4OsApp extends StatelessWidget {
  const G4OsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'G4 OS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
