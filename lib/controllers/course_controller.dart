// ============================================================
//  course_controller.dart  —  Course Controller
//
//  WHAT DOES THIS DO?
//  The controller sits between the Service (API calls) and the
//  UI (screens). It:
//    1. Calls the service to fetch/create/update/delete data
//    2. Manages loading/success/error states
//    3. Holds the list of courses so screens can display them
//    4. Notifies the screen when something changes (via callbacks)
//
//  FLOW DIAGRAM:
//  Screen  ──calls──▶  Controller  ──calls──▶  Service  ──HTTP──▶  API
//  Screen  ◀──updates──  Controller  ◀──returns data──  Service
//
//  STATE MANAGEMENT NOTE:
//  We use a simple callback pattern here (onStateChanged) so the
//  screen can call setState() when the controller's data changes.
//  In a real production app you would use Provider or Riverpod,
//  but this approach is the simplest to understand.
// ============================================================

import 'package:flutter/foundation.dart';
// flutter/foundation.dart gives us VoidCallback (and other core Flutter types).
// VoidCallback is simply a typedef for: void Function()
// It lives in foundation, not material, because it is not a UI concept —
// it is just a function type used for callbacks.

import '../models/course_model.dart';
import '../services/course_service.dart';

// ---- ApiState enum ----
// Tracks what is happening with the API right now.
// We defined AuthState in app_enums.dart for auth — we keep this
// separate because it belongs to the courses feature.
enum ApiState {
  idle, // Nothing is happening — initial state
  loading, // Waiting for the API response
  success, // API call succeeded
  error, // Something went wrong
}

class CourseController {
  // ---- Service instance ----
  // The controller owns the service — screens never touch the service directly.
  final CourseService _service = CourseService();

  // ---- State ----
  ApiState state = ApiState.idle;

  // ---- Error message ----
  // When state == ApiState.error, this tells the UI what went wrong.
  String errorMessage = '';

  // ---- Course list ----
  // This is the in-memory list of courses shown in the UI.
  // It starts empty and gets filled when fetchCourses() is called.
  List<CourseModel> courses = [];

  // ---- Callback ----
  // When the controller finishes an API call (success or error),
  // it calls this function so the screen knows to call setState().
  //
  // VoidCallback is just a typedef for: void Function()
  // The screen sets this to its own setState(() {}) call.
  VoidCallback? onStateChanged;

  // ---- Private helper ----
  // Calls onStateChanged if it has been set, triggering a UI rebuild.
  void _notify() {
    onStateChanged?.call();
    // ?. is the null-safe call operator — only calls .call() if not null
  }

  // ----------------------------------------------------------------
  //  FETCH COURSES  (Read)
  // ----------------------------------------------------------------
  Future<void> fetchCourses() async {
    // 1. Set state to loading and update the UI
    state = ApiState.loading;
    errorMessage = '';
    _notify();

    try {
      // 2. Call the service — await pauses here until data arrives
      final result = await _service.fetchCourses();

      // 3. Store the result and mark success
      courses = result;
      state = ApiState.success;
    } catch (e) {
      // 4. Something went wrong — store the error message
      state = ApiState.error;
      errorMessage = e.toString();
    }

    // 5. Notify the screen regardless of success or failure
    _notify();
  }

  // ----------------------------------------------------------------
  //  CREATE COURSE  (Create — POST)
  //
  //  Returns true on success, false on failure.
  //  The screen uses this return value to decide whether to close
  //  the form or stay and show an error.
  // ----------------------------------------------------------------
  Future<bool> createCourse({
    required String title,
    required String body,
  }) async {
    state = ApiState.loading;
    errorMessage = '';
    _notify();

    try {
      // Build the new CourseModel to send to the API.
      // userId: 1 is hardcoded — in a real app you would use the
      // logged-in user's actual id.
      final newCourse = CourseModel(
        title: title.trim(),
        body: body.trim(),
        userId: 1,
      );

      final created = await _service.createCourse(newCourse);

      // Add the returned course (which now has an id from the server)
      // to the FRONT of our local list so it appears at the top
      courses.insert(0, created);

      state = ApiState.success;
      _notify();
      return true;
    } catch (e) {
      state = ApiState.error;
      errorMessage = e.toString();
      _notify();
      return false;
    }
  }

  // ----------------------------------------------------------------
  //  UPDATE COURSE  (Update — PUT)
  // ----------------------------------------------------------------
  Future<bool> updateCourse({
    required int id,
    required String title,
    required String body,
  }) async {
    state = ApiState.loading;
    errorMessage = '';
    _notify();

    try {
      // Find the existing course so we can copy it with new values
      final existing = courses.firstWhere((c) => c.id == id);

      // copyWith creates a new object with only the changed fields replaced
      final updated = existing.copyWith(
        title: title.trim(),
        body: body.trim(),
      );

      final result = await _service.updateCourse(updated);

      // Find the index of the old course in the list
      final index = courses.indexWhere((c) => c.id == id);
      if (index != -1) {
        // Replace the old course with the updated one at the same position
        courses[index] = result;
      }

      state = ApiState.success;
      _notify();
      return true;
    } catch (e) {
      state = ApiState.error;
      errorMessage = e.toString();
      _notify();
      return false;
    }
  }

  // ----------------------------------------------------------------
  //  DELETE COURSE  (Delete)
  // ----------------------------------------------------------------
  Future<bool> deleteCourse(int id) async {
    state = ApiState.loading;
    errorMessage = '';
    _notify();

    try {
      await _service.deleteCourse(id);

      // Remove the deleted course from our local list
      // removeWhere removes all items where the condition is true
      courses.removeWhere((c) => c.id == id);

      state = ApiState.success;
      _notify();
      return true;
    } catch (e) {
      state = ApiState.error;
      errorMessage = e.toString();
      _notify();
      return false;
    }
  }
}

// ---- Singleton instance ----
// One shared CourseController for the whole app — same pattern
// as authController in auth_controller.dart.
final courseController = CourseController();
