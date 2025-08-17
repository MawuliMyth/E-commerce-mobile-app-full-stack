import 'package:ecommerce_firebase/Presentation/welcome_screen.dart';
import 'package:flutter/material.dart';

import 'features/auth/views/login_view.dart';
import 'features/auth/views/register_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        LoginView.id: (context) => const LoginView(),
        RegisterView.id: (context) => const RegisterView(),


      },
    );
  }
}
