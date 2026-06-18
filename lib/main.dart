// ============================================================
//  main.dart  —  App Entry Point  (UPDATED for Part 3)
//
//  WHAT CHANGED FROM PART 2:
//  1. Hive must be initialized BEFORE the app runs — we do this
//     in main() by making it async and calling Hive.initFlutter()
//
//  2. The HiveCourseAdapter must be registered so Hive knows how
//     to store and retrieve CourseModel objects
//
//  3. MultiProvider wraps the whole app so CourseProvider is
//     available to EVERY screen without passing it manually
//
//  PROVIDER SETUP EXPLAINED:
//  MultiProvider is a widget that sits above MaterialApp.
//  It creates and provides instances of our providers to the
//  entire widget tree. Any widget below it can access the
//  provider using context.watch() or context.read().
//
//  WHY WRAP MATERIALAPP?
//  If we put the provider inside MaterialApp, it would not be
//  accessible during route transitions. Wrapping MaterialApp
//  ensures it is truly available everywhere.
// ============================================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'models/course_model.dart';
import 'providers/course_provider.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/detail_screen.dart';

// main() is now async because Hive initialization is an async operation
// (it needs to set up file paths on the device before the app starts)
void main() async {
  // WidgetsFlutterBinding.ensureInitialized() must be called before
  // any async work in main(). It sets up the Flutter engine binding
  // so plugins (like Hive) can initialize correctly.
  WidgetsFlutterBinding.ensureInitialized();

  // ---- Initialize Hive ----
  // Hive.initFlutter() finds the correct directory on the device
  // to store database files (Documents folder on mobile, etc.)
  await Hive.initFlutter();

  // ---- Register the Hive adapter ----
  // Before Hive can store CourseModel, it needs to know HOW.
  // We register our HiveCourseAdapter which we wrote in course_model.dart.
  // isAlreadyRegistered check prevents errors on hot reload.
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(HiveCourseAdapter());
    // The '0' matches the typeId we set in HiveCourseAdapter
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ---- MultiProvider ----
    // Wraps the entire app. Each ChangeNotifierProvider creates one
    // instance of the provider and makes it available to all children.
    //
    // ChangeNotifierProvider vs Provider:
    // - Provider just provides a value
    // - ChangeNotifierProvider provides a ChangeNotifier AND
    //   automatically disposes it when the widget is removed
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CourseProvider(),
          // create: (_) means "create a new instance when first needed"
          // The underscore _ is the BuildContext which we do not need here
        ),
        // If we had more providers (AuthProvider, ThemeProvider, etc.)
        // we would add them here as additional entries in the list
      ],
      child: MaterialApp(
        title: 'Student App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A237E),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
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
        initialRoute: '/register',
        routes: {
          '/register': (context) => const RegisterScreen(),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/detail') {
            final subject = settings.arguments as Subject;
            return MaterialPageRoute(
              builder: (context) => DetailScreen(subject: subject),
            );
          }
          return null;
        },
      ),
    );
  }
}
