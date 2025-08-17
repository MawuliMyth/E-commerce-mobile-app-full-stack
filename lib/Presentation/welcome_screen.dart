import 'package:ecommerce_firebase/features/auth/views/register_view.dart';
import 'package:ecommerce_firebase/widgets/circle_icon_button.dart';
import 'package:ecommerce_firebase/widgets/custom_button.dart';
import 'package:flutter/material.dart';

import '../features/auth/views/login_view.dart';

class WelcomeScreen extends StatelessWidget {
  static String id = 'welcome_screen';

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/circle.png',
                  width: 190,
                  height: 190,
                ),
                Image.asset('assets/images/logo.png', width: 110, height: 110),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Shoppe',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              // fontFamily: 'dartguy',
              fontSize: 52,
              color: Color(0xff202020),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Beautiful eCommerce UI Kit\n for your online store',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff202020),
                fontFamily: 'ojuju',
                fontWeight: FontWeight.w300,
                fontSize: 20,
              ),
            ),
          ),

          const SizedBox(height: 80),
          CustomButton(
            text: 'Let\'s get started',
            onPressed: () {Navigator.pushNamed(context, RegisterView.id);},
            color: Color(0xff004CFF),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('I already have an account'),
              const SizedBox(width: 10),
              CircleIconButton(
                icon: Icons.arrow_forward,
                onPressed: () {
                  Navigator.pushNamed(context, LoginView.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
