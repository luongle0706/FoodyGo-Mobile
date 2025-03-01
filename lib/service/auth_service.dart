import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodygo/dto/login_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/firebase_options.dart';
import 'package:foodygo/repository/auth_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final logger = AppLogger.instance;
  final storage = SecureStorage.instance;
  final authRepository = AuthRepository.instance;

  void signInWithGoogle(BuildContext context) async {
    UserCredential result;

    try {
      final googleSignIn = GoogleSignIn(clientId: flutter_client_id, scopes: [
        'email',
      ]);
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final cred = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);

      result = await _auth.signInWithCredential(cred);
      String? idToken = await result.user?.getIdToken();

      logger.info("ID TOKEN: $idToken");

      String? fcmToken = await storage.get(key: 'fcm_token');
      logger.info('Fetched fcm_token: $fcmToken');

      LoginResponseDTO loginResponseDTO =
          await authRepository.loginByGoogle(idToken!, fcmToken!);

      logger.info("Backend token: ${loginResponseDTO.token}");

      if (loginResponseDTO.token.isNotEmpty) {
        SavedUser user = SavedUser(
            token: loginResponseDTO.token,
            email: loginResponseDTO.email,
            fullName: loginResponseDTO.fullName,
            role: loginResponseDTO.role);

        storage.put(key: 'user', value: json.encode(user.toJson()));

        if (context.mounted) {
          GoRouter.of(context).go('/protected/home');
        }
      } else {
        if (context.mounted) {
          _showErrorDialog(context, "Login failed. Please try again.");
        }
      }
      // print(result.toString());
    } catch (error) {
      if (context.mounted) {
        _showErrorDialog(context, "Google failed");
      }
    }
  }

  void signIn(String email, String password, BuildContext context) async {
    try {
      LoginResponseDTO loginResponseDTO = await authRepository
          .login(LoginRequestDTO(email: email, password: password));

      if (loginResponseDTO.token.isNotEmpty) {
        SavedUser user = SavedUser(
            token: loginResponseDTO.token,
            email: email,
            fullName: loginResponseDTO.fullName,
            role: loginResponseDTO.role);

        storage.put(key: 'user', value: json.encode(user.toJson()));

        if (context.mounted) {
          if (user.role == 'ROLE_USER') {
            GoRouter.of(context).go('/protected/home');
          } else if (user.role == 'ROLE_SELLER') {
            GoRouter.of(context).go('/protected/restaurant-home');
          } else {
            GoRouter.of(context).go('/protected/staff-home');
          }
        }
      } else {
        logger.error('login failed');
        if (context.mounted) {
          _showErrorDialog(context, "Login failed. Please try again.");
        }
      }
    } catch (e) {
      logger.error(e.toString());
      // logger.error(e.toString());
      // if (context.mounted) {
      //   _showErrorDialog(
      //       context, "Login failed. Please check your credentials.");
      // }
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
    storage.delete(key: 'user');
    if (context.mounted) {
      GoRouter.of(context).go('/login');
    }
  }
}
