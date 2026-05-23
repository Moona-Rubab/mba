// ============================================================
//  courses_screen.dart  —  Courses Screen (CRUD List)
//
//  This screen:
//    - Fetches courses from the API when it first opens (Read)
//    - Shows a loading spinner while fetching
//    - Shows an error message if the fetch fails
//    - Shows the list of courses when data arrives
//    - Each course card has Edit and Delete buttons
//    - A FAB (Floating Action Button) opens the Add Course form
//
//  LIFECYCLE NOTE:
//  We use initState() to trigger the API call when the screen opens.
//  initState() runs ONCE when the widget is inserted into the tree —
//  it is the right place to kick off initial data loading.
// ============================================================

import 'package:flutter/material.dart';

import '../controllers/course_controller.dart';
import '../models/course_model.dart';
import 'add_edit_course_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  // ----------------------------------------------------------------
  //  initState — runs once when the widget first appears
  // ----------------------------------------------------------------
  @override
  void initState() {
    super.initState(); // always call super first

    // Register our rebuild callback on the controller.
    // When the controller calls _notify(), it will call this function,
    // which calls setState() and re-draws the screen.
    courseController.onStateChanged = () {
      // mounted checks that the widget is still in the tree.
      // It can happen that an API response arrives AFTER the user
      // has already navigated away — calling setState() on a widget
      // that is no longer on screen would crash the app.
      if (mounted) setState(() {});
    };

    // Fetch courses immediately when the screen opens.
    // We do not await here — fetchCourses() runs in the background
    // and calls onStateChanged when done, which triggers rebuild.
    courseController.fetchCourses();
  }

  // ----------------------------------------------------------------
  //  dispose — runs when widget is removed from the tree
  // ----------------------------------------------------------------
  @override
  void dispose() {
    // Clear the callback so the controller does not call setState()
    // on a widget that no longer exists.
    courseController.onStateChanged = null;
    super.dispose();
  }

  // ----------------------------------------------------------------
  //  DELETE HANDLER — shows confirmation dialog first
  // ----------------------------------------------------------------
  Future<void> _onDeletePressed(CourseModel course) async {
    // showDialog returns whatever value the dialog passes to Navigator.pop()
    // We use it as a confirmation result (true = confirmed, false = cancelled)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text(
          'Are you sure you want to delete "${course.title}"?\n'
          'This action cannot be undone.',
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context, false), // returns false
            child: const Text('Cancel'),
          ),
          // Confirm delete button
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true), // returns true
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // If the dialog was dismissed (back button) confirmed will be null
    // confirmed == true means the user pressed the Delete button
    if (confirmed == true && course.id != null) {
      final success = await courseController.deleteCourse(course.id!);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${courseController.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ----------------------------------------------------------------
  //  NAVIGATE TO ADD COURSE
  // ----------------------------------------------------------------
  void _onAddPressed() {
    // We pass null as the course argument to signal "Add new" mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditCourseScreen(course: null),
      ),
    );
  }

  // ----------------------------------------------------------------
  //  NAVIGATE TO EDIT COURSE
  // ----------------------------------------------------------------
  void _onEditPressed(CourseModel course) {
    // We pass the existing course to pre-fill the form fields
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditCourseScreen(course: course),
      ),
    );
  }

  // ----------------------------------------------------------------
  //  BUILD
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          // Refresh button — re-fetches the list from the API
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => courseController.fetchCourses(),
          ),
        ],
      ),

      // ---- Body — switches between loading, error, and list ----
      body: _buildBody(),

      // ---- FAB — Floating Action Button to add a new course ----
      // The FAB is hidden while loading to prevent double-tapping
      floatingActionButton: courseController.state == ApiState.loading
          ? null // hide FAB while loading
          : FloatingActionButton.extended(
              onPressed: _onAddPressed,
              backgroundColor: const Color(0xFF1A237E),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Course',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }

  // ----------------------------------------------------------------
  //  BODY BUILDER — decides what to show based on current ApiState
  // ----------------------------------------------------------------
  Widget _buildBody() {
    switch (courseController.state) {
      // ---- Loading state ----
      case ApiState.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Fetching courses from API...'),
            ],
          ),
        );

      // ---- Error state ----
      case ApiState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load courses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  courseController.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: () => courseController.fetchCourses(),
                ),
              ],
            ),
          ),
        );

      // ---- Success / Idle state — show the list ----
      case ApiState.success:
      case ApiState.idle:
        if (courseController.courses.isEmpty) {
          // Empty state — no courses yet
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No courses yet. Tap + to add one.'),
              ],
            ),
          );
        }
        // Non-empty — show the list
        return _buildCourseList();
    }
  }

  // ----------------------------------------------------------------
  //  COURSE LIST
  // ----------------------------------------------------------------
  Widget _buildCourseList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courseController.courses.length,
      itemBuilder: (context, index) {
        final course = courseController.courses[index];
        return _buildCourseCard(course);
      },
    );
  }

  // ----------------------------------------------------------------
  //  SINGLE COURSE CARD
  // ----------------------------------------------------------------
  Widget _buildCourseCard(CourseModel course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Top row: ID badge + Title ----
            Row(
              children: [
                // ID badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ID: ${course.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Title — Flexible prevents overflow
                Flexible(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    // ellipsis adds "..." if text is too long
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ---- Description (body) ----
            Text(
              course.body,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // ---- Action buttons row ----
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit button
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1A237E),
                  ),
                  onPressed: () => _onEditPressed(course),
                ),
                const SizedBox(width: 8),
                // Delete button
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () => _onDeletePressed(course),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
