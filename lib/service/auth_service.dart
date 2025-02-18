import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foodygo/dto/login_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/firebase_options.dart';
import 'package:foodygo/repository/auth_repository.dart';
import 'package:foodygo/utils/injection.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  void signInWithGoogle(BuildContext context) async {
    UserCredential result;

    try {
      final googleSignIn = GoogleSignIn(clientId: flutter_client_id, scopes: [
        'email',
        // 'profile'
        // 'https://www.googleapis.com/auth/contacts.readonly',
      ]);

      final googleUser = await googleSignIn.signIn();

      final googleAuth = await googleUser?.authentication;

      final cred = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);

      // print("ACCESS TOKEN: ");
      // print(googleAuth?.accessToken);

      result = await _auth.signInWithCredential(cred);
      String? idToken = await result.user?.getIdToken();

      locator<AuthRepository>().test(idToken!);

      print("REAL ID TOKEN: ");
      print(idToken);

      // print(result.toString());
    } catch (error) {
      print(error.toString());
    }
  }

  void signIn(String email, String password, BuildContext context) async {
    try {
      LoginResponseDTO loginResponseDTO = await locator<AuthRepository>()
          .login(LoginRequestDTO(email: email, password: password));

      if (loginResponseDTO.token.isNotEmpty) {
        SavedUser user = SavedUser(token: loginResponseDTO.token, email: email);
        await locator<FlutterSecureStorage>()
            .write(key: 'user', value: json.encode(user.toJson()));

        if (context.mounted) {
          GoRouter.of(context).go('/protected/home');
        }
      } else {
        if (context.mounted) {
          _showErrorDialog(context, "Login failed. Please try again.");
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(
            context, "Login failed. Please check your credentials.");
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void signOut(BuildContext context) async {
    locator<FlutterSecureStorage>().delete(key: 'user');
    if (context.mounted) {
      GoRouter.of(context).go('/login');
    }
  }
}
