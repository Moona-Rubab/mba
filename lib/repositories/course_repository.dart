// ============================================================
//  course_repository.dart  —  Repository Layer  (NEW in Part 3)
//
//  WHAT IS THE REPOSITORY PATTERN?
//  The repository is the "single source of truth" for data.
//  It sits between the Provider (state management) and the
//  data sources (API and Hive). It decides WHERE data comes from.
//
//  ANALOGY:
//  Think of a librarian (repository).
//  When you ask for a book (data):
//    - If the book is on the shelf (Hive/local) AND the library
//      is closed (offline) → give you the local copy
//    - If the library is open (online) → get the fresh copy
//      from the publisher (API) AND update the shelf copy (Hive)
//
//  The reader (Provider/UI) never goes to the publisher directly.
//  They always ask the librarian.
//
//  FULL ARCHITECTURE:
//  UI Screens
//      ↓ (reads state, calls methods)
//  CourseProvider   ← ChangeNotifier (Part 3 state management)
//      ↓ (calls repository methods)
//  CourseRepository ← THIS FILE (decides API vs Hive)
//      ↓               ↓
//  CourseService    HiveLocalService
//  (HTTP calls)     (disk storage)
//      ↓
//  JSONPlaceholder API
// ============================================================

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/course_model.dart';
import '../services/course_service.dart';

// The name of our Hive box — like a table name in a database
// We define it as a constant so we never mistype it
const String kCoursesBox = 'courses_box';

class CourseRepository {
  // The service handles all HTTP — the repository calls it when online
  final CourseService _service = CourseService();

  // ----------------------------------------------------------------
  //  PRIVATE HELPER — check internet connectivity
  //
  //  connectivity_plus returns a list of ConnectivityResult values.
  //  We check if any of them is NOT 'none' (i.e. has some connection).
  //  ConnectivityResult.none means no connection at all.
  // ----------------------------------------------------------------
  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    // .any() returns true if at least one item passes the condition
    return results.any((r) => r != ConnectivityResult.none);
  }

  // ----------------------------------------------------------------
  //  PRIVATE HELPER — open the Hive box
  //
  //  A Hive Box is like a table — it stores a collection of objects.
  //  We open it before every read/write. If it is already open,
  //  Hive returns the existing instance (no duplicate opening).
  // ----------------------------------------------------------------
  Future<Box<CourseModel>> _openBox() async {
    // If the box is already open, return it directly
    if (Hive.isBoxOpen(kCoursesBox)) {
      return Hive.box<CourseModel>(kCoursesBox);
    }
    // Otherwise open it from disk
    return await Hive.openBox<CourseModel>(kCoursesBox);
  }

  // ----------------------------------------------------------------
  //  GET COURSES
  //
  //  ONLINE:
  //    1. Fetch from API
  //    2. Clear old Hive data
  //    3. Save fresh data to Hive
  //    4. Return fresh data
  //
  //  OFFLINE:
  //    1. Load whatever is stored in Hive
  //    2. Return it (may be empty if never fetched before)
  // ----------------------------------------------------------------
  Future<List<CourseModel>> getCourses() async {
    final box = await _openBox();

    if (await _isOnline()) {
      // ---- ONLINE path ----
      final courses = await _service.fetchCourses();

      // Clear old cached data before saving new data
      // This prevents duplicates if courses were added/removed on server
      await box.clear();

      // Save each course to Hive using its id as the key
      // If id is null we use the list index as a fallback key
      for (int i = 0; i < courses.length; i++) {
        final course = courses[i];
        await box.put(course.id ?? i, course);
        // box.put(key, value) — key is what we use to retrieve it later
      }

      return courses;
    } else {
      // ---- OFFLINE path ----
      // box.values returns all stored CourseModel objects
      // .toList() converts the Iterable to a List
      final cached = box.values.toList();

      if (cached.isEmpty) {
        // No cached data AND no internet — nothing we can do
        throw Exception(
          'No internet connection and no cached data available.\n'
          'Please connect to the internet and try again.',
        );
      }

      return cached;
    }
  }

  // ----------------------------------------------------------------
  //  CREATE COURSE
  //
  //  OPTIMISTIC UPDATE EXPLAINED:
  //  Optimistic update = update the UI BEFORE the API responds.
  //  This makes the app feel instant. If the API fails, we roll back.
  //
  //  For CREATE:
  //    1. Call API (must be online to create)
  //    2. On success → save the returned course (with real id) to Hive
  //    3. Return the created course to the Provider
  //    4. Provider adds it to the list → UI updates
  // ----------------------------------------------------------------
  Future<CourseModel> createCourse(CourseModel course) async {
    if (!await _isOnline()) {
      throw Exception(
          'No internet connection. Cannot create a course offline.');
    }

    final created = await _service.createCourse(course);

    // Save the new course to Hive so it persists locally too
    final box = await _openBox();
    await box.put(created.id ?? DateTime.now().millisecondsSinceEpoch, created);
    // DateTime.now().millisecondsSinceEpoch as fallback key if id is null

    return created;
  }

  // ----------------------------------------------------------------
  //  UPDATE COURSE  (with optimistic update + rollback)
  //
  //  OPTIMISTIC UPDATE FLOW:
  //  Step 1: Provider immediately swaps old course with updated course in UI
  //  Step 2: Repository sends PUT request to API
  //  Step 3a: If success → update Hive → done
  //  Step 3b: If failure → throw exception → Provider catches it
  //           → Provider rolls back to old course → UI shows old data again
  //
  //  The 'oldCourse' parameter is needed for rollback — if the API
  //  fails, the Provider uses it to restore the original data.
  // ----------------------------------------------------------------
  Future<CourseModel> updateCourse(CourseModel updatedCourse) async {
    if (!await _isOnline()) {
      throw Exception(
          'No internet connection. Cannot update a course offline.');
    }

    // Send the update to the API
    final result = await _service.updateCourse(updatedCourse);

    // API succeeded — update Hive too so local cache stays in sync
    final box = await _openBox();
    await box.put(result.id, result);

    return result;
  }

  // ----------------------------------------------------------------
  //  DELETE COURSE  (with optimistic update + rollback)
  //
  //  OPTIMISTIC DELETE FLOW:
  //  Step 1: Provider immediately removes course from the UI list
  //  Step 2: Repository sends DELETE request to API
  //  Step 3a: If success → delete from Hive → done
  //  Step 3b: If failure → throw exception → Provider catches it
  //           → Provider puts the course back in the list
  //           → UI shows it again (rollback)
  // ----------------------------------------------------------------
  Future<void> deleteCourse(int id) async {
    if (!await _isOnline()) {
      throw Exception(
          'No internet connection. Cannot delete a course offline.');
    }

    await _service.deleteCourse(id);

    // API succeeded — remove from Hive too
    final box = await _openBox();
    await box.delete(id);
    // box.delete(key) removes the entry with that key
  }
}
