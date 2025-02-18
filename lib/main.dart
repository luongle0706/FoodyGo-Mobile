import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foodygo/firebase_options.dart';
import 'package:foodygo/utils/injection.dart';
import 'package:foodygo/view/pages/add_to_cart_page.dart';
import 'package:foodygo/view/pages/detail_order.dart';
import 'package:foodygo/view/pages/empty_page.dart';
import 'package:foodygo/view/pages/food_detail.dart';
import 'package:foodygo/view/pages/foodyxu_history_page.dart';
import 'package:foodygo/view/pages/login.dart';
import 'package:foodygo/view/pages/profile.dart';
import 'package:foodygo/view/pages/protected_routes.dart';
import 'package:foodygo/view/pages/register.dart';
import 'package:foodygo/view/pages/register_info.dart';
import 'package:foodygo/view/pages/otp.dart';
import 'package:foodygo/view/pages/register_success.dart';
import 'package:foodygo/view/pages/topup_page.dart';
import 'package:foodygo/view/pages/transaction_detail_detail.dart';
import 'package:foodygo/view/pages/transfer_points_page.dart';
import 'package:foodygo/view/pages/wallet_homepage.dart';
import 'package:foodygo/view/pages/withdraw_page.dart';
import 'package:go_router/go_router.dart';

void main() async {
  // Setup Firebase
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        initialLocation: '/protected/home',
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
                    return MaterialPage(child: WalletHomepage());
                  },
                ),
                GoRoute(
                  name: 'protected_wallet_transaction_history',
                  path: '/protected/wallet/transaction-history',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: FoodyXuHistoryPage());
                  },
                ),
                GoRoute(
                  name: 'protected_wallet_transaction_detail',
                  path: '/protected/wallet/transaction-detail',
                  pageBuilder: (context, state) {
                    return MaterialPage(
                        child: TransactionDetailScreen(
                      transactionTitle: 'Sample Title',
                      transactionAmount: '100.0',
                      transactionStatus: 'Completed',
                      transactionId: '12345',
                      transactionDateTime: DateTime.now().toIso8601String(),
                      currentBalance: '500.0',
                    ));
                  },
                ),
                GoRoute(
                  name: 'protected_wallet_topup',
                  path: '/protected/wallet/topup',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: TopupPage());
                  },
                ),
                GoRoute(
                  name: 'protected_wallet_transfer',
                  path: '/protected/wallet/transfer',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: TransferPointsPage());
                  },
                ),
                GoRoute(
                  name: 'protected_wallet_withdraw',
                  path: '/protected/wallet/withdraw',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: WithdrawPage());
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
                ),
                GoRoute(
                  name: 'protected_add_to_cart',
                  path: '/protected/add-to-cart',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: AddToCartPage());
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
              name: 'detail_order',
              path: '/protected/detail-order',
              pageBuilder: (context, state) {
                return MaterialPage(child: DetailOrder());
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
              name: 'register info',
              path: '/register-info',
              pageBuilder: (context, state) {
                return MaterialPage(child: RegisterInfo());
              }),
          GoRoute(
              name: 'otp',
              path: '/otp',
              pageBuilder: (context, state) {
                return MaterialPage(child: OtpPage());
              }),
          GoRoute(
            name: 'protected_food_detail',
            path: '/protected/product',
            pageBuilder: (context, state) {
              return MaterialPage(child: FoodDetailPage());
            },
          ),
          GoRoute(
            name: 'registerSuccess',
            path: '/registerSuccess',
            pageBuilder: (context, state) {
              return MaterialPage(child: RegisterSuccessPage());
            },
          ),
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
