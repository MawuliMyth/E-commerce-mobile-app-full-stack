import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  static String id = 'register_view';

  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/left.png',
                width: 300,
                alignment: Alignment.topLeft,
              ),
              Positioned(
                bottom: 10,
                left: 30,
                child: Text(
                  'Create\nAccount',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'qwerty',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
         
        ],
      ),
    );
  }
}
