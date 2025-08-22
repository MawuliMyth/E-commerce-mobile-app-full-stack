import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class AuthController {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final String _refreshTokenUrl = 'https://online-store-api-ashy.vercel.app/api/users/refresh-token';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<void> storeTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    print('Tokens stored: accessToken=$accessToken, refreshToken=$refreshToken');
  }

  Future<String?> getAccessToken() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    print('Retrieved access token: $accessToken');
    return accessToken;
  }

  Future<String?> getRefreshToken() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    print('Retrieved refresh token: $refreshToken');
    return refreshToken;
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    print('Tokens cleared');
  }

  Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      print('No refresh token available');
      return false;
    }

    try {
      print('Attempting to refresh access token with refreshToken=$refreshToken');
      final response = await http.post(
        Uri.parse(_refreshTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['tokens']['accessToken'];
        final newRefreshToken = data['tokens']['refreshToken'] ?? refreshToken;
        await storeTokens(newAccessToken, newRefreshToken);
        print('Access token refreshed successfully: newAccessToken=$newAccessToken');
        return true;
      } else {
        print('Token refresh failed: statusCode=${response.statusCode}, response=${response.body}');
        await clearTokens();
        return false;
      }
    } catch (e) {
      print('Error during token refresh: $e');
      await clearTokens();
      return false;
    }
  }

  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    print('Checking authentication status: accessToken=$accessToken');
    if (accessToken == null) return false;
    return true;
  }
}