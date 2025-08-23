import 'package:flutter/material.dart';
import 'package:ecommerce_firebase/features/auth/models/auth_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthModel? _user;

  AuthModel? get user => _user;

  void setUser(AuthModel user) {
    _user = user;
    print('AuthProvider: User set with fullname=${user.fullname}, userId=${user.userId}');
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    print('AuthProvider: User cleared');
    notifyListeners();
  }
}