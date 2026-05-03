// ============================================================
//  detail_screen.dart  —  Subject Detail Screen
// ============================================================

import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';

class DetailScreen extends StatelessWidget {
  // The subject passed from DashboardScreen via Navigator.pushNamed arguments
  final Subject subject;

  const DetailScreen({super.key, required this.subject});

  // ----------------------------------------------------------------
  //  BUILD
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final bannerColor = _hexToColor(subject.bannerColor);

    return Scaffold(
      // AppBar shows the subject name and a back button automatically
      appBar: AppBar(
        title: Text(subject.name),
        backgroundColor: bannerColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- 01 — Banner Image / Header ----
            _buildBannerSection(bannerColor),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- 02 — Subject Name Header ----
                  _buildSectionNumber('01'),
                  _buildSectionTitle('Subject Header'),
                  const SizedBox(height: 8),
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 32),

                  // ---- 03 — Description ----
                  _buildSectionNumber('03'),
                  _buildSectionTitle('Description'),
                  const SizedBox(height: 8),
                  Text(
                    subject.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6, // Line height for readability
                      color: Colors.black87,
                    ),
                  ),
                  const Divider(height: 32),

                  // ---- 04 — Schedule Details ----
                  _buildSectionNumber('04'),
                  _buildSectionTitle('Schedule Details'),
                  const SizedBox(height: 12),
                  _buildScheduleCard(bannerColor),
                  const SizedBox(height: 32),

                  // ---- Back Button ----
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Dashboard'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: bannerColor,
                        side: BorderSide(color: bannerColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  //  HELPER WIDGETS
  // ----------------------------------------------------------------

  /// The big colored banner at the top (acts as the subject image)
  Widget _buildBannerSection(Color color) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: color,
        // Subtle gradient overlay for a polished look
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.7)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_rounded, size: 64, color: Colors.white70),
          const SizedBox(height: 8),
          Text(
            subject.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Small "02" style section number label
  Widget _buildSectionNumber(String number) {
    return Text(
      number,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.blue,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }

  /// Bold section title like "Description"
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A237E),
      ),
    );
  }

  /// A card showing the schedule with an icon
  Widget _buildScheduleCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08), // Very light tint of the banner color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.schedule, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              subject.schedule,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Converts a hex color string like '#1A237E' to a Flutter Color object
  Color _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}
