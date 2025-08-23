import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_firebase/features/auth/provider/auth_provider.dart';

class DashboardView extends StatefulWidget {
  static const String id = 'dashboard_view';

  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        return Scaffold(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),

          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                user != null && user.fullname.isNotEmpty
                    ? 'Hello, ${user.fullname}!'
                    : 'Hello Guest!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
