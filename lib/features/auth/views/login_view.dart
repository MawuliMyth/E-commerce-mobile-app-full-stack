import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/forgot_password_controller.dart';
import '../controllers/google_signin_controller.dart';

class LoginView extends StatefulWidget {
  static String id = 'login_view';

  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isLoading = false;
  bool _obscurePassword = true;
  final GoogleAuthController _loginController = GoogleAuthController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String _selectedCountryCode = '+233'; // Default to Ghana

  // List of countries with their codes and flags
  final List<Map<String, String>> _countries = [
    {'name': 'Ghana', 'code': '+233', 'flag': '🇬🇭'},
    {'name': 'Nigeria', 'code': '+234', 'flag': '🇳🇬'},
  ];

  @override
  void dispose() {
    _passwordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset('assets/images/b2.png', height: 250),
                Positioned(
                  child: Image.asset('assets/images/b1.png', height: 200),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(
                  children: [
                    Positioned(
                      child: Image.asset('assets/images/b3.png', height: 150),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'qwerty',
                    ),
                  ),
                  Text(
                    'Good to see you back! 🖤',
                    style: TextStyle(fontSize: 16, color: Color(0xff202020)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Continue with Google button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  icon: Image.asset('assets/images/Google.png'),
                  label: Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            // Divider with "or" text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Flexible(
                    child: Divider(color: Colors.grey[300], thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ),
                  Flexible(
                    child: Divider(color: Colors.grey[300], thickness: 1),
                  ),
                ],
              ),
            ),

            // Form fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  // Phone number field with country code dropdown
                  Row(
                    children: [
                      // Country Flag Dropdown
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          underline: SizedBox(), // Remove default underline
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          items: _countries.map((country) {
                            return DropdownMenuItem<String>(
                              value: country['code'],
                              child: Text(
                                country['flag']!,
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCountryCode = newValue!;
                              _phoneNumberController.clear();
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 12),

                      // Vertical Divider
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      SizedBox(width: 12),

                      // Phone Number Input with Country Code Prefix
                      Flexible(
                        child: TextField(
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            prefixText: _selectedCountryCode,
                            prefixStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue[400]!,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.blue[400]!,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[400],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, ForgotPasswordView.id);
                    },
                    child: Text('Forgot Password?'),
                  ),

                  SizedBox(height: 20),

                  // Done button
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ElevatedButton(
                      onPressed: () {}, // empty function, button stays enabled
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff004CFF),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Cancel button
                ],
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Handle Google Sign In
  Future<void> _handleGoogleSignIn() async {
    final result = await _loginController.signInWithGoogle(
      context: context,
      setLoading: (isLoading) => setState(() => _isLoading = isLoading),
      onSuccess: () {
        // Navigate to home screen or handle success
        Navigator.pushNamed(context, ForgotPasswordView.id);
      },
    );

    if (result['success'] == true) {
      if (kDebugMode) {
        print("Google sign-in successful: ${result['data']}");
      }
    } else {
      // ❌ Not successful, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Google sign-in failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
