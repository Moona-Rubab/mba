// ============================================================
//  courses_screen.dart  —  Courses Screen  (UPDATED for Part 3)
//
//  WHAT CHANGED FROM PART 2:
//  - Removed: courseController.onStateChanged callback
//  - Removed: manual setState() calls everywhere
//  - Added:   context.watch<CourseProvider>() — auto-rebuilds
//  - Added:   pull-to-refresh (RefreshIndicator)
//  - Added:   search bar with real-time filtering
//  - Added:   offline banner when serving cached data
//
//  HOW PROVIDER WORKS IN THIS SCREEN:
//
//  context.watch<CourseProvider>()
//  → Subscribes this widget to CourseProvider
//  → Every time notifyListeners() is called in the provider,
//    this widget's build() method is called again automatically
//  → No manual setState() needed anywhere
//
//  context.read<CourseProvider>()
//  → Gets the provider WITHOUT subscribing
//  → Used inside callbacks (onPressed, onTap) where we just
//    want to call a method, not listen for changes
//  → Using .watch() inside a callback would be wrong because
//    callbacks run outside the build method
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course_model.dart';
import '../providers/course_provider.dart';
import 'add_edit_course_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  // Search controller — tracks what the user types in the search bar
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Fetch courses when screen opens.
    // context.read() is used here (not watch) because initState()
    // runs outside the build method.
    // addPostFrameCallback ensures the first frame is drawn before
    // we trigger a state change — avoids a "called during build" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------
  //  DELETE with confirmation dialog
  // ----------------------------------------------------------------
  Future<void> _onDeletePressed(CourseModel course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text(
          'Are you sure you want to delete "${course.title}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && course.id != null && mounted) {
      // context.read — we are inside a callback, not build()
      final success =
          await context.read<CourseProvider>().deleteCourse(course.id!);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<CourseProvider>().errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course deleted'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ----------------------------------------------------------------
  //  NAVIGATE TO ADD
  // ----------------------------------------------------------------
  void _onAddPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditCourseScreen(course: null),
      ),
    );
  }

  // ----------------------------------------------------------------
  //  NAVIGATE TO EDIT
  // ----------------------------------------------------------------
  void _onEditPressed(CourseModel course) {
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
    // context.watch() subscribes to CourseProvider
    // Every time notifyListeners() is called, build() runs again
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            // context.read inside onPressed — we don't need to listen here
            onPressed: () => context.read<CourseProvider>().fetchCourses(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ---- Offline banner ----
          // Shows when the user is viewing cached data (no internet)
          if (provider.isOffline) _buildOfflineBanner(),

          // ---- Search bar ----
          // Only show when we have data to search through
          if (provider.state == CourseState.success ||
              provider.state == CourseState.empty)
            _buildSearchBar(),

          // ---- Main content area ----
          Expanded(child: _buildBody(provider)),
        ],
      ),
      floatingActionButton: provider.state == CourseState.loading
          ? null
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
  //  BODY — switches between states
  // ----------------------------------------------------------------
  Widget _buildBody(CourseProvider provider) {
    switch (provider.state) {
      case CourseState.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Fetching courses...'),
            ],
          ),
        );

      case CourseState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Could not load courses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: () =>
                      context.read<CourseProvider>().fetchCourses(),
                ),
              ],
            ),
          ),
        );

      case CourseState.empty:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No courses yet.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Tap + Add Course to create one.'),
            ],
          ),
        );

      case CourseState.success:
      case CourseState.idle:
        // Get filtered list based on current search query
        final displayList = provider.searchCourses(_searchQuery);

        if (displayList.isEmpty && _searchQuery.isNotEmpty) {
          // Search returned nothing
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('No courses matching "$_searchQuery"'),
              ],
            ),
          );
        }

        // ---- RefreshIndicator ----
        // Wrapping the list with RefreshIndicator adds pull-to-refresh.
        // When the user pulls down, onRefresh is called.
        return RefreshIndicator(
          onRefresh: () => context.read<CourseProvider>().fetchCourses(),
          color: const Color(0xFF1A237E),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              return _buildCourseCard(displayList[index]);
            },
          ),
        );
    }
  }

  // ----------------------------------------------------------------
  //  OFFLINE BANNER
  // ----------------------------------------------------------------
  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade700,
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'You are offline. Showing cached data.',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  //  SEARCH BAR
  // ----------------------------------------------------------------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search courses...',
          prefixIcon: const Icon(Icons.search),
          // Show clear button only when there is text
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (value) {
          // This is the one place we still use setState() in Part 3 —
          // it is for LOCAL widget state (the search query string) that
          // does not need to be shared with any other widget.
          // Provider is for SHARED state; local widget state is fine with setState.
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  // ----------------------------------------------------------------
  //  COURSE CARD
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
            // ---- ID badge + Title ----
            Row(
              children: [
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
                Flexible(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ---- Description ----
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

            // ---- Action buttons ----
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1A237E),
                  ),
                  onPressed: () => _onEditPressed(course),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
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
