import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  static String id = 'profile_view';
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(       backgroundColor: Color.fromRGBO(255, 255, 255, 1),
    );
  }
}
