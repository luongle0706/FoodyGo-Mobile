import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/cart_repository.dart';
import 'package:foodygo/repository/product_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/components/button.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class FoodDetailPage extends StatefulWidget {
  final int restaurantId;
  final int productId;

  const FoodDetailPage(
      {super.key, required this.restaurantId, required this.productId});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final _storage = SecureStorage.instance;
  final AppLogger _logger = AppLogger.instance;
  final ProductRepository _productRepository = ProductRepository.instance;
  final CartRepository _cartRepository = CartRepository.instance;
  SavedUser? _user;
  ProductDto? _product;
  bool _isLoading = true;
  int _cartItemCount = 0;
  int _cartTotal = 0;

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
      bool fetchedItemsInCart = await fetchItemsInCart(user: user);

      if (fetchedProduct && fetchedItemsInCart) {
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
    ProductDto? fetchProduct =
        await _productRepository.getProductById(widget.productId, user.token);
    if (fetchProduct != null) {
      setState(() {
        _product = fetchProduct;
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> fetchItemsInCart({required SavedUser user}) async {
    List<dynamic>? data = await _cartRepository.getCartByRestaurant(
        accessToken: _user?.token,
        userId: _user?.userId,
        restaurantId: widget.restaurantId);
    if (data != null) {
      int total = data.isNotEmpty
          ? data
              .where((item) => item['productId'] == widget.productId)
              .map((item) => ((item['price'] as num).toInt() *
                  (item['quantity'] as num).toInt()))
              .fold(0, (a, b) => a + b)
          : 0;
      int totalQuantity = data.isNotEmpty
          ? data
              .where((item) => item['productId'] == widget.productId)
              .map((item) => (item['quantity'] as num).toInt())
              .fold(0, (a, b) => a + b)
          : 0;
      setState(() {
        _cartItemCount = totalQuantity;
        _cartTotal = total;
      });
      return true;
    } else {
      return false;
    }
  }

  Future<void> addToCart({required ProductDto product}) async {
    bool result = await _cartRepository.addToCart(
        accessToken: _user?.token,
        userId: _user?.userId,
        restaurantId: widget.restaurantId,
        productId: product.id,
        productName: product.name,
        price: product.price,
        image: product.image,
        quantity: 1);
    if (result) {
      fetchItemsInCart(user: _user!);
    } else {
      _logger.info('failed');
    }
  }

  Future<void> removeFromCart({required ProductDto product}) async {
    bool result = await _cartRepository.removeFromCart(
        productId: product.id,
        userId: _user?.userId,
        accessToken: _user?.token);
    if (result) {
      fetchItemsInCart(user: _user!);
    } else {
      _logger.info('Failed to delete item from cart');
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

                  _cartItemCount > 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Price section
                            Row(
                              children: [
                                Text(
                                  '${NumberFormat("#,###", "vi_VN").format(_cartTotal)}đ',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // Quantity control
                            Row(
                              children: [
                                // Remove button
                                InkWell(
                                  onTap: _cartItemCount > 0
                                      ? () => removeFromCart(product: _product!)
                                      : null,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _cartItemCount > 0
                                          ? Colors.white
                                          : Colors.grey.shade300,
                                      border: Border.all(
                                        color: _cartItemCount > 0
                                            ? Colors.red
                                            : Colors.grey,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          4), // Square corners
                                    ),
                                    child: Icon(Icons.remove,
                                        color: _cartItemCount > 0
                                            ? Colors.red
                                            : Colors.grey,
                                        size: 20),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Quantity text
                                Text(
                                  '$_cartItemCount',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                // Add button
                                InkWell(
                                  onTap: () => addToCart(product: _product!),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(
                                          4), // Square corners
                                    ),
                                    child: const Icon(Icons.add,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : MyButton(
                          onTap: () => addToCart(product: _product!),
                          text:
                              'Thêm vào giỏ hàng - ${NumberFormat("#,###", "vi_VN").format(_product?.price)}đ',
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
