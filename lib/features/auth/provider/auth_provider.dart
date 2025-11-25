import 'package:ecommerce_firebase/features/auth/models/auth_model.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../controllers/auth_controller.dart';

class AuthProvider extends ChangeNotifier {
  AuthModel? _user;

  AuthModel? get user => _user;

  void setUser(AuthModel user) {
    _user = user;
    print(
      'AuthProvider: User set with fullname=${user.fullname}, userId=${user.userId}',
    );
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    print('AuthProvider: User cleared');
    notifyListeners();
  }

  void forceLogout() async {
    final authController = AuthController();
    await authController.clearTokens();
    _user = null;
    notifyListeners();

    Navigator.pushNamedAndRemoveUntil(
      navigatorKey.currentState!.context,
      '/login',
      (route) => false,
    );
  }
}
