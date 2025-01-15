import 'package:flutter/material.dart';
import 'package:foodygo/pages/home.dart';
import 'package:foodygo/pages/login.dart';
import 'package:foodygo/pages/profile.dart';
import 'package:foodygo/pages/register.dart';
import 'package:go_router/go_router.dart';

class MyAppRouter {
  static final MyAppRouter _instance =
      MyAppRouter._internal(isAuthenticated: false);
  factory MyAppRouter() => _instance;
  MyAppRouter._internal({required this.isAuthenticated});

  final bool isAuthenticated;

  GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
          name: 'home',
          path: '/',
          pageBuilder: (context, state) {
            return MaterialPage(child: HomePage());
          }),
      GoRoute(
          name: 'login',
          path: '/login',
          pageBuilder: (context, state) {
            return MaterialPage(child: LoginPage());
          }),
      GoRoute(
          name: 'register',
          path: '/register',
          pageBuilder: (context, state) {
            return MaterialPage(child: RegisterPage());
          }),
      GoRoute(
          name: 'profile',
          path: '/profile/:username',
          pageBuilder: (context, state) {
            return MaterialPage(
                child: ProfilePage(
              username: state.pathParameters['username'],
            ));
          })
    ],
  );
}
