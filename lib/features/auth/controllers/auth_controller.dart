import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/auth_model.dart';

class AuthController {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final String _refreshTokenUrl = 'https://online-store-api-ashy.vercel.app/api/users/refresh-token';

  Future<void> storeTokens(String accessToken, String refreshToken) async {
    print('AuthController: Storing tokens - accessToken=$accessToken, refreshToken=$refreshToken');
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<void> storeUserData(AuthModel authModel) async {
    print('AuthController: Storing user data - fullname=${authModel.fullname}, userId=${authModel.userId}');
    await _storage.write(key: 'userData', value: jsonEncode(authModel.toJson()));
  }

  Future<AuthModel?> getUserData() async {
    final userDataJson = await _storage.read(key: 'userData');
    if (userDataJson != null) {
      try {
        final userData = jsonDecode(userDataJson);
        final authModel = AuthModel.fromJson(userData);
        print('AuthController: Retrieved user data - fullname=${authModel.fullname}, userId=${authModel.userId}');
        return authModel;
      } catch (e) {
        print('AuthController: Error parsing user data = $e');
        return null;
      }
    }
    print('AuthController: No user data found');
    return null;
  }

  Future<String?> getAccessToken() async {
    final accessToken = await _storage.read(key: 'accessToken');
    print('AuthController: Retrieved accessToken=$accessToken');
    return accessToken;
  }

  Future<String?> getRefreshToken() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    print('AuthController: Retrieved refreshToken=$refreshToken');
    return refreshToken;
  }

  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    final userData = await getUserData();
    bool isAuthenticated = accessToken != null && accessToken.isNotEmpty && userData != null;
    print('AuthController: isAuthenticated=$isAuthenticated');
    return isAuthenticated;
  }

  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        print('AuthController: No refresh token available');
        return false;
      }

      final response = await http.post(
        Uri.parse(_refreshTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      print('AuthController: Refresh token API Response = ${response.body}, statusCode=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['tokens']['accessToken'];
        final newRefreshToken = data['tokens']['refreshToken'];
        await storeTokens(newAccessToken, newRefreshToken);
        print('AuthController: Tokens refreshed successfully');
        return true;
      } else {
        print('AuthController: Failed to refresh token, statusCode=${response.statusCode}, response=${response.body}');
        return false;
      }
    } catch (e) {
      print('AuthController: Error refreshing token = $e');
      return false;
    }
  }

  Future<void> clearTokens() async {
    print('AuthController: Clearing tokens and user data');
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'userData');
  }
}