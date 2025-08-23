import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../models/login_model.dart';
import '../models/auth_model.dart';
import '../provider/auth_provider.dart';
import 'auth_controller.dart';

class LoginController {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final AuthController _authController = AuthController();
  final String _loginApiUrl = 'https://online-store-api-ashy.vercel.app/api/users/login';

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

      print('LoginController: API Response = ${response.body}, statusCode=${response.statusCode}');

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
          userId: data['data']['_id']?.toString() ?? data['data']['id']?.toString(),
          token: accessToken,
        );

        print('LoginController: Storing tokens and user data - fullname=${authModel.fullname}, accessToken=$accessToken');
        await _authController.storeTokens(accessToken, refreshToken);
        await _authController.storeUserData(authModel);

        print('LoginController: Updating AuthProvider with fullname=${authModel.fullname}, userId=${authModel.userId}');
        Provider.of<AuthProvider>(context, listen: false).setUser(authModel);

        onSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('LoginController: Error = $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
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
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final authModel = AuthModel(
          fullname: userCredential.user!.displayName ?? 'Google User',
          email: userCredential.user!.email ?? '',
          password: '',
          phone: userCredential.user!.phoneNumber ?? '',
          userId: userCredential.user!.uid,
          token: googleAuth.accessToken,
        );

        print('LoginController: Storing user data - fullname=${authModel.fullname}, token=${authModel.token}');
        await _authController.storeUserData(authModel);
        if (googleAuth.accessToken != null) {
          print('LoginController: Storing Google tokens - accessToken=${googleAuth.accessToken}');
          await _authController.storeTokens(googleAuth.accessToken!, googleAuth.accessToken!);
        }

        print('LoginController: Updating AuthProvider with fullname=${authModel.fullname}');
        Provider.of<AuthProvider>(context, listen: false).setUser(authModel);

        onSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in with Google!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('LoginController: Google Sign-In Error = $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setLoading(false);
    }
  }
}