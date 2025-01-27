import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foodygo/dto/login_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/auth_repository.dart';
import 'package:foodygo/utils/injection.dart';
import 'package:go_router/go_router.dart';

class AuthService {
  void signIn(String email, String password, BuildContext context) async {
    LoginResponseDTO loginResponseDTO = await locator<AuthRepository>()
        .login(LoginRequestDTO(email: email, password: password));

    SavedUser user = SavedUser(token: loginResponseDTO.token, email: email);

    locator<FlutterSecureStorage>()
        .write(key: 'user', value: json.encode(user.toJson()));
    if (context.mounted) {
      GoRouter.of(context).go('/');
    }
  }
}
