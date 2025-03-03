import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodygo/firebase_options.dart';
import 'package:foodygo/service/notification_service.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/components/hub/hub_home_wrapper.dart';
import 'package:foodygo/view/pages/add_to_cart.dart';
import 'package:foodygo/view/pages/add_topping_section.dart';
import 'package:foodygo/view/pages/confirm_order.dart';
import 'package:foodygo/view/pages/detail_order.dart';
import 'package:foodygo/view/pages/empty_page.dart';
import 'package:foodygo/view/pages/food_detail.dart';
import 'package:foodygo/view/pages/notification_page.dart';
import 'package:foodygo/view/pages/restaurant_home.dart';
import 'package:foodygo/view/pages/wallet/foodyxu_history_page.dart';
import 'package:foodygo/view/pages/home.dart';
import 'package:foodygo/view/pages/hub/staff_arrived_page.dart';
import 'package:foodygo/view/pages/hub/staff_home_history_page.dart';
import 'package:foodygo/view/pages/login.dart';
import 'package:foodygo/view/pages/order_history.dart';
import 'package:foodygo/view/pages/order_success.dart';
import 'package:foodygo/view/pages/profile.dart';
import 'package:foodygo/view/pages/profile_detail_page.dart';
import 'package:foodygo/view/pages/protected_routes.dart';
import 'package:foodygo/view/pages/register.dart';
import 'package:foodygo/view/pages/register_info.dart';
import 'package:foodygo/view/pages/otp.dart';
import 'package:foodygo/view/pages/register_success.dart';
import 'package:foodygo/view/pages/restaurant/food_link_page.dart';
import 'package:foodygo/view/pages/restaurant/topping_selection_page.dart';
import 'package:foodygo/view/pages/restaurant_detail.dart';
import 'package:foodygo/view/pages/restaurant_foodygo_page.dart';
import 'package:foodygo/view/pages/restaurant_home_page.dart';
import 'package:foodygo/view/pages/restaurant_menu.dart';
import 'package:foodygo/view/pages/hub/staff_home_page.dart';
import 'package:foodygo/view/pages/wallet/topup_page.dart';
import 'package:foodygo/view/pages/wallet/transaction_detail_detail.dart';
import 'package:foodygo/view/pages/wallet/transfer_points_page.dart';
import 'package:foodygo/view/pages/view_cart.dart';
import 'package:foodygo/view/pages/wallet/wallet_homepage.dart';
import 'package:foodygo/view/pages/wallet/withdraw_page.dart';
import 'package:go_router/go_router.dart';

void main() async {
  // Setup Firebase
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.instance.initialize();
  runApp(Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  Future<bool> isAuthenticated() async {
    String? savedUser = await SecureStorage.instance.get(key: 'user');
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
                    return MaterialPage(child: HomePage());
                  },
                ),
                GoRoute(
                  name: 'protected_restaurant_home',
                  path: '/protected/restaurant-home',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: RestaurantHomePage());
                  },
                ),
                GoRoute(
                  name: 'protected_staff_home',
                  path: '/protected/staff-home',
                  pageBuilder: (context, state) {
                    return MaterialPage(
                        child: HubHomeWrapper(child: StaffHomePage()));
                  },
                ),
                GoRoute(
                  name: 'protected_staff_home_arrived',
                  path: '/protected/staff-home-arrived',
                  pageBuilder: (context, state) {
                    return MaterialPage(
                        child: HubHomeWrapper(child: StaffArrivedPage()));
                  },
                ),
                GoRoute(
                  name: 'protected_staff_home_history',
                  path: '/protected/staff-home-history',
                  pageBuilder: (context, state) {
                    return MaterialPage(
                        child: HubHomeWrapper(child: StaffHomeHistoryPage()));
                  },
                ),
                GoRoute(
                  name: 'protected_restaurant_foodygo',
                  path: '/protected/restaurant-foodygo',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: RestaurantFoodygoPage());
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
                  name: 'order_success',
                  path: '/order-success',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: OrderSuccessPage());
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
                    return MaterialPage(child: UserProfileScreen());
                  },
                ),
                GoRoute(
                  name: 'protected_user_detail',
                  path: '/protected/user/detail',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: ProfileDetailPage());
                  },
                ),
                GoRoute(
                  name: 'protected_add_to_cart',
                  path: '/protected/add-to-cart',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: AddToCartPage());
                  },
                ),
                GoRoute(
                  name: 'protected_view_cart',
                  path: '/protected/view-cart',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: ViewCartPage());
                  },
                ),
              ]),
          GoRoute(
              name: 'detail_order',
              path: '/protected/detail-order',
              pageBuilder: (context, state) {
                return MaterialPage(child: DetailOrder());
              }),
          GoRoute(
              name: 'order_history',
              path: '/protected/order-history',
              pageBuilder: (context, state) {
                return MaterialPage(child: OrderHistory());
              }),
          GoRoute(
              name: 'restaurant_menu',
              path: '/protected/restaurant_menu',
              pageBuilder: (context, state) {
                return MaterialPage(child: RestaurantMenu());
              }),
          GoRoute(
              name: 'restaurant_home',
              path: '/protected/restaurant_home',
              pageBuilder: (context, state) {
                return MaterialPage(child: RestaurantHome());
              }),
          GoRoute(
              name: 'protected_restaurant_detail',
              path: '/protected/restaurant-detail/:id',
              pageBuilder: (context, state) {
                final restaurantId = int.parse(state.pathParameters['id']!);
                return MaterialPage(
                    child: RestaurantDetailPage(restaurantId: restaurantId));
              }),
          GoRoute(
            name: 'protected_add_topping_section',
            path: '/protected/add-topping-section',
            pageBuilder: (context, state) {
              return MaterialPage(child: AddToppingSection());
            },
          ),
          GoRoute(
            name: 'protected_topping_selection',
            path: '/protected/topping-selection',
            pageBuilder: (context, state) {
              return MaterialPage(child: ToppingSelectionPage());
            },
          ),
          GoRoute(
            name: 'food_link',
            path: '/protected/food-link',
            pageBuilder: (context, state) {
              return MaterialPage(child: FoodLinkPage());
            },
          ),
          GoRoute(
              name: 'confirm_order',
              path: '/confirm-order',
              pageBuilder: (context, state) {
                return MaterialPage(child: ConfirmOrderPage());
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
