import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../models/auth_model.dart';
import '../provider/auth_provider.dart';

class AuthUtils {
  static Future<void> handleSuccessfulLogin({
    required BuildContext context,
    required String accessToken,
    required String refreshToken,
    required AuthModel user,
  }) async {
    final authController = AuthController();
    await authController.storeTokens(accessToken, refreshToken);
    await authController.storeUserData(user);

    Provider.of<AuthProvider>(context, listen: false).setUser(user);
  }
}
