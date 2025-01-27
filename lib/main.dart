import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foodygo/pages/home.dart';
import 'package:foodygo/pages/login.dart';
import 'package:foodygo/pages/profile.dart';
import 'package:foodygo/pages/register.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  Main({super.key});

  final storage = FlutterSecureStorage();

  final List<String> publicRoutes = ['/login', '/register'];

  Future<bool> isAuthenticated() async {
    // String? token = await storage.read(key: 'token');
    // return token != null;
    return true;
  }

  GoRouter get _router => GoRouter(
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
          final isAuthenticated = await this.isAuthenticated();
          final isPublicRoute = publicRoutes.contains(state.matchedLocation);
          if (!isAuthenticated && !isPublicRoute) return '/login';
          if (isAuthenticated && state.matchedLocation == '/login') return '/';
          return null;
        },
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
