// ============================================================
//  main.dart  —  App Entry Point  (UPDATED for Part 2)
//
//  WHAT CHANGED FROM PART 1:
//  - Imported CoursesScreen (no new named route needed — we use
//    Navigator.push directly from DashboardScreen because
//    CoursesScreen takes no arguments)
//  - Everything else is identical to Part 1
// ============================================================

import 'package:flutter/material.dart';

// Import the controller — needed so main.dart knows what 'Subject' is
import 'controllers/auth_controller.dart';

// Import all screens
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/detail_screen.dart';
// CoursesScreen and AddEditCourseScreen are navigated to directly
// via Navigator.push — no named route needed since they take no
// route arguments that need to be unwrapped here.

// This is the very first function Flutter calls when your app starts
void main() {
  runApp(const MyApp());
}

// MyApp is the ROOT widget of our entire application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student App',
      debugShowCheckedModeBanner: false,

      // --------------- APP THEME ---------------
      // Defined once here so every screen uses the same colors and styles
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,

        // Default style for all TextFormField / TextField widgets
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),

        // Default style for all ElevatedButton widgets
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      // --------------- NAMED ROUTES ---------------
      initialRoute: '/register',

      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        // '/detail' is in onGenerateRoute below because it needs arguments
      },

      // onGenerateRoute handles routes that need arguments passed to them
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final subject = settings.arguments as Subject;
          return MaterialPageRoute(
            builder: (context) => DetailScreen(subject: subject),
          );
        }
        return null;
      },
    );
  }
}
