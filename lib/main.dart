import 'package:ecommerce_firebase/Presentation/welcome_screen.dart';
import 'package:flutter/material.dart';

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
      routes:{
        WelcomeScreen.id : (context) => const WelcomeScreen(),
      },
    );
  }
}

