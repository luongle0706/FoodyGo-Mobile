import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/restaurant_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/restaurant_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class RestaurantHome extends StatefulWidget {
  const RestaurantHome({super.key});

  @override
  State<RestaurantHome> createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends State<RestaurantHome> {
  final _storage = SecureStorage.instance;
  final AppLogger _logger = AppLogger.instance;
  final RestaurantRepository _restaurantRepository =
      RestaurantRepository.instance;
  RestaurantDto? _restaurantDto;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<bool> fetchRestaurant({required SavedUser user}) async {
    RestaurantDto? fetchOrder = await _restaurantRepository.loadRestaurantById(
        user.token, user.restaurantId!);

    if (fetchOrder != null) {
      setState(() {
        _restaurantDto = fetchOrder;
      });
      return true;
    }
    return false;
  }

  Future<void> loadUser() async {
    String? userData = await _storage.get(key: 'user');
    SavedUser? user =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
    if (user != null) {
      bool fetchOrderData = await fetchRestaurant(user: user);

      if (fetchOrderData) {
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = true;
        });
      }
    } else {
      _logger.info('Failed to load user');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> menuItems = [
    {"icon": Icons.receipt_long, "title": "Đơn hàng"},
    {"icon": Icons.restaurant_menu, "title": "Thực đơn"},
    {"icon": Icons.bar_chart, "title": "Báo cáo"},
    {"icon": Icons.storefront, "title": "Thông tin"},
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _restaurantDto != null
                ? Text(
                    _restaurantDto!.name,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : SizedBox(),
            GestureDetector(
              onTap: () {
                GoRouter.of(context)
                    .push("/protected/open-hours-setting", extra: 1);
              },
              child: _restaurantDto != null
                  ? Row(
                      children: [
                        Icon(Icons.circle,
                            size: 11,
                            color: _restaurantDto!.available
                                ? Colors.green
                                : Colors.grey),
                        SizedBox(width: 5),
                        Text(
                          _restaurantDto!.available ? "Mở cửa " : "Đóng cửa ",
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: _restaurantDto!.available
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 15, color: Colors.white),
                      ],
                    )
                  : SizedBox(),
            )
          ],
        ),
      ),
      body: _restaurantDto == null
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
              ),
            )
          : Padding(
              padding: EdgeInsets.only(top: 0),
              child: Container(
                color: AppColors.background,
                padding: EdgeInsets.all(35),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    return _buildMenuItem(
                        menuItems[index]["icon"], menuItems[index]["title"]);
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {});
        if (title == "Thực đơn") {
          GoRouter.of(context)
              .go('/protected/restaurant-foodygo', extra: {'chosenTab': 1});
        } else if (title == "Đơn hàng") {
          GoRouter.of(context).go('/protected/restaurant-foodygo');
        } else if (title == "Báo cáo") {
        } else if (title == "Thông tin") {
          GoRouter.of(context).go('/protected/notifications');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: AppColors.primary,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
