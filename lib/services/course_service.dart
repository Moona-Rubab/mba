// ============================================================
//  course_service.dart  —  API Service Layer
//
//  WHAT IS A SERVICE LAYER?
//  The service layer is responsible for ALL communication with
//  the outside world (in this case, the JSONPlaceholder API).
//  No screen or controller should ever call the API directly —
//  they all go through this class.
//
//  WHY SEPARATE IT?
//  If the API URL or structure changes, you only fix it HERE.
//  The rest of the app does not need to change at all.
//
//  Think of it like a travel agent:
//    • Controller = you (decides where to go)
//    • Service    = the travel agent (handles all the bookings)
//    • API        = the airline (actually does the work)
//
//  HTTP METHODS USED:
//    GET    → Read / fetch data
//    POST   → Create / send new data
//    PUT    → Update / replace existing data completely
//    DELETE → Remove data
//
//  JSONPLACEHOLDER API:
//  Base URL: https://jsonplaceholder.typicode.com
//  We use the /posts endpoint because it has id, title, body, userId
//  which maps perfectly to a "course" structure.
//
//  IMPORTANT NOTE FOR STUDENTS:
//  JSONPlaceholder is a FAKE API used for practice.
//  POST / PUT / DELETE requests appear to succeed and return a response,
//  but the data is NOT actually saved on the server permanently.
//  This is perfect for learning without needing a real backend.
// ============================================================

import 'dart:convert'; // dart:convert gives us jsonEncode and jsonDecode
import 'package:http/http.dart' as http; // the http package for network calls

import '../models/course_model.dart';

class CourseService {
  // ---- Base URL ----
  // We store the base URL as a constant so we only write it once.
  // Every method builds its full URL from this base.
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // ---- Endpoints ----
  // An endpoint is the specific path on the server.
  // /posts/1  means "the post (course) with id 1"
  // /posts    means "all posts (courses)"
  static const String _postsEndpoint = '/posts';

  // ----------------------------------------------------------------
  //  GET ALL COURSES  (Read — fetches the first 10 for display)
  //
  //  ASYNC / AWAIT EXPLAINED:
  //  Network calls take time (milliseconds to seconds).
  //  If we waited without async/await, the whole app would freeze.
  //  'async' marks a function as asynchronous (it can wait).
  //  'await' pauses ONLY this function while the network call runs —
  //  the rest of the app keeps working normally.
  //
  //  Future<List<CourseModel>> means:
  //  "This function will eventually return a List<CourseModel>
  //   but not immediately — it takes time."
  // ----------------------------------------------------------------
  Future<List<CourseModel>> fetchCourses() async {
    // Build the full URL: https://jsonplaceholder.typicode.com/posts?_limit=10
    // ?_limit=10 is a query parameter — it tells the server to only send 10 items
    final url = Uri.parse('$_baseUrl$_postsEndpoint?_limit=10');

    // http.get sends a GET request and returns a Response object
    // 'await' pauses here until the response arrives
    final response = await http.get(url);

    // response.statusCode is the HTTP status code:
    //   200 = OK (success)
    //   404 = Not Found
    //   500 = Server Error
    if (response.statusCode == 200) {
      // response.body is the raw JSON string from the server
      // jsonDecode turns that JSON string into a Dart List of Maps
      final List<dynamic> jsonList = jsonDecode(response.body);

      // Convert each Map in the list into a CourseModel object
      // .map() transforms each item, .toList() converts the result to a List
      return jsonList.map((json) => CourseModel.fromJson(json)).toList();
    } else {
      // If something went wrong, throw an Exception.
      // The controller will catch this and show an error to the user.
      throw Exception(
          'Failed to fetch courses. Status: ${response.statusCode}');
    }
  }

  // ----------------------------------------------------------------
  //  CREATE COURSE  (Create — POST request)
  //
  //  We send the new course data to the server.
  //  The server responds with the same data + a new 'id'.
  //  We return a CourseModel built from that response.
  // ----------------------------------------------------------------
  Future<CourseModel> createCourse(CourseModel course) async {
    final url = Uri.parse('$_baseUrl$_postsEndpoint');

    // http.post sends a POST request
    // 'headers' tells the server we are sending JSON
    // 'body' is the data we are sending, encoded as a JSON string
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        // Content-Type tells the server what format the data is in
      },
      body: jsonEncode(course.toJson()),
      // jsonEncode turns our Dart Map into a JSON string like:
      // '{"title": "Flutter Basics", "body": "...", "userId": 1}'
    );

    // 201 = Created (the standard success code for POST)
    if (response.statusCode == 201) {
      return CourseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to create course. Status: ${response.statusCode}');
    }
  }

  // ----------------------------------------------------------------
  //  UPDATE COURSE  (Update — PUT request)
  //
  //  PUT replaces the entire resource at the given URL.
  //  We must include ALL fields, not just the changed ones.
  //  (PATCH would only send the changed fields — PUT sends everything.)
  // ----------------------------------------------------------------
  Future<CourseModel> updateCourse(CourseModel course) async {
    // The URL includes the id: /posts/1, /posts/2, etc.
    final url = Uri.parse('$_baseUrl$_postsEndpoint/${course.id}');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(course.toJson()),
    );

    // 200 = OK (success for PUT)
    if (response.statusCode == 200) {
      return CourseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to update course. Status: ${response.statusCode}');
    }
  }

  // ----------------------------------------------------------------
  //  DELETE COURSE  (Delete — DELETE request)
  //
  //  We send a DELETE request to /posts/{id}.
  //  A successful delete returns status 200 with an empty body {}.
  //  We return true on success, throw on failure.
  // ----------------------------------------------------------------
  Future<bool> deleteCourse(int id) async {
    final url = Uri.parse('$_baseUrl$_postsEndpoint/$id');

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return true; // deletion succeeded
    } else {
      throw Exception(
          'Failed to delete course. Status: ${response.statusCode}');
    }
  }
}
