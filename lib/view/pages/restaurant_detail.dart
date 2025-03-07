import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/cart_repository.dart';
import 'package:foodygo/repository/product_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Map<String, dynamic> restaurantDto;

  const RestaurantDetailPage({super.key, required this.restaurantDto});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final _storage = SecureStorage.instance;
  final AppLogger logger = AppLogger.instance;
  final ProductRepository _productRepository = ProductRepository.instance;
  final CartRepository _cartRepository = CartRepository.instance;
  final AppLogger _logger = AppLogger.instance;
  SavedUser? _user;
  List<ProductDto>? _products;
  List<dynamic>? _cartItems;
  bool _isLoading = true;
  int _cartTotal = 0;
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    String? userData = await _storage.get(key: 'user');
    SavedUser? user =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
    logger.info('hello');
    if (user != null) {
      setState(() {
        _user = user;
      });
      bool fetchedProducts = await fetchProducts(user);
      bool fetchedCartItems = await fetchItemsInCart(user: user);

      if (fetchedProducts && fetchedCartItems) {
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

  Future<bool> fetchProducts(SavedUser user) async {
    List<ProductDto>? fetchProducts = await _productRepository
        .getProductsByRestaurantId(widget.restaurantDto['id'], user.token);
    if (fetchProducts != null) {
      setState(() {
        _products = fetchProducts;
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
        restaurantId: widget.restaurantDto['id'],
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: 1);
    if (result) {
      logger.info('success');
      fetchItemsInCart(user: _user!);
    } else {
      logger.info('failed');
    }
  }

  Future<bool> fetchItemsInCart({required SavedUser user}) async {
    List<dynamic>? data = await _cartRepository.getCartByRestaurant(
        accessToken: _user?.token,
        userId: _user?.userId,
        restaurantId: widget.restaurantDto['id']);
    if (data != null) {
      int total = data.isNotEmpty
          ? data
              .map((item) => ((item['price'] as num).toInt() *
                  (item['quantity'] as num).toInt()))
              .reduce((a, b) => a + b)
          : 0;
      int totalQuantity = data.isNotEmpty
          ? data
              .map((item) => (item['quantity'] as num).toInt())
              .reduce((a, b) => a + b)
          : 0;
      logger.info('Total price: $total');
      setState(() {
        _cartItems = data;
        _cartItemCount = totalQuantity;
        _cartTotal = total;
      });
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
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => GoRouter.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {},
              )
            ],
          ),
          body: SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
              // Show loading indicator
            ),
          ));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // Restaurant Info
          Container(
            color: AppColors.secondary,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Cơm_Tấm%2C_Da_Nang%2C_Vietnam.jpg/1280px-Cơm_Tấm%2C_Da_Nang%2C_Vietnam.jpg',
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
                        widget.restaurantDto['name'],
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text("📞 ${widget.restaurantDto['phone']}"),
                      Text("✉️ ${widget.restaurantDto['email']}"),
                      Text("📍 ${widget.restaurantDto['address']}"),
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
              itemCount: _products?.length,
              itemBuilder: (context, index) {
                final item = _products?[index];
                return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        GoRouter.of(context).push('/protected/product', extra: {
                          'restaurantId': widget.restaurantDto['id'],
                          'productId': item.id
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Cơm_Tấm%2C_Da_Nang%2C_Vietnam.jpg/1280px-Cơm_Tấm%2C_Da_Nang%2C_Vietnam.jpg',
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item!.name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Text(item.description),
                                Text(
                                    "⏳ Thời gian chuẩn bị: ${item.prepareTime.round()} phút"),
                                SizedBox(height: 4),
                                Text("Giá: ${item.price.round()}đ",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          TextButton(
                              onPressed: () => addToCart(product: item),
                              child: Text('+')),
                          Text(
                              '(Đã có ${_cartItems?.firstWhere((i) => i['productId'] == item.id, orElse: () => {
                                    'quantity': 0
                                  })['quantity']})')
                        ],
                      ),
                    ));
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.shopping_cart, size: 24),
                if (_cartItemCount > 0) // Only show if there are items
                  Positioned(
                    right: -10,
                    top: -20,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '$_cartItemCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            Text('Giỏ hàng: $_cartTotal'),
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
