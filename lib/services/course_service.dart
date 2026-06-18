// ============================================================
//  course_service.dart  —  API Service Layer  (unchanged from Part 2)
//
//  This file is IDENTICAL to Part 2.
//  Its only job is HTTP — GET, POST, PUT, DELETE.
//  It knows nothing about Hive, Provider, or the Repository.
//
//  ARCHITECTURE REMINDER:
//  UI → Provider → Repository → CourseService (this file)
//                            → Hive (local storage)
//
//  The service layer ONLY handles HTTP requests.
//  The repository (course_repository.dart) decides WHEN to call it.
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/course_model.dart';

class CourseService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _postsEndpoint = '/posts';

  // ---- GET all courses (first 10) ----
  Future<List<CourseModel>> fetchCourses() async {
    final url = Uri.parse('$_baseUrl$_postsEndpoint?_limit=10');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => CourseModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to fetch courses. Status: ${response.statusCode}');
    }
  }

  // ---- POST — create a new course ----
  Future<CourseModel> createCourse(CourseModel course) async {
    final url = Uri.parse('$_baseUrl$_postsEndpoint');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 201) {
      return CourseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to create course. Status: ${response.statusCode}');
    }
  }

  // ---- PUT — update an existing course ----
  Future<CourseModel> updateCourse(CourseModel course) async {
    final url = Uri.parse('$_baseUrl$_postsEndpoint/${course.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200) {
      return CourseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to update course. Status: ${response.statusCode}');
    }
  }

  // ---- DELETE — remove a course ----
  Future<bool> deleteCourse(int id) async {
    final url = Uri.parse('$_baseUrl$_postsEndpoint/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
          'Failed to delete course. Status: ${response.statusCode}');
    }
  }
}
