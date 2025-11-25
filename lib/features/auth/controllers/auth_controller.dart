import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/auth_model.dart';

class AuthController {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final String _refreshTokenUrl =
      'https://online-store-api-ashy.vercel.app/api/users/refresh-token';

  Future<void> storeTokens(String accessToken, String refreshToken) async {
    print(
      'AuthController: Storing tokens - accessToken=$accessToken, refreshToken=$refreshToken',
    );
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<void> storeUserData(AuthModel authModel) async {
    print(
      'AuthController: Storing user data - fullname=${authModel.fullname}, userId=${authModel.userId}',
    );
    await _storage.write(
      key: 'userData',
      value: jsonEncode(authModel.toJson()),
    );
  }

  Future<AuthModel?> getUserData() async {
    final userDataJson = await _storage.read(key: 'userData');
    if (userDataJson != null) {
      try {
        final userData = jsonDecode(userDataJson);
        final authModel = AuthModel.fromJson(userData);
        print(
          'AuthController: Retrieved user data - fullname=${authModel.fullname}, userId=${authModel.userId}',
        );
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
    bool isAuthenticated =
        accessToken != null && accessToken.isNotEmpty && userData != null;
    print('AuthController: isAuthenticated=$isAuthenticated');
    return isAuthenticated;
  }

  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ AuthController: No refresh token available');
        return false;
      }

      print('🔄 AuthController: Attempting to refresh token...');
      print(
        '🔑 Refresh Token (first 20 chars): ${refreshToken.substring(0, refreshToken.length > 20 ? 20 : refreshToken.length)}...',
      );

      final response = await http.post(
        Uri.parse(_refreshTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      print(
        '📡 AuthController: Refresh Response StatusCode=${response.statusCode}',
      );
      print('📡 AuthController: Refresh Response Body=${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check what structure we received
        print('📦 Response keys: ${data.keys.toList()}');
        print('📦 Full response data: $data');

        // Extract tokens - your backend returns them at root level
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];

        print('🔍 newAccessToken present: ${newAccessToken != null}');
        print('🔍 newRefreshToken present: ${newRefreshToken != null}');

        if (newAccessToken == null || newRefreshToken == null) {
          print('❌ AuthController: Missing tokens in response');
          print('   accessToken: $newAccessToken');
          print('   refreshToken: $newRefreshToken');
          return false;
        }

        print(
          '✅ New AccessToken (first 20 chars): ${newAccessToken.toString().substring(0, newAccessToken.toString().length > 20 ? 20 : newAccessToken.toString().length)}...',
        );

        await storeTokens(newAccessToken, newRefreshToken);
        print('✅ AuthController: Tokens refreshed and stored successfully');
        return true;
      } else {
        print(
          '❌ AuthController: Refresh failed with status ${response.statusCode}',
        );
        print('   Response: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ AuthController: Error refreshing token = $e');
      print('❌ Stack trace: $stackTrace');
      return false;
    }
  }

  Future<void> clearTokens() async {
    print('AuthController: Clearing tokens and user data');
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'userData');
  }

  Future<http.Response> authenticatedRequest(
    Uri url, {
    String method = 'GET',
    Map<String, String>? headers,
    dynamic body,
  }) async {
    headers ??= {};
    headers['Content-Type'] = 'application/json';

    final accessToken = await getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    print('🔐 Making $method request to ${url.path}');
    print(
      '🔑 Using token: ${accessToken?.substring(0, accessToken.length > 20 ? 20 : accessToken.length)}...',
    );

    http.Response response = await _sendRequest(url, method, headers, body);

    print('📡 Response status: ${response.statusCode}');

    // ✅ Handle both 401 AND 403 for expired tokens
    if (response.statusCode == 401 || response.statusCode == 403) {
      print('🔄 Access token expired (${response.statusCode}) → refreshing...');

      final refreshed = await refreshAccessToken();
      if (!refreshed) {
        print('❌ Refresh failed → user must logout.');
        await clearTokens();
        throw Exception("TOKEN_EXPIRED");
      }

      // Retry with new token
      final newAccessToken = await getAccessToken();
      headers['Authorization'] = 'Bearer $newAccessToken';
      print('🔄 Retrying request with new token...');
      response = await _sendRequest(url, method, headers, body);
      print('📡 Retry response status: ${response.statusCode}');
    }

    return response;
  }

  // INTERNAL REQUEST SENDER ---------------------------------------------------
  Future<http.Response> _sendRequest(
    Uri url,
    String method,
    Map<String, String> headers,
    dynamic body,
  ) async {
    switch (method.toUpperCase()) {
      case 'POST':
        return http.post(url, headers: headers, body: jsonEncode(body));
      case 'PUT':
        return http.put(url, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return http.delete(url, headers: headers);
      default:
        return http.get(url, headers: headers);
    }
  }
}
