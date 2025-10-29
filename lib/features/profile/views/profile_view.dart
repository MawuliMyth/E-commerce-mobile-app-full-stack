import 'package:ecommerce_firebase/features/auth/controllers/auth_controller.dart';
import 'package:ecommerce_firebase/features/auth/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/provider/auth_provider.dart';

class ProfileView extends StatefulWidget {
  static const String id = 'profile_view';
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthController _authController = AuthController();

  Future<void> _logout(BuildContext context) async {
    // 1️⃣ Clear secure storage tokens
    await _authController.clearTokens();

    // 2️⃣ Clear AuthProvider user
    Provider.of<AuthProvider>(context, listen: false).clearUser();

    // 3️⃣ Navigate to Login Screen and remove all previous routes
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginView.id, // <-- make sure this matches your actual login route name
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text(
                'Welcome, ${user.fullname}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('User ID: ${user.userId}'),
            ],
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
