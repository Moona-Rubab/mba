// ============================================================
//  add_edit_course_screen.dart  —  Add / Edit Course Form
//
//  DUAL PURPOSE SCREEN:
//  This ONE screen handles both:
//    - Adding a new course    (course == null)
//    - Editing an existing one (course != null)
//
//  WHY ONE SCREEN FOR BOTH?
//  Add and Edit have almost identical UI — a form with a title
//  and body field. Instead of maintaining two separate screens
//  that are nearly identical, we pass an optional CourseModel.
//  If it is null  → we are adding.
//  If it is set   → we are editing, and we pre-fill the fields.
//
//  This is a very common pattern in real Flutter apps.
// ============================================================

import 'package:flutter/material.dart';

import '../controllers/course_controller.dart';
import '../models/course_model.dart';
import '../validators/course_validator.dart';

class AddEditCourseScreen extends StatefulWidget {
  // 'course' is nullable — null means Add mode, non-null means Edit mode
  final CourseModel? course;

  const AddEditCourseScreen({super.key, required this.course});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for the two form fields
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _isLoading = false;

  // ----------------------------------------------------------------
  //  initState — pre-fill fields when editing
  // ----------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    // widget.course accesses the 'course' property passed to this widget
    // If we are in Edit mode (course is not null), pre-fill the fields
    if (widget.course != null) {
      _titleController.text = widget.course!.title;
      _bodyController.text = widget.course!.body;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // ---- Helper: are we in Edit mode? ----
  bool get _isEditing => widget.course != null;
  // 'get' defines a getter — it's like a computed property.
  // We can call _isEditing anywhere as if it were a variable.

  // ----------------------------------------------------------------
  //  SUBMIT HANDLER
  // ----------------------------------------------------------------
  Future<void> _onSubmitPressed() async {
    // 1. Validate all fields
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    bool success;

    if (_isEditing) {
      // ---- Update existing course ----
      success = await courseController.updateCourse(
        id: widget.course!.id!,
        title: _titleController.text,
        body: _bodyController.text,
      );
    } else {
      // ---- Create new course ----
      success = await courseController.createCourse(
        title: _titleController.text,
        body: _bodyController.text,
      );
    }

    setState(() => _isLoading = false);

    if (!mounted) return;
    // 'mounted' check: if the user navigated away while waiting for the
    // API, we should not try to show a SnackBar or pop the screen.

    if (success) {
      // Show a brief success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Course updated successfully!'
                : 'Course added successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      // Go back to the Courses screen
      Navigator.pop(context);
    } else {
      // Show the error from the controller
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${courseController.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ----------------------------------------------------------------
  //  BUILD
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Title changes based on mode
        title: Text(_isEditing ? 'Edit Course' : 'Add Course'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Header icon + text ----
              const SizedBox(height: 8),
              Icon(
                _isEditing ? Icons.edit_note : Icons.add_circle_outline,
                size: 56,
                color: Color(0xFF1A237E),
              ),
              const SizedBox(height: 8),
              Text(
                _isEditing ? 'Update Course Details' : 'Create a New Course',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isEditing
                    ? 'Edit the fields below and tap Update'
                    : 'Fill in the fields below and tap Save',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 32),

              // ---- Course Title field ----
              const Text(
                'Course Title',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Flutter Advanced Concepts',
                  prefixIcon: Icon(Icons.title),
                ),
                textCapitalization: TextCapitalization.sentences,
                // maxLines: 1 is default — single line input
                validator: CourseValidator.validateTitle,
              ),
              const SizedBox(height: 20),

              // ---- Course Description / Body field ----
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  hintText: 'Describe what this course covers...',
                  prefixIcon: Icon(Icons.description_outlined),
                  // alignLabelWithHint keeps the prefix icon at the top
                  // when the field expands to multiple lines
                  alignLabelWithHint: true,
                ),
                maxLines: 5, // allows up to 5 lines of text
                minLines: 3, // starts at 3 lines tall
                textCapitalization: TextCapitalization.sentences,
                validator: CourseValidator.validateBody,
              ),
              const SizedBox(height: 36),

              // ---- Submit Button ----
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      // icon changes based on mode
                      icon: Icon(_isEditing ? Icons.save : Icons.add),
                      label: Text(_isEditing ? 'UPDATE COURSE' : 'SAVE COURSE'),
                      onPressed: _onSubmitPressed,
                    ),
              const SizedBox(height: 12),

              // ---- Cancel Button ----
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A237E),
                  side: const BorderSide(color: Color(0xFF1A237E)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('CANCEL'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
