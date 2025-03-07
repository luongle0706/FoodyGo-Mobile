import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/product_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/components/button.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class FoodDetailPage extends StatefulWidget {
  final int productId;

  const FoodDetailPage({super.key, required this.productId});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final _storage = SecureStorage.instance;
  final AppLogger _logger = AppLogger.instance;
  final ProductRepository _productRepository = ProductRepository.instance;
  SavedUser? _user;
  ProductDto? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    String? userData = await _storage.get(key: 'user');
    SavedUser? user =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
    if (user != null) {
      setState(() {
        _user = user;
      });
      bool fetchedProduct = await fetchProduct(user);

      if (fetchedProduct) {
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

  Future<bool> fetchProduct(SavedUser user) async {
    ProductDto? fetchProduct = await _productRepository
        .getProductById(widget.productId, user.token);
    if (fetchProduct != null) {
      setState(() {
        _product = fetchProduct;
      });
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
      body: Column(
        children: [
          // Food image and back button
          Stack(
            children: [
              // Food image
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Cơm_Tấm%2C_Da_Nang%2C_Vietnam.jpg/1280px-Cơm_Tấm%2C_Da_Nang%2C_Vietnam.jpg',
                height: 300,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
              // Back button
              Positioned(
                top: 40,
                left: 10,
                child: GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Food detail
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food description
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cơm tấm sườn trứng",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text("Cơm tấm siêu cấp ngon"),
                        SizedBox(height: 4),
                        Text("Thời gian chuẩn bị: 15 phút"),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Add to cart
                  MyButton(
                      onTap: () {},
                      text: 'Thêm vào giỏ hàng',
                      color: AppColors.primary)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
