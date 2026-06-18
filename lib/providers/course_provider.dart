// ============================================================
//  course_provider.dart  —  State Management with Provider
//  (NEW in Part 3 — replaces course_controller.dart)
//
//  WHAT IS PROVIDER?
//  Provider is Flutter's recommended way to share state between
//  widgets without passing data manually through constructors.
//
//  HOW IT WORKS:
//  1. CourseProvider extends ChangeNotifier
//  2. When data changes, we call notifyListeners()
//  3. Any widget that is "watching" this provider automatically rebuilds
//
//  COMPARE WITH PART 2:
//  Part 2 used a manual callback:
//    courseController.onStateChanged = () { setState(() {}); }
//  That works but it is fragile — you must remember to set and
//  clear the callback in every screen.
//
//  Part 3 with Provider:
//    context.watch<CourseProvider>()  ← widget rebuilds automatically
//  Cleaner, safer, and the standard industry approach.
//
//  STATES WE MANAGE:
//  We use a proper enum with 4 states (not just loading/done):
//    idle    → app just started, no action taken yet
//    loading → waiting for data (API or Hive)
//    success → data is ready to display
//    error   → something went wrong
//    empty   → request succeeded but no data exists
// ============================================================

import 'package:flutter/foundation.dart';
// ChangeNotifier lives in foundation.dart (not material.dart)
// because it is not a UI concept — it is just a notification system

import '../models/course_model.dart';
import '../repositories/course_repository.dart';

// ---- CourseState enum ----
// Each state tells the UI exactly what to display
enum CourseState {
  idle, // Nothing has happened yet
  loading, // Waiting for data
  success, // Data loaded successfully
  error, // Something went wrong
  empty, // Loaded successfully but the list is empty
}

// ChangeNotifier is the base class from Flutter that gives us
// notifyListeners() — the method that tells all watching widgets to rebuild
class CourseProvider extends ChangeNotifier {
  // ---- Repository ----
  // The provider talks to the repository, never directly to the service or Hive
  final CourseRepository _repository = CourseRepository();

  // ---- State variables ----
  // These are private (underscore prefix) — accessed via getters below
  CourseState _state = CourseState.idle;
  List<CourseModel> _courses = [];
  String _errorMessage = '';
  bool _isOffline = false; // true when serving data from Hive cache

  // ---- Getters ----
  // Getters expose private variables as read-only to the outside world.
  // Screens can READ these but cannot SET them directly — they must
  // call the provider's methods instead.
  CourseState get state => _state;
  List<CourseModel> get courses => List.unmodifiable(_courses);
  // List.unmodifiable prevents screens from accidentally mutating the list
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;

  // ---- Private helper: update state and notify ----
  // Every time we change state, we call this instead of writing
  // notifyListeners() everywhere — keeps things DRY (Don't Repeat Yourself)
  void _setState(CourseState newState) {
    _state = newState;
    notifyListeners();
    // notifyListeners() is like calling setState() on every
    // widget that is watching this provider simultaneously
  }

  // ----------------------------------------------------------------
  //  FETCH COURSES
  // ----------------------------------------------------------------
  Future<void> fetchCourses() async {
    _setState(CourseState.loading);
    _isOffline = false;

    try {
      final result = await _repository.getCourses();

      _courses = result;
      _isOffline = false;

      // Check if the list came back empty
      _setState(result.isEmpty ? CourseState.empty : CourseState.success);
    } catch (e) {
      final errorStr = e.toString();

      // Check if the error message mentions "cached data"
      // That means we are offline but have local data to show
      if (errorStr.contains('cached')) {
        _isOffline = true;
        _setState(CourseState.error);
      } else if (errorStr.contains('internet') && _courses.isNotEmpty) {
        // Offline but we already have courses in memory from before
        _isOffline = true;
        _setState(CourseState.success);
      } else {
        _errorMessage = errorStr;
        _setState(CourseState.error);
      }
    }
  }

  // ----------------------------------------------------------------
  //  CREATE COURSE
  //  Returns true on success, false on failure.
  // ----------------------------------------------------------------
  Future<bool> createCourse({
    required String title,
    required String body,
  }) async {
    _setState(CourseState.loading);

    try {
      final newCourse = CourseModel(
        title: title.trim(),
        body: body.trim(),
        userId: 1,
      );

      final created = await _repository.createCourse(newCourse);

      // Add to the FRONT of the list so it appears at the top
      _courses = [created, ..._courses];
      // The spread operator '...' expands the existing list inline

      _setState(CourseState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(CourseState.error);
      return false;
    }
  }

  // ----------------------------------------------------------------
  //  UPDATE COURSE  (with optimistic update + rollback)
  //
  //  OPTIMISTIC UPDATE STEPS:
  //  1. Find the old course and save it (for rollback)
  //  2. Immediately swap it with the updated version in the list
  //  3. Call notifyListeners() → UI updates instantly
  //  4. Send API request in the background
  //  5. If API fails → put old course back → UI reverts
  // ----------------------------------------------------------------
  Future<bool> updateCourse({
    required int id,
    required String title,
    required String body,
  }) async {
    // Step 1: Find the old course at its current index
    final index = _courses.indexWhere((c) => c.id == id);
    if (index == -1) return false; // course not found

    final oldCourse = _courses[index]; // save for rollback

    // Step 2: Build the updated version
    final updatedCourse = oldCourse.copyWith(
      title: title.trim(),
      body: body.trim(),
    );

    // Step 3: Optimistically update the list RIGHT NOW
    // We create a new list with the updated course swapped in
    final optimisticList = List<CourseModel>.from(_courses);
    optimisticList[index] = updatedCourse;
    _courses = optimisticList;
    _setState(CourseState.success); // UI sees the change immediately

    try {
      // Step 4: Send to API (this takes time)
      await _repository.updateCourse(updatedCourse);
      // Success — the optimistic update was correct, nothing more to do
      return true;
    } catch (e) {
      // Step 5: API failed — ROLLBACK to old course
      final rollbackList = List<CourseModel>.from(_courses);
      rollbackList[index] = oldCourse; // put the original back
      _courses = rollbackList;
      _errorMessage = e.toString();
      _setState(CourseState.error);
      return false;
    }
  }

  // ----------------------------------------------------------------
  //  DELETE COURSE  (with optimistic update + rollback)
  //
  //  Same optimistic pattern as update:
  //  1. Remove from list immediately → UI updates
  //  2. Send DELETE to API
  //  3. If API fails → put course back → UI reverts
  // ----------------------------------------------------------------
  Future<bool> deleteCourse(int id) async {
    // Step 1: Save the course AND its position for rollback
    final index = _courses.indexWhere((c) => c.id == id);
    if (index == -1) return false;

    final deletedCourse = _courses[index];

    // Step 2: Optimistically remove from list
    final optimisticList = List<CourseModel>.from(_courses);
    optimisticList.removeAt(index);
    _courses = optimisticList;
    _setState(CourseState.success); // UI sees item gone immediately

    try {
      // Step 3: Send DELETE to API
      await _repository.deleteCourse(id);
      // Success — item stays gone
      return true;
    } catch (e) {
      // Step 4: ROLLBACK — put deleted course back at original position
      final rollbackList = List<CourseModel>.from(_courses);
      rollbackList.insert(index, deletedCourse);
      // .insert(index, item) adds item at the specific position
      _courses = rollbackList;
      _errorMessage = e.toString();
      _setState(CourseState.error);
      return false;
    }
  }

  // ----------------------------------------------------------------
  //  SEARCH / FILTER
  //
  //  Returns a filtered copy of the list based on the search query.
  //  This does NOT modify _courses — it just filters for display.
  //  The original list is always preserved.
  // ----------------------------------------------------------------
  List<CourseModel> searchCourses(String query) {
    if (query.trim().isEmpty) return _courses;

    final lower = query.toLowerCase();
    return _courses.where((course) {
      // .where() keeps only items where the condition is true
      return course.title.toLowerCase().contains(lower) ||
          course.body.toLowerCase().contains(lower);
      // search matches if title OR body contains the query
    }).toList();
  }
}
