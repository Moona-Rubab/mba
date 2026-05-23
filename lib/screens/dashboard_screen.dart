// ============================================================
//  dashboard_screen.dart  —  Dashboard Screen  (UPDATED for Part 2)
//
//  WHAT CHANGED FROM PART 1:
//  A new "Courses (API)" button card has been added below the
//  existing subjects list. Tapping it opens the CoursesScreen
//  which connects to the JSONPlaceholder API.
//
//  Everything else is unchanged from Part 1.
// ============================================================

import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../screens/courses_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // ----------------------------------------------------------------
  //  LOGOUT HANDLER
  // ----------------------------------------------------------------
  void _onLogout(BuildContext context) {
    // Call controller to clear user data
    authController.logout();

    // Navigate back to Login and remove all other routes from the stack
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  // ----------------------------------------------------------------
  //  BUILD
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Get the subjects list from the controller
    final subjects = authController.getSubjects();

    // Get current user (we know it's not null because login succeeded)
    final user = authController.currentUser!;

    return Scaffold(
      // ---- AppBar with Logout button ----
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false, // No back arrow on dashboard
        actions: [
          // Logout icon button in the top-right corner
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _onLogout(context),
          ),
        ],
      ),

      body: Column(
        children: [
          // ---- User Profile Header ----
          _buildUserHeader(user.fullName),

          // ---- API Courses Banner ----
          // NEW in Part 2: a prominent button to navigate to the
          // Courses screen which connects to the JSONPlaceholder API
          _buildApiCoursesButton(context),

          // ---- Section Title ----
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'My Subjects',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ---- Subject List ----
          // Expanded makes the ListView take all remaining vertical space
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // itemCount tells ListView how many items to build
              itemCount: subjects.length,
              // itemBuilder is called once for each index (0, 1, 2...)
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return _buildSubjectCard(context, subject);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  //  HELPER WIDGETS
  // ----------------------------------------------------------------

  /// The blue header card showing user's avatar and name
  Widget _buildUserHeader(String fullName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E), // Deep blue background
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          // Avatar placeholder — a circle with the user's initial
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              // Take the first character of the name and make it uppercase
              fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back,',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// NEW — Banner button that navigates to the live API Courses screen
  Widget _buildApiCoursesButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.push directly (no named route needed here since
        // CoursesScreen does not need arguments)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CoursesScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Gradient makes it stand out from the plain subject cards
          gradient: const LinearGradient(
            colors: [Color(0xFF006064), Color(0xFF00838F)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cloud_download_outlined,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Courses  (Live API)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'View, add, edit and delete via JSONPlaceholder',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  /// A single tappable card for each subject
  Widget _buildSubjectCard(BuildContext context, Subject subject) {
    // Parse the hex color string to a Flutter Color
    final color = _hexToColor(subject.bannerColor);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      // InkWell adds a tap ripple effect to any widget
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to DetailScreen and pass the subject as an argument
          // The route is defined in main.dart's onGenerateRoute
          Navigator.pushNamed(
            context,
            '/detail',
            arguments: subject, // This is received by DetailScreen
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Colored square on the left (acts like a banner preview)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              // Subject name (Expanded prevents text overflow)
              Expanded(
                child: Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Arrow indicating it's tappable
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  /// Converts a hex color string like '#1A237E' to a Flutter Color object
  Color _hexToColor(String hex) {
    // Remove the '#' symbol, add 'FF' for full opacity, then parse as int
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}
