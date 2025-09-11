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
        Provider.of<AuthProvider>(
          context,
          listen: false,
        ).setUser(updatedAuthModel);

        onSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('RegisterController: Error = $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setLoading(false);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      if (userCredential.user != null) {
        final authModel = AuthModel(
          fullname: userCredential.user!.displayName ?? 'Google User',
          email: userCredential.user!.email ?? '',
          password: '',
          phone: userCredential.user!.phoneNumber ?? '',
          userId: userCredential.user!.uid,
          token: googleAuth.accessToken,
        );

        print(
          'RegisterController: Storing user data - fullname=${authModel.fullname}, token=${authModel.token}',
        );
        await _authController.storeUserData(authModel);
        if (googleAuth.accessToken != null) {
          print(
            'RegisterController: Storing Google tokens - accessToken=${googleAuth.accessToken}',
          );
          await _authController.storeTokens(
            googleAuth.accessToken!,
            googleAuth.accessToken!,
          );
        }

        print(
          'RegisterController: Updating AuthProvider with fullname=${authModel.fullname}',
        );
        Provider.of<AuthProvider>(context, listen: false).setUser(authModel);

        onSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered with Google!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('RegisterController: Google Sign-In Error = $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google registration failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setLoading(false);
    }
  }
}
