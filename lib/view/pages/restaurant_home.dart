import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/restaurant_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/repository/restaurant_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/pages/restaurant/order_view_restaurant.dart';
// import 'package:foodygo/view/pages/restaurant/order_view_restaurant.dart';
import 'package:foodygo/view/pages/welcome_screen.dart';
import 'package:go_router/go_router.dart';

class RestaurantHome extends StatefulWidget {
  final int restaurantId;

  const RestaurantHome({super.key, required this.restaurantId});

  @override
  State<RestaurantHome> createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends State<RestaurantHome> {
  final _storage = SecureStorage.instance;
  final AppLogger _logger = AppLogger.instance;
  final RestaurantRepository _restaurantRepository =
      RestaurantRepository.instance;
  SavedUser? _user;
  RestaurantDto? _restaurantDto;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<bool> fetchRestaurant(String accessToken) async {
    RestaurantDto? fetchOrder = await _restaurantRepository.loadRestaurantById(
        accessToken, widget.restaurantId);

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
      setState(() {
        _user = user;
      });
      bool fetchOrderData = await fetchRestaurant(user.token);

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _restaurantDto != null
                ? Text(
                    _restaurantDto!.name,
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
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
                            size: 15, color: Colors.grey),
                      ],
                    )
                  : SizedBox(), // Tránh lỗi khi _restaurantDto chưa có giá trị
            )
          ],
        ),
      ),
      body: _restaurantDto == null
          ? Center(
              child:
                  CircularProgressIndicator()) // Hiển thị vòng loading khi dữ liệu chưa sẵn sàng
          : Padding(
              padding: EdgeInsets.only(top: 0),
              child: Container(
                color: Colors.grey.shade300,
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
        if (title == "Thực đơn") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
          );
        } else if (title == "Đơn hàng") {
          Navigator.push(
            context,
            // MaterialPageRoute(builder: (context) => OrderListRestaurantPage()),
            MaterialPageRoute(builder: (context) => OrderListRestaurantPage()),
          );
        } else if (title == "Báo cáo") {
          Navigator.push(
            context,
            // MaterialPageRoute(builder: (context) => OrderListRestaurantPage()),
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
          );
        } else if (title == "Thông tin") {
          Navigator.push(
            context,
            // MaterialPageRoute(builder: (context) => OrderListRestaurantPage()),
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade400, blurRadius: 3, spreadRadius: 1),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black),
            SizedBox(height: 10),
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
