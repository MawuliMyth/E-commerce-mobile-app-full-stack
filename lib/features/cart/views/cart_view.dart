import 'package:flutter/material.dart';

class CartView extends StatefulWidget {
  static String id = 'cart_view';

  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor);
  }
}
