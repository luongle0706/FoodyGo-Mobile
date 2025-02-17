import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foodygo/utils/injection.dart';
import 'package:foodygo/view/pages/empty_page.dart';
import 'package:foodygo/view/pages/login.dart';
import 'package:foodygo/view/pages/profile.dart';
import 'package:foodygo/view/pages/protected_routes.dart';
import 'package:foodygo/view/pages/register.dart';
import 'package:foodygo/view/pages/register_info.dart';
import 'package:go_router/go_router.dart';

void main() {
  setupInjection();
  runApp(Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  Future<bool> isAuthenticated() async {
    String? savedUser = await locator<FlutterSecureStorage>().read(key: 'user');
    return savedUser != null;
  }

  GoRouter get _router => GoRouter(
        initialLocation: '/register-info',
        routes: [
          ShellRoute(
              builder: (context, state, child) {
                return ProtectedRoutes(child: child);
              },
              routes: [
                GoRoute(
                  name: 'protected_home',
                  path: '/protected/home',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: EmptyPage());
                  },
                ),
                GoRoute(
                  name: 'protected_order',
                  path: '/protected/order',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: EmptyPage());
                  },
                ),
                GoRoute(
                  name: 'protected_wallet',
                  path: '/protected/wallet',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: EmptyPage());
                  },
                ),
                GoRoute(
                  name: 'protected_notification',
                  path: '/protected/notification',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: EmptyPage());
                  },
                ),
                GoRoute(
                  name: 'protected_user',
                  path: '/protected/user',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: ProfilePage());
                  },
                )
              ]),
          // GoRoute(
          //     name: 'home',
          //     path: '/',
          //     pageBuilder: (context, state) {
          //       return MaterialPage(child: HomePage());
          //     }),
          // GoRoute(
          //     name: 'splash_screen',
          //     path: '/splash',
          //     pageBuilder: (context, state) {
          //       return MaterialPage(child: SplashScreen());
          //     }),
          // GoRoute(
          //     name: 'welcome_screen',
          //     path: '/welcome',
          //     pageBuilder: (context, state) {
          //       return MaterialPage(child: WelcomeScreen());
          //     }),
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
              name: 'register info',
              path: '/register-info',
              pageBuilder: (context, state) {
                return MaterialPage(child: RegisterInfo());
              })
        ],
        redirect: (context, state) async {
          final isAuthenticated = await this.isAuthenticated();
          final isProtectedRoute = state.matchedLocation.contains('protected');
          if (isProtectedRoute && !isAuthenticated) {
            return '/login';
          } else {
            return null;
          }
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
