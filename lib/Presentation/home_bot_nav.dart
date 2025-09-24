import 'package:ecommerce_firebase/features/cart/views/cart_view.dart';
import 'package:ecommerce_firebase/features/dashboard/views/dashboard_view.dart';
import 'package:ecommerce_firebase/features/filter/views/filter_view.dart';
import 'package:ecommerce_firebase/features/profile/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/wishlist/views/wishlist_view.dart';
import '../theme/theme_controller.dart';
import '../widgets/custom_bottom_bar_nav.dart';

class HomeBotnav extends StatefulWidget {
  static String id = 'home_botnav';

  const HomeBotnav({super.key});

  @override
  State<HomeBotnav> createState() => _HomeBotnavState();
}

class _HomeBotnavState extends State<HomeBotnav> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    const DashboardView(),
    WishlistView(),
    FilterView(),
    CartView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: CustomBottomBarNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
