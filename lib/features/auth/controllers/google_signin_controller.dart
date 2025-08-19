import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class RegisterController {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  RegisterController({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  // Handle Google Sign In for registration
  Future<Map<String, dynamic>> handleGoogleSignIn({
    required BuildContext context,
    required Function(bool) setLoading,
    VoidCallback? onSuccess,
  }) async {
    setLoading(true);

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        setLoading(false);
        return {'success': false, 'message': 'Sign-in cancelled by user'};
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Successfully signed in/registered
        final String? idToken = await user.getIdToken();

        // Send to your backend (replace with your logic)
        final response = await _sendToBackend(idToken!, user);

        print('Successfully signed in: ${user.email}');
        onSuccess?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully registered with Google!'),
            backgroundColor: Colors.green,
          ),
        );

        return {'success': true, 'data': response};
      }

      // If user is somehow null
      return {'success': false, 'message': 'User is null after sign-in'};
    } catch (e) {
      // Handle error
      print('Google sign-in error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google registration failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      return {'success': false, 'message': e.toString()};
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, dynamic>> _sendToBackend(
    String idToken,
    User firebaseUser,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://online-store-api-ashy.vercel.app/users/google-auth'),
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
