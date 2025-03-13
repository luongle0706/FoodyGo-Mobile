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

      setState(() {
        _isLoading = !(fetchedProduct && fetchedItemsInCart);
      });
    } else {
      _logger.info('Failed to load user');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> fetchProduct(SavedUser user) async {
    ProductDto? fetchedProduct =
        await _productRepository.getProductById(widget.productId, user.token);
    if (fetchedProduct != null) {
      setState(() {
        _product = fetchedProduct;
      });
      return true;
    }
    return false;
  }

  Future<bool> fetchItemsInCart({required SavedUser user}) async {
    List<dynamic>? data = await _cartRepository.getCartByRestaurant(
        accessToken: user.token,
        userId: user.userId,
        restaurantId: widget.restaurantId);

    if (data != null) {
      int total = data
          .where((item) => item['productId'] == widget.productId)
          .map((item) => ((item['price'] as num).toInt() *
              (item['quantity'] as num).toInt()))
          .fold(0, (a, b) => a + b);
      int totalQuantity = data
          .where((item) => item['productId'] == widget.productId)
          .map((item) => (item['quantity'] as num).toInt())
          .fold(0, (a, b) => a + b);

      setState(() {
        _cartItemCount = totalQuantity;
        _cartTotal = total;
      });
      return true;
    }
    return false;
  }

  Future<void> addToCart({required ProductDto product}) async {
    bool result = await _cartRepository.addToCart(
      accessToken: _user?.token,
      userId: _user?.userId,
      restaurantId: widget.restaurantId,
      productId: product.id,
      productName: product.name,
      image: product.image,
      price: product.price,
      quantity: 1,
    );
    if (result) {
      fetchItemsInCart(user: _user!);
    } else {
      _logger.info('Failed to add item to cart');
    }
  }

  Future<void> removeFromCart({required ProductDto product}) async {
    bool result = await _cartRepository.removeFromCart(
      productId: product.id,
      userId: _user?.userId,
      accessToken: _user?.token,
    );
    if (result) {
      fetchItemsInCart(user: _user!);
    } else {
      _logger.info('Failed to remove item from cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          // Food image and back button
          Stack(
            children: [
              // Food image
              Image.network(
                _product?.image ?? '',
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              // Back button
              Positioned(
                top: 40,
                left: 10,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),

          // Food detail
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.background),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _product?.name ?? "Không có tên",
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(_product?.description ?? "Không có mô tả"),
                        const SizedBox(height: 4),
                        Text(
                            "Thời gian chuẩn bị: ${_product?.prepareTime ?? 0} phút"),
                      ],
                    ),
                  ),

                  const Spacer(),

                  _cartItemCount > 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${NumberFormat("#,###", "vi_VN").format(_cartTotal)} xu',
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                _buildQuantityButton(
                                    Icons.remove,
                                    _cartItemCount > 0,
                                    () => removeFromCart(product: _product!)),
                                const SizedBox(width: 8),
                                Text('$_cartItemCount',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                _buildQuantityButton(Icons.add, true,
                                    () => addToCart(product: _product!)),
                              ],
                            ),
                          ],
                        )
                      : MyButton(
                          onTap: () => addToCart(product: _product!),
                          text:
                              'Thêm vào giỏ hàng - ${NumberFormat("#,###", "vi_VN").format(_product?.price ?? 0)} xu',
                          color: AppColors.primary,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
      IconData icon, bool isActive, VoidCallback onPressed) {
    return InkWell(
      onTap: isActive ? onPressed : null,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.red : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
