// import 'package:ecommerce_firebase/features/profile/views/category_screen.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  static const String id = 'profile_view';
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,    );
  }
}
