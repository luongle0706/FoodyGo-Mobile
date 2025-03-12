import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/dto/restaurant_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/cart_repository.dart';
import 'package:foodygo/repository/product_repository.dart';
import 'package:foodygo/repository/restaurant_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RestaurantDetailPage extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailPage({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final _storage = SecureStorage.instance;
  final RestaurantRepository _restaurantRepository =
      RestaurantRepository.instance;
  final ProductRepository _productRepository = ProductRepository.instance;
  final CartRepository _cartRepository = CartRepository.instance;
  final AppLogger _logger = AppLogger.instance;
  SavedUser? _user;
  RestaurantDto? _restaurant;
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
    if (user != null) {
      setState(() {
        _user = user;
      });
      bool fetchRestaurantById = await fetchRestaurant(user.token);
      bool fetchedProducts = await fetchProducts(user);
      bool fetchedCartItems = await fetchItemsInCart(user: user);

      if (fetchedProducts && fetchedCartItems && fetchRestaurantById) {
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

  Future<bool> fetchRestaurant(String accessToken) async {
    RestaurantDto? fetchRestaurant = await _restaurantRepository
        .loadRestaurantById(accessToken, widget.restaurantId);
    if (fetchRestaurant != null) {
      setState(() {
        _restaurant = fetchRestaurant;
      });
      return true;
    }
    return false;
  }

  Future<bool> fetchProducts(SavedUser user) async {
    List<ProductDto>? fetchProducts = await _productRepository
        .getProductsByRestaurantId(widget.restaurantId, user.token);
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
        restaurantId: widget.restaurantId,
        productId: product.id,
        productName: product.name,
        image: product.image,
        price: product.price,
        quantity: 1);
    if (result) {
      await fetchItemsInCart(user: _user!);
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
      await fetchItemsInCart(user: _user!);
    } else {
      _logger.info('Failed to delete item from cart');
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
              .map((item) => ((item['price'] as num).toInt() *
                  (item['quantity'] as num).toInt()))
              .reduce((a, b) => a + b)
          : 0;
      int totalQuantity = data.isNotEmpty
          ? data
              .map((item) => (item['quantity'] as num).toInt())
              .reduce((a, b) => a + b)
          : 0;
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
                        _restaurant!.name,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text("📞 ${_restaurant?.phone}"),
                      Text("✉️ ${_restaurant?.email}"),
                      Text("📍 ${_restaurant?.address}"),
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
                          'restaurantId': widget.restaurantId,
                          'productId': item.id
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item!.image,
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
                                Text(
                                    "Giá: ${NumberFormat("#,###", "vi_VN").format(item.price)}đ",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () => removeFromCart(product: item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  minimumSize: Size(32, 32),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                                child: Icon(Icons.remove,
                                    color: Colors.white, size: 18),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${_cartItems?.firstWhere((i) => i['productId'] == item.id, orElse: () => {
                                      'quantity': 0
                                    })['quantity']}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => addToCart(product: item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  minimumSize: Size(32, 32),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                                child: Icon(Icons.add,
                                    color: Colors.white, size: 18),
                              ),
                            ],
                          ),
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
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setModalState) {
                      return DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: 0.5,
                        minChildSize: 0.3,
                        maxChildSize: 0.9,
                        builder: (context, scrollController) {
                          return Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Giỏ hàng",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                Divider(),
                                Expanded(
                                  child: _cartItems == null ||
                                          _cartItems!.isEmpty
                                      ? Center(child: Text("Giỏ hàng trống"))
                                      : ListView.builder(
                                          controller: scrollController,
                                          itemCount: _cartItems!.length,
                                          itemBuilder: (context, index) {
                                            final item = _cartItems![index];
                                            final product = ProductDto(
                                                id: item['productId'],
                                                image: item['image'],
                                                code: item['productId']
                                                    .toString(),
                                                name: item['productName'],
                                                price: item['price'],
                                                description: '',
                                                prepareTime: 0.0,
                                                available: true);
                                            return ListTile(
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  item['image'],
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              title: Text(item['productName']),
                                              subtitle: Text(
                                                  "Giá: ${NumberFormat("#,###", "vi_VN").format(item['price'])}đ"),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.remove,
                                                        color: Colors.red),
                                                    onPressed: () async {
                                                      await removeFromCart(
                                                          product: product);
                                                      setModalState(() {});
                                                    },
                                                  ),
                                                  Text("${item['quantity']}"),
                                                  IconButton(
                                                    icon: Icon(Icons.add,
                                                        color: Colors.green),
                                                    onPressed: () async {
                                                      await addToCart(
                                                          product: product);
                                                      setModalState(() {});
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tổng: ${NumberFormat("#,###", "vi_VN").format(_cartTotal)}đ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        GoRouter.of(context).go(
                                            '/protected/confirm-order-cart/${widget.restaurantId}');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                      ),
                                      child: Text("Thanh toán"),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      );
                    });
                  },
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.shopping_cart, size: 24),
                  if (_cartItemCount > 0)
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
            ),
            Text(
              'Tổng: ${NumberFormat("#,###", "vi_VN").format(_cartTotal)}đ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context)
                    .go('/protected/confirm-order-cart/${widget.restaurantId}');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text("Thanh toán"),
            ),
          ],
        ),
      ),
    );
  }
}
