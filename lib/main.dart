import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodygo/firebase_options.dart';
import 'package:foodygo/service/notification_service.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/components/hub/hub_home_wrapper.dart';
import 'package:foodygo/view/pages/add_to_cart.dart';
import 'package:foodygo/view/pages/notification_page.dart';
import 'package:foodygo/view/pages/restaurant/add_edit_category.dart';
import 'package:foodygo/view/pages/restaurant/add_topping_item.dart';
import 'package:foodygo/view/pages/restaurant/add_topping_section.dart';
import 'package:foodygo/view/pages/restaurant/confirm_order_restaurant.dart';
import 'package:foodygo/view/pages/detail_order.dart';
import 'package:foodygo/view/pages/empty_page.dart';
import 'package:foodygo/view/pages/food_detail.dart';
import 'package:foodygo/view/pages/restaurant/open_hours_setting.dart';
import 'package:foodygo/view/pages/restaurant/order_detail_restaurant.dart';
import 'package:foodygo/view/pages/restaurant/product_detail_restaurant.dart';
import 'package:foodygo/view/pages/restaurant/topping_section_setting.dart';
import 'package:foodygo/view/pages/restaurant_home.dart';
import 'package:foodygo/view/pages/wallet/foodyxu_history_page.dart';
import 'package:foodygo/view/pages/home.dart';
import 'package:foodygo/view/pages/hub/staff_arrived_page.dart';
import 'package:foodygo/view/pages/hub/staff_home_history_page.dart';
import 'package:foodygo/view/pages/login.dart';
import 'package:foodygo/view/pages/order_view_customer.dart';
import 'package:foodygo/view/pages/restaurant/order_view_restaurant.dart';
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
import 'package:foodygo/view/pages/restaurant_menu.dart';
import 'package:foodygo/view/pages/hub/staff_home_page.dart';
import 'package:foodygo/view/pages/wallet/payment_history_page.dart';
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
        initialLocation: '/login',
        routes: [
          ShellRoute(
              builder: (context, state, child) {
                return ProtectedRoutes(child: child);
              },
              routes: [
                GoRoute(
                  name: 'protected_home', // S-006
                  path: '/protected/home',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: HomePage());
                  },
                ),
                GoRoute(
                  name: 'protected_restaurant_home', // S-033
                  path: '/protected/restaurant-home',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: RestaurantHome());
                  },
                ),
                GoRoute(
                    name: 'notifications', // S-032
                    path: '/protected/notifications',
                    pageBuilder: (context, state) {
                      return MaterialPage(child: NotificationPage());
                    }),
                GoRoute(
                  name: 'protected_staff_home', // S-040
                  path: '/protected/staff-home',
                  pageBuilder: (context, state) {
                    return MaterialPage(
                        child: HubHomeWrapper(child: StaffHomePage()));
                  },
                ),
                GoRoute(
                  name: 'protected_staff_home_arrived', //S-041
                  path: '/protected/staff-home-arrived',
                  pageBuilder: (context, state) {
                    return MaterialPage(
                        child: HubHomeWrapper(child: StaffArrivedPage()));
                  },
                ),
                GoRoute(
                  name: 'protected_staff_home_history', //S-042
                  path: '/protected/staff-home-history',
                  pageBuilder: (context, state) {
                    return MaterialPage(
                        child: HubHomeWrapper(child: StaffHomeHistoryPage()));
                  },
                ),
                GoRoute(
                    name: 'order_list_restaurant',
                    path: '/protected/restaurant-foodygo', //S-022
                    pageBuilder: (context, state) {
                      return MaterialPage(child: OrderListRestaurantPage());
                    }),
                GoRoute(
                    name: 'order_list_customer',
                    path: 'protected/order-list-customer',
                    pageBuilder: (context, state) {
                      return MaterialPage(child: OrderListCustomerPage());
                    }),
                GoRoute(
                    name: 'confirm_order',
                    path: '/protected/confirm-order',
                    pageBuilder: (context, state) {
                      return MaterialPage(
                          child: ConfirmedOrderRestaurantScreen());
                    }),
                GoRoute(
                  name: 'protected_order',
                  path: '/protected/order',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: EmptyPage());
                  },
                ),
                GoRoute(
                  name: 'protected_wallet', //S-027
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
                  name: 'protected_wallet_payment_history',
                  path: '/protected/wallet/payment-history',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: PaymentHistoryPage());
                  },
                ),
                GoRoute(
                  name: 'protected_wallet_transaction_detail',
                  path: '/protected/wallet/transaction-detail',
                  pageBuilder: (context, state) {
                    // Extract transaction details from the extra data
                    final extra = state.extra as Map<String, dynamic>? ?? {};

                    return MaterialPage(
                      child: TransactionDetailScreen(
                        transactionTitle:
                            extra['transactionTitle'] ?? 'Giao dịch',
                        transactionAmount:
                            extra['transactionAmount'] ?? '0 FoodyXu',
                        transactionStatus:
                            extra['transactionStatus'] ?? 'Thành công',
                        transactionId: extra['transactionId'] ?? '',
                        transactionDateTime: extra['transactionDateTime'] ?? '',
                        currentBalance: extra['currentBalance'] ?? '0 FoodyXu',
                      ),
                    );
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
                  name: 'protected_wallet_topup', //S-035
                  path: '/protected/wallet/topup',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: TopupPage());
                  },
                ),
                GoRoute(
                  name: 'protected_wallet_transfer', //S-037
                  path: '/protected/wallet/transfer',
                  pageBuilder: (context, state) {
                    return MaterialPage(child: TransferPointsPage());
                  },
                ),
                GoRoute(
                  name: 'protected_wallet_withdraw', //S-36
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
                GoRoute(
                    name: 'restaurant_menu', // S-016
                    path: '/protected/restaurant_menu',
                    pageBuilder: (context, state) {
                      return MaterialPage(child: RestaurantMenu());
                    })
              ]),
          GoRoute(
              name: 'detail_order', // S-014
              path: '/protected/detail-order',
              pageBuilder: (context, state) {
                return MaterialPage(child: DetailOrder());
              }),
          GoRoute(
              name: 'order_history', // S-015
              path: '/order-history',
              pageBuilder: (context, state) {
                return MaterialPage(child: OrderHistory());
              }),
          GoRoute(
            name: 'protected_restaurant_detail', // S-007
            path: '/protected/restaurant-detail',
            pageBuilder: (context, state) {
              final restaurantDto = state.extra as Map<String, dynamic>;
              return MaterialPage(
                child: RestaurantDetailPage(restaurantDto: restaurantDto),
              );
            },
          ),
          GoRoute(
            name: 'protected_open_hours_seting', // S-038
            path: '/protected/open-hours-setting',
            pageBuilder: (context, state) {
              return MaterialPage(child: OpenHoursSetting());
            },
          ),
          GoRoute(
            name: 'protected_add_topping_section', // S-019
            path: '/protected/add-topping-section',
            pageBuilder: (context, state) {
              return MaterialPage(child: AddToppingSection());
            },
          ),
          GoRoute(
            name: 'protected_topping_section_setting', // S-020
            path: '/protected/topping-section-setting',
            pageBuilder: (context, state) {
              return MaterialPage(child: ToppingSectionSetting());
            },
          ),
          GoRoute(
            name: 'protected_add_topping_item', // S-021
            path: '/protected/add-topping-item',
            pageBuilder: (context, state) {
              return MaterialPage(child: AddToppingItem());
            },
          ),
          GoRoute(
            name: 'protected_order_detail_restaurant', // S-026
            path: '/protected/order-detail-restaurant',
            pageBuilder: (context, state) {
              return MaterialPage(child: OrderDetailRestaurant());
            },
          ),
          GoRoute(
            name: 'protected_add_edit_category', // S-039
            path: '/protected/add-edit-category',
            pageBuilder: (context, state) {
              return MaterialPage(child: AddEditCategory());
            },
          ),
          GoRoute(
            name: 'protected_topping_selection', // S-043
            path: '/protected/topping-selection',
            pageBuilder: (context, state) {
              return MaterialPage(child: ToppingSelectionPage());
            },
          ),
          GoRoute(
            name: 'protected_product_detail_restaurant', // S-045
            path: '/protected/product-detail-restaurant',
            pageBuilder: (context, state) {
              return MaterialPage(child: ProductDetailRestaurant());
            },
          ),
          GoRoute(
            name: 'food_link', // S-034
            path: '/protected/food-link',
            pageBuilder: (context, state) {
              return MaterialPage(child: FoodLinkPage());
            },
          ),
          GoRoute(
              name: 'login', //S-001
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
