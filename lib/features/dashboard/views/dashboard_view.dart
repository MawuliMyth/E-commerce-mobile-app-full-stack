import 'package:ecommerce_firebase/features/dashboard/views/search_view.dart';
import 'package:ecommerce_firebase/features/dashboard/widgets/poster_widget.dart';
import 'package:ecommerce_firebase/widgets/circle_icon_button.dart';
import 'package:ecommerce_firebase/widgets/searchbar_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Presentation/category_screen.dart';
import '../../../theme/theme_controller.dart';
import '../widgets/category_grid_widget.dart';

class DashboardView extends StatefulWidget {
  static const String id = 'dashboard_view';

  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Shop',
                    style: TextStyle(
                      fontSize: screenWidth * 0.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.5,
                    child: SearchbarField(
                      onTap: () {
                        Navigator.pushNamed(context, SearchView.id);
                      },
                    ),
                  ),
                  Switch.adaptive(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Poster carousel
              const PosterCarousel(),
              const SizedBox(height: 20),

              // Categories header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleIconButton(
                        icon: Icons.arrow_forward,
                        onPressed: () {
                          Navigator.pushNamed(context, CategoriesScreen.id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Category grid
              const Expanded(child: CategoriesView()),

              const SizedBox(height: 20),

              // Flash Sale header
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'Flash Sale',
              //       style: TextStyle(
              //         fontSize: screenWidth * 0.05,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //     Row(
              //       children: [
              //         Text(
              //           'See All',
              //           style: TextStyle(
              //             fontSize: screenWidth * 0.05,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //         const SizedBox(width: 10),
              //         CircleIconButton(
              //           icon: Icons.arrow_forward,
              //           onPressed: () {
              //             // TODO: Navigate to Flash Sale screen
              //           },
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
