import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../models/login_model.dart';
import '../provider/auth_provider.dart';
import 'auth_controller.dart';
import 'auth_utils.dart';

class LoginController {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final AuthController _authController = AuthController();
  final String _loginApiUrl =
      'https://online-store-api-ashy.vercel.app/api/users/login';

  LoginController({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<void> handleEmailPasswordLogin({
    required String phone,
    required String password,
    required BuildContext context,
    required Function(bool) setLoading,
    VoidCallback? onSuccess,
  }) async {
    setLoading(true);
    try {
      final loginModel = LoginModel(
        phone: phone.trim(),
        password: password.trim(),
      );

      final response = await http.post(
        Uri.parse(_loginApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginModel.toJson()),
      );

      print(
        'LoginController: API Response = ${response.body}, statusCode=${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['tokens']?['accessToken'];
        final refreshToken = data['tokens']?['refreshToken'];

        if (accessToken == null || refreshToken == null) {
          throw Exception('Missing tokens in API response');
        }

        final authModel = AuthModel(
          fullname: data['data']['fullname'] ?? data['data']['name'] ?? 'User',
          email: data['data']['email'] ?? '',
          password: password.trim(),
          phone: data['data']['phone'] ?? phone.trim(),
          userId:
              data['data']['_id']?.toString() ?? data['data']['id']?.toString(),
          token: accessToken,
        );

        print(
          'LoginController: Storing tokens and user data - fullname=${authModel.fullname}, accessToken=$accessToken',
        );
        await _authController.storeTokens(accessToken, refreshToken);
        await _authController.storeUserData(authModel);

        print(
          'LoginController: Updating AuthProvider with fullname=${authModel.fullname}, userId=${authModel.userId}',
        );

        if (context.mounted) {
          Provider.of<AuthProvider>(context, listen: false).setUser(authModel);
        }

        await AuthUtils.handleSuccessfulLogin(
          context: context,
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: authModel,
        );

        onSuccess?.call();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully signed in!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('LoginController: Error = $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  Future<void> handleGoogleSignIn({
    required BuildContext context,
    required Function(bool) setLoading,
    VoidCallback? onSuccess,
  }) async {
    setLoading(true);
    try {
      print('🔵 Step 1: Starting Google Sign-In...');

      // Step 1: Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ Google Sign-In cancelled by user');
        setLoading(false);
        return;
      }

      print('✅ Google user signed in: ${googleUser.email}');
      print('🔵 Step 2: Getting Google authentication...');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('✅ Got Google Auth tokens');
      print('   - accessToken present: ${googleAuth.accessToken != null}');
      print('   - idToken present: ${googleAuth.idToken != null}');

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      print('🔵 Step 3: Authenticating with Firebase...');

      // Step 2: Authenticate with Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Google user authentication failed');
      }

      print('✅ Firebase authentication successful');
      print('   - User UID: ${user.uid}');
      print('   - User Email: ${user.email}');

      print('🔵 Step 4: Sending to backend...');

      // FIXED: Get Firebase token - this is what backend expects
      final String? firebaseIdToken = await user.getIdToken();

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Failed to get Firebase ID token');
      }

      print('✅ Got Firebase token:');
      print(
        '   - Token (first 50 chars): ${firebaseIdToken.substring(0, firebaseIdToken.length > 50 ? 50 : firebaseIdToken.length)}...',
      );

      // Step 4: Send to backend - SIMPLIFIED payload
      final backendUrl = Uri.parse(
        'https://online-store-api-ashy.vercel.app/api/users/google-auth',
      );

      final requestBody = {
        'idToken': firebaseIdToken, // Send Firebase token
        'email': user.email,
        'name': user.displayName,
      };

      print('📤 Sending request to backend:');
      print('   - URL: $backendUrl');
      print('   - Email: ${user.email}');
      print('   - Name: ${user.displayName}');

      final response = await http
          .post(
            backendUrl,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Backend request timed out after 30 seconds');
            },
          );

      print('📥 Backend Response:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Google authentication failed on backend',
        );
      }

      final data = jsonDecode(response.body);

      print('🔍 Parsing backend response...');
      print('   - Response keys: ${data.keys.toList()}');

      // Handle different response structures
      final accessToken = data['tokens']?['accessToken'] ?? data['accessToken'];
      final refreshToken =
          data['tokens']?['refreshToken'] ?? data['refreshToken'];
      final userData = data['data'] ?? data['user'];

      if (accessToken == null || refreshToken == null) {
        print('❌ Missing tokens in response');
        print('   - Full response: $data');
        throw Exception('Missing tokens in backend response');
      }

      print('✅ Got tokens from backend');
      print(
        '   - accessToken (first 20 chars): ${accessToken.toString().substring(0, accessToken.toString().length > 20 ? 20 : accessToken.toString().length)}...',
      );

      print('🔵 Step 5: Storing tokens and user data...');

      // Step 5: Store your backend-issued JWTs
      await _authController.storeTokens(accessToken, refreshToken);

      final authModel = AuthModel(
        fullname: userData['fullname'] ?? user.displayName ?? 'Google User',
        email: userData['email'] ?? user.email ?? '',
        password: '',
        phone: userData['phone'] ?? user.phoneNumber ?? '',
        userId: userData['_id'] ?? userData['id'] ?? user.uid,
        token: accessToken,
      );

      await _authController.storeUserData(authModel);

      print('✅ Tokens and user data stored');
      print('🔵 Step 6: Updating AuthProvider...');

      if (context.mounted) {
        Provider.of<AuthProvider>(context, listen: false).setUser(authModel);
      }

      print('✅ AuthProvider updated');
      print('🔵 Step 7: Handling successful login...');

      await AuthUtils.handleSuccessfulLogin(
        context: context,
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: authModel,
      );

      print('✅ Google Sign-In completed successfully!');

      onSuccess?.call();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in with Google!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ LoginController: Google Sign-In Error = $e');
      print('❌ Stack trace: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setLoading(false);
    }
  }
}
