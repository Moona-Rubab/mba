// ============================================================
//  register_screen.dart  —  Registration Screen
// ============================================================

import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../enums/app_enums.dart';
import '../validators/app_validator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// StatefulWidget needs a State class.
// Everything that can CHANGE over time lives here (form values, toggles, etc.)
class _RegisterScreenState extends State<RegisterScreen> {
  // ---- Form key ----
  // GlobalKey<FormState> is Flutter's way of letting us control the Form widget.
  // We use it to call _formKey.currentState!.validate() on submit.
  final _formKey = GlobalKey<FormState>();

  // ---- Text Editing Controllers ----
  // These link our TextFormFields to variables we can read.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // ---- State variables ----
  bool _obscurePassword = true; // Controls show/hide of password field
  bool _obscureConfirm = true; // Controls show/hide of confirm field
  Gender? _selectedGender; // Selected gender from dropdown (null = not chosen)
  bool _isLoading = false; // True while we're processing the form

  // dispose() is called when this widget is removed from the screen.
  // We MUST dispose controllers to free up memory — a common Flutter best practice.
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------
  //  SUBMIT HANDLER
  // ----------------------------------------------------------------
  void _onRegisterPressed() {
    // 1. Validate all fields — if any field returns an error string, stop here
    if (!_formKey.currentState!.validate()) return;

    // 2. Check gender was chosen (dropdown isn't part of Form validation)
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }

    // 3. Show loading spinner
    setState(() => _isLoading = true);

    // 4. Call the controller
    final success = authController.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      gender: _selectedGender!,
    );

    // 5. Hide loading spinner
    setState(() => _isLoading = false);

    if (success) {
      // Show a success message, then navigate to Login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please log in.'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to login and remove Register from the back stack
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Show the error from the controller
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ----------------------------------------------------------------
  //  BUILD — this is what gets drawn on screen
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar at the top of the screen
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      // SingleChildScrollView lets the page scroll when the keyboard appears
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey, // Connect the Form to our GlobalKey
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Header ----
              const SizedBox(height: 16),
              const Icon(Icons.person_add, size: 64, color: Color(0xFF1A237E)),
              const SizedBox(height: 8),
              const Text(
                'Register',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Fill in the details below to create your account',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 28),

              // ---- Full Name ----
              _buildSectionLabel('Full Name'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. John Doe',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                // validator is called automatically when the form is validated
                validator: AppValidator.validateFullName,
              ),
              const SizedBox(height: 16),

              // ---- Email ----
              _buildSectionLabel('Email'),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'e.g. john@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: AppValidator.validateEmail,
              ),
              const SizedBox(height: 16),

              // ---- Gender Dropdown ----
              _buildSectionLabel('Gender'),
              DropdownButtonFormField<Gender>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.wc_outlined),
                ),
                hint: const Text('Select gender'),
                // Build one DropdownMenuItem for each Gender enum value
                items: Gender.values.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender.label), // Uses our extension from enums
                  );
                }).toList(),
                onChanged: (value) {
                  // setState tells Flutter to re-draw the widget with new data
                  setState(() => _selectedGender = value);
                },
              ),
              const SizedBox(height: 16),

              // ---- Password ----
              _buildSectionLabel('Password'),
              TextFormField(
                controller: _passwordController,
                obscureText:
                    _obscurePassword, // true = shows dots instead of letters
                decoration: InputDecoration(
                  hintText: 'Min 6 chars, 1 uppercase, 1 special',
                  prefixIcon: const Icon(Icons.lock_outline),
                  // suffixIcon is the eye icon to toggle visibility
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: AppValidator.validatePassword,
              ),
              const SizedBox(height: 8),

              // Password hint cards — helpful visual guide for the user
              _buildPasswordHints(),
              const SizedBox(height: 16),

              // ---- Confirm Password ----
              _buildSectionLabel('Re-type Password'),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Must match the password above',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),
                ),
                // We pass the original password into the validator
                validator: (value) => AppValidator.validateConfirmPassword(
                  value,
                  _passwordController.text,
                ),
              ),
              const SizedBox(height: 32),

              // ---- Submit Button ----
              // Show a spinner while loading, button otherwise
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _onRegisterPressed,
                      child: const Text('REGISTER'),
                    ),
              const SizedBox(height: 20),

              // ---- Already have an account? ----
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF1A237E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  //  HELPER WIDGETS
  //  Breaking UI into small helper methods keeps build() readable.
  // ----------------------------------------------------------------

  /// Small bold label above each field
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  /// Visual hints showing password requirements
  Widget _buildPasswordHints() {
    final password = _passwordController.text;
    return Column(
      children: [
        _buildHintRow(
          'At least 6 characters',
          password.length >= 6,
        ),
        _buildHintRow(
          'At least 1 uppercase letter (A–Z)',
          password.contains(RegExp(r'[A-Z]')),
        ),
        _buildHintRow(
          'At least 1 special character (!@#\$...)',
          password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')),
        ),
      ],
    );
  }

  Widget _buildHintRow(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: met ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: met ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
