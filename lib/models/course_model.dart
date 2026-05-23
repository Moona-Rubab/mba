// ============================================================
//  course_model.dart  —  Course Data Model
//
//  WHAT IS A MODEL?
//  A model is a plain Dart class that represents one piece of data.
//  It knows nothing about the UI or network — it just holds fields.
//
//  WHY DO WE NEED THIS?
//  The JSONPlaceholder API returns data as JSON, which looks like this:
//  {
//    "id": 1,
//    "title": "Flutter Basics",
//    "body": "Learn widgets and state management",
//    "userId": 1
//  }
//  We convert that raw JSON into a CourseModel object so the rest of
//  the app can work with typed Dart objects instead of raw Maps.
// ============================================================

class CourseModel {
  // ---- Fields ----
  // These match the keys coming from the JSONPlaceholder /posts endpoint.
  // 'id' can be null for a NEW course that hasn't been saved yet
  // (the server assigns the id after creation).
  final int? id;
  final String title;
  final String body; // JSONPlaceholder calls the description 'body'
  final int userId; // which user this course belongs to

  // ---- Constructor ----
  // 'required' means the caller MUST provide these values.
  // 'id' is NOT required because a new course has no id yet.
  CourseModel({
    this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  // ---- fromJson ----
  // A named constructor (factory) that builds a CourseModel from a Map.
  //
  // WHY factory?
  // 'factory' means this constructor can return an existing instance or
  // do custom work before creating the object. It is the standard pattern
  // for JSON parsing in Dart.
  //
  // The Map<String, dynamic> type means:
  //   - Keys are Strings (the JSON field names like "id", "title")
  //   - Values are dynamic (could be int, String, bool, null — we don't
  //     know until runtime)
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'], // int or null
      title: json['title'], // String
      body: json['body'], // String
      userId: json['userId'], // int
    );
  }

  // ---- toJson ----
  // Converts this CourseModel back into a Map so we can send it to the API.
  // Used when doing POST (create) and PUT (update) requests.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'userId': userId,
      // We do NOT include 'id' here — the server controls the id
    };
  }

  // ---- copyWith ----
  // Creates a new CourseModel with some fields changed.
  // This is a common Dart pattern — because our fields are 'final'
  // (immutable), we cannot change them directly. copyWith gives us
  // a new object with the updated values.
  //
  // Example: course.copyWith(title: 'New Title')
  CourseModel copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
  }) {
    return CourseModel(
      // ?? means: use the new value if provided, otherwise keep the old one
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
    );
  }
}
