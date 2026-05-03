// ============================================================
//  login_screen.dart  —  Login Screen
// ============================================================

import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../validators/app_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Same pattern as Register screen
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true; // Toggle password visibility
  bool _rememberMe = false; // Remember Me checkbox state
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------
  //  LOGIN HANDLER
  // ----------------------------------------------------------------
  void _onLoginPressed() {
    // Validate the form fields
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      // Navigate to dashboard and clear the navigation stack
      // pushNamedAndRemoveUntil removes all previous routes so the user
      // can't press Back to go back to the login screen while logged in
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false, // Remove ALL previous routes
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage),
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
        title: const Text('Welcome Back'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        centerTitle: true,
        // automaticallyImplyLeading: false removes the back arrow
        // (user should not go back to register after landing on login)
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // ---- Header ----
              const Icon(Icons.lock_open, size: 64, color: Color(0xFF1A237E)),
              const SizedBox(height: 8),
              const Text(
                'Login',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to your account',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 36),

              // ---- Email Field ----
              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: AppValidator.validateEmail,
              ),
              const SizedBox(height: 20),

              // ---- Password Field ----
              const Text(
                'Password',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  // Eye icon — toggles _obscurePassword on tap
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
                validator: AppValidator.validateLoginPassword,
              ),
              const SizedBox(height: 12),

              // ---- Remember Me ----
              Row(
                children: [
                  // CheckboxListTile combines a Checkbox + Text in one tile,
                  // but here we build it manually for a cleaner look
                  Checkbox(
                    value: _rememberMe,
                    activeColor: const Color(0xFF1A237E),
                    onChanged: (value) {
                      setState(() => _rememberMe = value ?? false);
                    },
                  ),
                  const Text('Remember Me'),
                ],
              ),
              const SizedBox(height: 28),

              // ---- Login Button ----
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _onLoginPressed,
                      child: const Text('LOGIN'),
                    ),
              const SizedBox(height: 20),

              // ---- Don't have an account? ----
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/register'),
                    child: const Text(
                      'Register',
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
}
