
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'signup_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';
import 'services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color primaryGreen = const Color(0xFF063D34);
  final Color inputBgColor = const Color(0xFFE6F0EB);

  bool _obscurePassword = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
      'http://localhost:5000/api/auth/login',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Receive JWT token from backend
        final token = data['token'];

        if (token == null || token.toString().isEmpty) {
          throw Exception(
            'Login token was not received from server.',
          );
        }

        // Save token for authenticated API requests
        ApiService.setToken(token.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Successful!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? 'Invalid email or password',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 25.0,
            vertical: 10.0,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode:
                AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF063D34),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome back! Please login to your account',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email Address',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF063D34),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Color(0xFF063D34),
                        ),
                        filled: true,
                        fillColor: inputBgColor,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }

                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );

                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }

                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF063D34),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Color(0xFF063D34),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: inputBgColor,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF063D34),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child:
                                CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Or',
                        style:
                            TextStyle(color: Colors.grey),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 20),

                // Google Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Google Sign-In Coming Soon!',
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      side:
                          const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      'Continue with Google',
                      style:
                          TextStyle(color: Colors.black),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Sign Up Link
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
