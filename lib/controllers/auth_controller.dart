// ============================================================
//  auth_controller.dart  —  Controller Layer
//
//  WHY A CONTROLLER?
//  The Controller holds BUSINESS LOGIC (what the app does),
//  while screens hold PRESENTATION LOGIC (what it looks like).
//
//  Think of it like a restaurant:
//    • Screen   = the waiter  (shows things, takes input)
//    • Controller = the kitchen (does the actual work)
//
//  In a real app you'd use a state-management package (like Provider
//  or GetX), but here we use a simple class to keep things beginner-friendly.
// ============================================================

import '../enums/app_enums.dart';

// ============================================================
//  DATA MODELS
//  A "model" is just a class that holds related data together.
// ============================================================

/// Holds all the data for a registered user
class UserModel {
  final String fullName;
  final String email;
  final Gender gender;

  // A constructor with named parameters (the curly braces make them named)
  UserModel({
    required this.fullName,
    required this.email,
    required this.gender,
  });
}

/// Holds the data for one subject shown on the dashboard
class Subject {
  final String name; // e.g. "Mobile App Development"
  final String description; // Short course description
  final String schedule; // e.g. "Monday & Wednesday, 9:00 AM"
  final String bannerColor; // Hex color string for the placeholder banner

  Subject({
    required this.name,
    required this.description,
    required this.schedule,
    required this.bannerColor,
  });
}

// ============================================================
//  AUTH CONTROLLER
// ============================================================

class AuthController {
  // --------------- In-memory "database" ---------------
  // In a real app this would talk to a server or local database.
  // Here we just store registered users in a List inside the controller.
  final List<UserModel> _registeredUsers = [];

  // The currently logged-in user (null if no one is logged in)
  UserModel? currentUser;

  // AuthState tracks what is happening right now (see enums)
  AuthState state = AuthState.idle;

  // Error message to show in the UI when state == AuthState.error
  String errorMessage = '';

  // ----------------------------------------------------------------
  //  REGISTER
  //  Returns true if registration succeeds, false otherwise.
  // ----------------------------------------------------------------
  bool register({
    required String fullName,
    required String email,
    required String password,
    required Gender gender,
  }) {
    state = AuthState.loading;

    // Check if an account with this email already exists
    final alreadyExists = _registeredUsers.any(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
    );

    if (alreadyExists) {
      state = AuthState.error;
      errorMessage = 'An account with this email already exists.';
      return false;
    }

    // Create and store the new user
    final newUser = UserModel(
      fullName: fullName,
      email: email,
      gender: gender,
    );
    _registeredUsers.add(newUser);

    state = AuthState.success;
    return true;
  }

  // ----------------------------------------------------------------
  //  LOGIN
  //  For this assignment we just check the email exists in our list.
  //  (We don't store passwords in this demo — a real app would hash them.)
  // ----------------------------------------------------------------
  bool login({
    required String email,
    required String password,
  }) {
    state = AuthState.loading;

    // Try to find a user with matching email
    try {
      final user = _registeredUsers.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );

      // In a real app: also verify the hashed password here
      currentUser = user;
      state = AuthState.success;
      return true;
    } catch (_) {
      // firstWhere throws if nothing is found
      state = AuthState.error;
      errorMessage = 'No account found. Please register first.';
      return false;
    }
  }

  // ----------------------------------------------------------------
  //  LOGOUT
  // ----------------------------------------------------------------
  void logout() {
    currentUser = null;
    state = AuthState.idle;
    errorMessage = '';
  }

  // ----------------------------------------------------------------
  //  SUBJECTS LIST
  //  Returns the subjects for the dashboard.
  //  Defined here (in the controller) so the UI doesn't hard-code data.
  //
  //  TO ADD A NEW SUBJECT: just copy one Subject(...) block,
  //  paste it below the last one, and change the fields.
  //  The dashboard ListView.builder will pick it up automatically!
  // ----------------------------------------------------------------
  List<Subject> getSubjects() {
    return [
      Subject(
        name: 'Mobile App Development',
        description:
            'This course covers cross-platform mobile development using Flutter '
            'and Dart. Topics include widgets, state management, navigation, '
            'API integration, and publishing apps to the Play Store and App Store.',
        schedule: 'Monday & Wednesday\n9:00 AM – 10:30 AM  |  Room: CS-201',
        bannerColor: '#1A237E', // Deep blue
      ),
      Subject(
        name: 'Software Re-engineering',
        description:
            'Focuses on techniques to improve, modernize, and maintain legacy '
            'software systems. Topics include reverse engineering, refactoring, '
            'migration strategies, and software quality metrics.',
        schedule: 'Tuesday & Thursday\n11:00 AM – 12:30 PM  |  Room: CS-105',
        bannerColor: '#4A148C', // Deep purple
      ),
      Subject(
        name: 'Management Information Systems', // Renamed from 'MIS'
        description:
            'Management Information Systems explores how organizations use '
            'information technology to achieve business goals. Topics include '
            'ERP systems, decision support, data analytics, and IT governance.',
        schedule: 'Friday\n2:00 PM – 5:00 PM  |  Room: BS-301',
        bannerColor: '#006064', // Teal
      ),
      Subject(
        name: 'Game Programming', // New subject added here
        description:
            'An introduction to game development concepts and techniques. '
            'Topics include game loops, physics simulation, collision detection, '
            'sprite animation, input handling, and building 2D/3D games using '
            'a modern game engine.',
        schedule: 'Wednesday & Friday\n1:00 PM – 2:30 PM  |  Room: CS-309',
        bannerColor: '#BF360C', // Deep orange
      ),
    ];
  }
}

// ============================================================
//  SINGLETON PATTERN (simple version)
//
//  We create ONE global instance of AuthController so ALL screens
//  share the same data (same user list, same logged-in user).
//
//  Without this, each screen would create its own controller and
//  they wouldn't know about each other's data.
// ============================================================
final authController = AuthController();
