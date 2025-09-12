import 'package:ecommerce_firebase/Presentation/home_bot_nav.dart';
import 'package:ecommerce_firebase/Presentation/welcome_screen.dart';
import 'package:ecommerce_firebase/features/cart/views/cart_view.dart';
import 'package:ecommerce_firebase/features/dashboard/views/dashboard_view.dart';
import 'package:ecommerce_firebase/features/filter/views/filter_view.dart';
import 'package:ecommerce_firebase/features/wishlist/views/wishlist_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/controllers/forgot_password_controller.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/register_view.dart';
import 'features/dashboard/category_provider.dart';
import 'features/profile/views/profile_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: WelcomeScreen.id,
        routes: {
          WelcomeScreen.id: (context) => const WelcomeScreen(),
          LoginView.id: (context) => const LoginView(),
          RegisterView.id: (context) => const RegisterView(),
          ForgotPasswordView.id: (context) => const ForgotPasswordView(),
          ProfileView.id: (context) => const ProfileView(),
          CartView.id: (context) => const CartView(),
          FilterView.id: (context) => const FilterView(),
          DashboardView.id: (context) => const DashboardView(),
          WishlistView.id: (context) => const WishlistView(),
          HomeBotnav.id: (context) => const HomeBotnav(),
        },
      ),
    );
  }
}
