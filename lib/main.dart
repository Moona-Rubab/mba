import 'package:flutter/material.dart';

// Import the controller — needed so main.dart knows what 'Subject' is
import 'controllers/auth_controller.dart';

// Import all our screens
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/detail_screen.dart';

// This is the very first function Flutter calls when your app starts
void main() {
  runApp(const MyApp()); // Launches the MyApp widget
}

// MyApp is the ROOT widget of our entire application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student App', // App title (shown in task switcher)
      debugShowCheckedModeBanner: false, // Removes the red "DEBUG" banner

      // --------------- APP THEME ---------------
      // We define colors and font styles once here so every screen uses them
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Deep blue as brand color
          brightness: Brightness.light,
        ),
        useMaterial3: true, // Use the latest Material Design version

        // Default style for all TextFormField / TextField widgets
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),

        // Default style for all ElevatedButton widgets
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E), // Deep blue
            foregroundColor: Colors.white, // White text
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
      // Named routes let us navigate using a simple string like '/login'
      // instead of writing Navigator.push(...) with a full widget every time
      initialRoute: '/register', // First screen the user sees

      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        // '/detail' is handled separately because it needs arguments (subject data)
      },

      // onGenerateRoute handles routes that need arguments
      // The DetailScreen needs to know WHICH subject was tapped
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          // Cast the arguments to our Subject model
          final subject = settings.arguments as Subject;
          return MaterialPageRoute(
            builder: (context) => DetailScreen(subject: subject),
          );
        }
        return null; // Return null for unknown routes
      },
    );
  }
}
