// ============================================================
//  course_model.dart  —  Course Data Model  (UPDATED for Part 3)
//
//  WHAT CHANGED FROM PART 2:
//  We added Hive support so CourseModel can be stored on-device.
//
//  HOW HIVE STORES DATA:
//  Hive is a key-value database. It stores Dart objects as
//  binary data on disk. To store a custom class like CourseModel,
//  Hive needs to know how to convert it to/from binary.
//
//  We do this manually using a TypeAdapter — a class that tells
//  Hive exactly how to read and write each field.
//  We write the adapter ourselves (HiveCourseAdapter below) to
//  keep things beginner-friendly without needing code generation.
//
//  HIVE CONCEPTS:
//  - Box     = like a table in a database, or a named file
//  - typeId  = a unique number identifying this type to Hive (0-223)
//  - adapter = the converter class that reads/writes the object
// ============================================================

import 'package:hive_flutter/hive_flutter.dart';

class CourseModel {
  final int? id;
  final String title;
  final String body;
  final int userId;

  CourseModel({
    this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  // ---- fromJson — build from API response ----
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      userId: json['userId'],
    );
  }

  // ---- toJson — convert to Map for API requests ----
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'userId': userId,
    };
  }

  // ---- copyWith — create updated copy without mutating original ----
  CourseModel copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
    );
  }
}

// ============================================================
//  HiveCourseAdapter  —  Teaches Hive how to store CourseModel
//
//  WHY WRITE THIS MANUALLY?
//  Normally you would use code generation (hive_generator package)
//  to auto-create this. But code generation requires extra setup
//  steps (build_runner, annotations) that are confusing for beginners.
//  Writing it manually is more lines but much easier to understand.
//
//  TypeAdapter<T> is a Hive class we extend.
//  T = the type we are teaching Hive about = CourseModel
// ============================================================
class HiveCourseAdapter extends TypeAdapter<CourseModel> {
  // typeId must be unique across all adapters in your app.
  // We use 0 since this is our only custom type.
  @override
  final int typeId = 0;

  // ---- read — Hive calls this when LOADING a CourseModel from disk ----
  // BinaryReader reads the binary data field by field, IN ORDER.
  // The order here MUST match the order in write() below.
  @override
  CourseModel read(BinaryReader reader) {
    return CourseModel(
      id: reader.readInt(), // field 0
      title: reader.readString(), // field 1
      body: reader.readString(), // field 2
      userId: reader.readInt(), // field 3
    );
  }

  // ---- write — Hive calls this when SAVING a CourseModel to disk ----
  // BinaryWriter converts each field to binary.
  // The order here MUST match the order in read() above.
  @override
  void write(BinaryWriter writer, CourseModel obj) {
    writer.writeInt(obj.id ?? 0); // field 0 — write 0 if id is null
    writer.writeString(obj.title); // field 1
    writer.writeString(obj.body); // field 2
    writer.writeInt(obj.userId); // field 3
  }
}
