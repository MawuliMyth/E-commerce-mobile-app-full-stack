import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleAuthController {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  GoogleAuthController({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  // Shared method for Google Auth (works for both login & register)
  Future<Map<String, dynamic>> signInWithGoogle({
    required BuildContext context,
    required Function(bool) setLoading,
    VoidCallback? onSuccess,
  }) async {
    setLoading(true);

    try {
      // Step 1: Google sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setLoading(false);
        return {'success': false, 'message': 'Sign-in cancelled by user'};
      }

      // Step 2: Get Google Auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 3: Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        final String? idToken = await user.getIdToken();

        // Step 5: Send to backend (dynamic endpoint: login OR register)
        final response = await _sendToBackend(idToken!, user);

        onSuccess?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully signed in with Google!'),
            backgroundColor: Colors.green,
          ),
        );

        return {'success': true, 'data': response};
      }

      return {'success': false, 'message': 'User is null after sign-in'};
    } catch (e) {
      print('Google sign-in error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return {'success': false, 'message': e.toString()};
    } finally {
      setLoading(false);
    }
  }

  // 🔑 Shared backend call for login/register
  Future<Map<String, dynamic>> _sendToBackend(
    String idToken,
    User firebaseUser,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://online-store-api-ashy.vercel.app/api/users/google-auth',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'userData': {
            'uid': firebaseUser.uid,
            'email': firebaseUser.email,
            'displayName': firebaseUser.displayName,
            'photoURL': firebaseUser.photoURL,
          },
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Backend request failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Backend communication failed: $e');
    }
  }
}
