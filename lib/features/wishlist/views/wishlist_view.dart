import 'package:flutter/material.dart';


class WishlistView extends StatefulWidget {
  static String id = 'wishlist_view';

  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,


    );
  }
}
