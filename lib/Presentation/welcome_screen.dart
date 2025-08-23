import 'package:ecommerce_firebase/features/auth/views/register_view.dart';
import 'package:ecommerce_firebase/features/auth/controllers/auth_controller.dart';
import 'package:ecommerce_firebase/features/auth/provider/auth_provider.dart';
import 'package:ecommerce_firebase/Presentation/home_bot_nav.dart';
import 'package:ecommerce_firebase/widgets/circle_icon_button.dart';
import 'package:ecommerce_firebase/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/views/login_view.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    print('WelcomeScreen: Checking authentication status');
    bool isAuthenticated = await _authController.isAuthenticated();
    if (isAuthenticated) {
      print('WelcomeScreen: User is authenticated, fetching user data');
      bool success = await _fetchUserData(context);
      if (success) {
        print('WelcomeScreen: User data fetched, navigating to HomeBotnav');
        Navigator.pushReplacementNamed(context, HomeBotnav.id);
      } else {
        print('WelcomeScreen: Failed to fetch user data, attempting token refresh');
        bool refreshed = await _authController.refreshAccessToken();
        if (refreshed) {
          print('WelcomeScreen: Token refresh successful, retrying user data fetch');
          success = await _fetchUserData(context);
          if (success) {
            print('WelcomeScreen: User data fetched after refresh, navigating to HomeBotnav');
            Navigator.pushReplacementNamed(context, HomeBotnav.id);
          } else {
            print('WelcomeScreen: Failed to fetch user data after refresh');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to load user data. Please log in again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          print('WelcomeScreen: Token refresh failed, staying on welcome screen');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print('WelcomeScreen: User is not authenticated, attempting token refresh');
      bool refreshed = await _authController.refreshAccessToken();
      if (refreshed) {
        print('WelcomeScreen: Token refresh successful, fetching user data');
        bool success = await _fetchUserData(context);
        if (success) {
          print('WelcomeScreen: User data fetched after refresh, navigating to HomeBotnav');
          Navigator.pushReplacementNamed(context, HomeBotnav.id);
        } else {
          print('WelcomeScreen: Failed to fetch user data after refresh');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('WelcomeScreen: Token refresh failed, staying on welcome screen');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _fetchUserData(BuildContext context) async {
    try {
      final authModel = await _authController.getUserData();
      if (authModel != null) {
        print('WelcomeScreen: Updating AuthProvider with fullname=${authModel.fullname}, userId=${authModel.userId}');
        Provider.of<AuthProvider>(context, listen: false).setUser(authModel);
        return true;
      } else {
        print('WelcomeScreen: No user data found in storage');
        return false;
      }
    } catch (e) {
      print('WelcomeScreen: Error fetching user data = $e');
      return false;
    }
  }

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
            onPressed: () {
              Navigator.pushNamed(context, RegisterView.id);
            },
            color: Color(0xff004CFF),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: Text(
                  'I already have an account',
                  style: TextStyle(color: Color(0xff202020)),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, LoginView.id);
                },
              ),
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