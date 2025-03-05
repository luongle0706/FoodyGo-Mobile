import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/dto/restaurant_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/product_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class RestaurantDetailPage extends StatefulWidget {
  final RestaurantDto restaurantDto;

  const RestaurantDetailPage({super.key, required this.restaurantDto});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final storage = SecureStorage.instance;
  final ProductRepository repository = ProductRepository.instance;
  AppLogger logger = AppLogger.instance;
  List<ProductDto>? products;
  SavedUser? user;
  bool isLoading = true;

  int cartTotal = 59000; // Sample cart total
  int cartItemCount = 1;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    String? data = await storage.get(key: 'user');
    SavedUser? savedUser =
        data != null ? SavedUser.fromJson(json.decode(data)) : null;

    if (savedUser != null) {
      List<ProductDto>? fetchProducts = await repository
          .getProductsByRestaurantId(widget.restaurantDto.id, savedUser.token);
      if (fetchProducts != null) {
        setState(() {
          products = fetchProducts;
          user = savedUser;
          isLoading = false;
        });
      } else {
        logger.info('Failed to load restaurant details');
        setState(() {
          user = savedUser;
        });
      }
    } else {
      logger.info('Failed to load user');
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Row(
            children: [
              CircularProgressIndicator(),
            ],
          ), // Show loading indicator
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // Restaurant Info
          Container(
            color: AppColors.background,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.restaurantDto.image,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.restaurantDto.name,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text("📞 ${widget.restaurantDto.phone}"),
                      Text("✉️ ${widget.restaurantDto.email}"),
                      Text("📍 ${widget.restaurantDto.address}"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(),
          // Menu List
          Expanded(
            child: ListView.builder(
              itemCount: products?.length,
              itemBuilder: (context, index) {
                final item = products?[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: Text("Ảnh đồ ăn"),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item!.name,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(item.description),
                            Text(
                                "⏳ Thời gian chuẩn bị: ${item.prepareTime.round()} phút"),
                            SizedBox(height: 4),
                            Text("Giá: ${item.price.toStringAsFixed(3)}đ",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Bottom Cart Summary
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, size: 24),
                SizedBox(width: 8),
                Text("Tổng cộng: ${cartTotal}đ",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Handle checkout
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text("Thanh toán"),
            )
          ],
        ),
      ),
    );
  }
}
