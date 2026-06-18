// ============================================================
//  add_edit_course_screen.dart  —  Add / Edit Course Form
//  (UPDATED for Part 3)
//
//  WHAT CHANGED FROM PART 2:
//  - Removed: courseController.createCourse / updateCourse
//  - Added:   context.read<CourseProvider>().createCourse / updateCourse
//
//  The form logic and UI are identical to Part 2.
//  Only the state management calls changed.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course_model.dart';
import '../providers/course_provider.dart';
import '../validators/course_validator.dart';

class AddEditCourseScreen extends StatefulWidget {
  final CourseModel? course; // null = Add mode, non-null = Edit mode

  const AddEditCourseScreen({super.key, required this.course});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false;

  // Getter: true if editing an existing course
  bool get _isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields in Edit mode
    if (_isEditing) {
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

  // ----------------------------------------------------------------
  //  SUBMIT
  // ----------------------------------------------------------------
  Future<void> _onSubmitPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // context.read — inside a callback, not in build()
    final provider = context.read<CourseProvider>();

    bool success;
    if (_isEditing) {
      success = await provider.updateCourse(
        id: widget.course!.id!,
        title: _titleController.text,
        body: _bodyController.text,
      );
    } else {
      success = await provider.createCourse(
        title: _titleController.text,
        body: _bodyController.text,
      );
    }

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (success) {
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
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.errorMessage}'),
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
              const SizedBox(height: 8),
              Icon(
                _isEditing ? Icons.edit_note : Icons.add_circle_outline,
                size: 56,
                color: const Color(0xFF1A237E),
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

              // ---- Title field ----
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
                validator: CourseValidator.validateTitle,
              ),
              const SizedBox(height: 20),

              // ---- Description field ----
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
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: CourseValidator.validateBody,
              ),
              const SizedBox(height: 36),

              // ---- Submit button ----
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: Icon(_isEditing ? Icons.save : Icons.add),
                      label: Text(_isEditing ? 'UPDATE COURSE' : 'SAVE COURSE'),
                      onPressed: _onSubmitPressed,
                    ),
              const SizedBox(height: 12),

              // ---- Cancel button ----
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
