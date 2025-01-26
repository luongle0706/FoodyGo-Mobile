import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foodygo/pages/home.dart';
import 'package:foodygo/pages/login.dart';
import 'package:foodygo/pages/profile.dart';
import 'package:foodygo/pages/register.dart';
import 'package:go_router/go_router.dart';

class MyAppRouter {
  static final MyAppRouter _instance = MyAppRouter._internal();
  factory MyAppRouter() => _instance;
  MyAppRouter._internal();

  final storage = FlutterSecureStorage();

  Future<bool> isAuthenticated() async {
    String? token = await storage.read(key: 'token');
    return token != null;
  }

  final List<String> publicRoutes = [
    '/login',
    '/register',
  ];

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
      redirect: (context, state) async {
        final isAuthenticated = await _instance.isAuthenticated();
        final isPublicRoute =
            _instance.publicRoutes.contains(state.matchedLocation);
        if (!isAuthenticated && !isPublicRoute) return '/login';
        if (isAuthenticated && state.matchedLocation == '/login') return '/';
        return null;
      });
}
