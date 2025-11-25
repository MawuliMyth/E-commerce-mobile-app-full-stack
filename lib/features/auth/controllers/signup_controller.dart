import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../provider/auth_provider.dart';
import 'auth_controller.dart';

class RegisterController {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final AuthController _authController = AuthController();
  final String _registerApiUrl =
      'https://online-store-api-ashy.vercel.app/api/users/register';

  RegisterController({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<void> handleEmailPasswordRegistration({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required BuildContext context,
    required Function(bool) setLoading,
    VoidCallback? onSuccess,
  }) async {
    setLoading(true);
    try {
      final authModel = AuthModel(
        fullname: fullName.trim(),
        email: email.trim(),
        password: password.trim(),
        phone: phone.trim(),
      );

      final response = await http.post(
        Uri.parse(_registerApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(authModel.toJson()),
      );

      print(
        'RegisterController: API Response = ${response.body}, statusCode=${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final accessToken = data['tokens']?['accessToken'];
        final refreshToken = data['tokens']?['refreshToken'];

        if (accessToken == null || refreshToken == null) {
          throw Exception('Missing tokens in API response');
        }

        final updatedAuthModel = AuthModel(
          fullname:
              data['data']['fullname'] ??
              data['data']['name'] ??
              fullName.trim(),
          email: data['data']['email'] ?? email.trim(),
          password: password.trim(),
          phone: data['data']['phone'] ?? phone.trim(),
          userId:
              data['data']['_id']?.toString() ?? data['data']['id']?.toString(),
          token: accessToken,
        );

        print(
          'RegisterController: Storing tokens and user data - fullname=${updatedAuthModel.fullname}, accessToken=$accessToken',
        );
        await _authController.storeTokens(accessToken, refreshToken);
        await _authController.storeUserData(updatedAuthModel);

        print(
          'RegisterController: Updating AuthProvider with fullname=${updatedAuthModel.fullname}',
        );

        if (context.mounted) {
          Provider.of<AuthProvider>(
            context,
            listen: false,
          ).setUser(updatedAuthModel);
        }

        onSuccess?.call();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully registered!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('RegisterController: Error = $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
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
      print('🔵 Starting Google Sign-In for Registration...');

      // Step 1: Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ Google Sign-In cancelled by user');
        setLoading(false);
        return;
      }

      print('✅ Google user signed in: ${googleUser.email}');

      // Step 2: Get Google authentication
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      print('✅ Got Google Auth tokens');

      // Step 3: Authenticate with Firebase
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
      print('   - User Email: ${user.email}');

      // FIXED: Get Firebase token - this is what backend expects
      final String? firebaseIdToken = await user.getIdToken();

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Failed to get Firebase ID token');
      }

      print('🔵 Sending to backend for registration...');

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
              throw Exception('Backend request timed out');
            },
          );

      print('📥 Backend Response: ${response.statusCode}');
      print('   - Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Google registration failed');
      }

      final data = jsonDecode(response.body);

      // Parse tokens
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

      // Step 5: Store tokens and user data
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

      // Update AuthProvider
      if (context.mounted) {
        Provider.of<AuthProvider>(context, listen: false).setUser(authModel);
      }

      print('✅ Google Sign-In Registration completed successfully!');

      onSuccess?.call();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered with Google!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ RegisterController: Google Sign-In Error = $e');
      print('❌ Stack trace: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google registration failed: ${e.toString()}'),
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
