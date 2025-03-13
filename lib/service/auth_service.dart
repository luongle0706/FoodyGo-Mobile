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

      Map<String, dynamic> response =
          await authRepository.loginByGoogle(idToken!, fcmToken!);

      if (response['token'] != null) {
        SavedUser user = SavedUser(
            token: response['token'],
            email: response['email'],
            fullName: response['fullName'],
            role: response['role'],
            userId: response['userId'],
            customerId: response['customerId'],
            restaurantId: response['restaurantId'],
            hubId: response['hubId'],
            walletId: response['walletId']);

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

  void signIn(String email, String password, BuildContext context,
      Function(String) onError) async {
    try {
      String? fcmToken = await storage.get(key: 'fcm_token');
      LoginResponseDTO loginResponseDTO = await authRepository.login(
          request: LoginRequestDTO(email: email, password: password),
          fcmToken: fcmToken);

      if (loginResponseDTO.token.isNotEmpty) {
        SavedUser user = SavedUser(
            token: loginResponseDTO.token,
            email: email,
            fullName: loginResponseDTO.fullName,
            role: loginResponseDTO.role,
            userId: loginResponseDTO.userId,
            customerId: loginResponseDTO.customerId,
            restaurantId: loginResponseDTO.restaurantId,
            hubId: loginResponseDTO.hubId,
            walletId: loginResponseDTO.walletId);

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
        logger.error('Login failed');
        if (context.mounted) {
          onError("Đăng nhập thất bại. Vui lòng thử lại.");
        }
      }
    } catch (e) {
      logger.error(e.toString());
      if (context.mounted) {
        onError("Đăng nhập thất bại. Vui lòng thử lại.");
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
              onPressed: () => GoRouter.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void signOut(BuildContext context) async {
    String? fcmToken = await storage.get(key: 'fcm_token');
    await authRepository.optOut(fcmToken: fcmToken!);
    storage.delete(key: 'user');
    if (context.mounted) {
      GoRouter.of(context).go('/login');
    }
  }
}
