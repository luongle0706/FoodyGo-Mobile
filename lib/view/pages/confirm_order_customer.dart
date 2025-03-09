import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/cart_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';

class ConfirmOrderPage extends StatefulWidget {
  final int restaurantId;
  const ConfirmOrderPage({super.key, required this.restaurantId});

  @override
  State<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  final _storage = SecureStorage.instance;
  final _logger = AppLogger.instance;
  final _cartRepository = CartRepository.instance;
  // List<dynamic>? _cartItems;
  SavedUser? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadUser() async {
    String? userData = await _storage.get(key: 'user');
    SavedUser? user =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
    if (user != null) {
      setState(() {
        _user = user;
      });
      bool fetchedCartItems = await fetchItemsInCart(user: user);

      if (fetchedCartItems) {
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

  Future<bool> fetchItemsInCart({required SavedUser user}) async {
    List<dynamic>? data = await _cartRepository.getCartByRestaurant(
        accessToken: _user?.token,
        userId: _user?.userId,
        restaurantId: widget.restaurantId);
    if (data != null) {
      // int total = data.isNotEmpty
      //     ? data
      //         .map((item) => ((item['price'] as num).toInt() *
      //             (item['quantity'] as num).toInt()))
      //         .reduce((a, b) => a + b)
      //     : 0;
      // int totalQuantity = data.isNotEmpty
      //     ? data
      //         .map((item) => (item['quantity'] as num).toInt())
      //         .reduce((a, b) => a + b)
      //     : 0;
      // setState(() {
      //   _cartItems = data;
      // });
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Xác nhận giao hàng"),
            leading: GestureDetector(
              onTap: () {
                GoRouter.of(context).go('/protected/home');
              },
              child: Icon(Icons.arrow_back),
            ),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Xác nhận giao hàng"),
        leading: GestureDetector(
          onTap: () {
            GoRouter.of(context).go('/protected/home');
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 16),
        child: Column(
          children: [
            //address section
            Divider(),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.location_on),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Địa chỉ giao hàng",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text("Quận Nguyễn | 0113114115"),
                      Text("Tòa C3"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(),
            const SizedBox(height: 10),
            //Restaurant name
            Row(
              children: [
                Icon(Icons.local_restaurant),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Xoài Non số dách - Mắm ruốt bao thêm - Nhà hàng Gil Lê",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow:
                        TextOverflow.ellipsis, // Add "..." if text is too long
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Order Details
            Row(
              children: [
                // Image Placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://images.immediate.co.uk/production/volatile/sites/30/2020/08/chorizo-mozarella-gnocchi-bake-cropped-9ab73a3.jpg?resize=768,574',
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) {
                          return child;
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error);
                      },
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
                SizedBox(width: 8),

                // Item Name & Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("1 x Xoài non mắm ruốt"),
                    ],
                  ),
                ),
                Text("59.000đ", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            // Price Breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tổng giá món"),
                Text("59.000đ"),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Phí giao hàng"),
                Text("59.000đ"),
              ],
            ),
            Divider(),

            // Total Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tổng thanh toán",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("59.000đ",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            Spacer(),
            // Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 189, 75, 3),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  GoRouter.of(context).go("/order-success");
                },
                child: Text("Đặt Đơn", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
