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
import 'package:foodygo/view/pages/add_to_cart.dart';
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

  Future<void> reloadCartItems() async {
    if (_user != null) {
      await fetchItemsInCart(user: _user!);
    }
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
    _logger.info("fetchProduct ${fetchProducts.toString()}");
    if (fetchProducts != null && fetchProducts.isNotEmpty) {
      for (var product in fetchProducts) {
        _logger.info("Sản phẩm: ${product.addonSections?.length}");
      }
    }
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

  Future<void> removeSpecificCartItem(dynamic cartItem) async {
    // Since we don't have a unique ID, we need to:
    // 1. Generate a fingerprint for the current item
    // 2. Find all items in cart with same productId
    // 3. Remove the one with matching addons

    String targetFingerprint =
        _cartRepository.generateItemFingerprint(cartItem);

    // Get current cart items
    List<dynamic>? currentCartItems = await _cartRepository.getCartByRestaurant(
        accessToken: _user?.token,
        userId: _user?.userId,
        restaurantId: widget.restaurantId);

    if (currentCartItems == null) return;

    // Find the exact match
    bool result = false;
    for (var item in currentCartItems) {
      if (_cartRepository.generateItemFingerprint(item) == targetFingerprint) {
        // Found the exact match, remove it
        result = await _cartRepository.removeFromCart(
            productId: item['productId'],
            userId: _user?.userId,
            accessToken: _user?.token);
        break;
      }
    }

    if (result) {
      await fetchItemsInCart(user: _user!);
    } else {
      _logger.info('Failed to delete specific item from cart');
    }
  }

  Future<bool> fetchItemsInCart({required SavedUser user}) async {
    List<dynamic>? data = await _cartRepository.getCartByRestaurant(
        accessToken: _user?.token,
        userId: _user?.userId,
        restaurantId: widget.restaurantId);

    if (data != null) {
      int total = 0;
      int totalQuantity = 0;

      // Calculate total price including addons
      for (var item in data) {
        double itemPrice = (item['price'] as num).toDouble();
        int quantity = (item['quantity'] as num).toInt();

        // Add base product price
        total += (itemPrice * quantity).toInt();
        totalQuantity += quantity;

        // Add addon prices
        List<dynamic> addons = item['cartAddOnItems'] ?? [];
        for (var addon in addons) {
          total += ((addon['price'] as num).toDouble() *
                  (addon['quantity'] as num).toInt())
              .toInt();
        }
      }

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
    return SafeArea(
      child: Scaffold(
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
                      _restaurant?.image ?? '',
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
                  _logger.info("Item: ${item.toString()}");
                  return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          final result = await GoRouter.of(context)
                              .push('/protected/product', extra: {
                            'restaurantId': widget.restaurantId,
                            'productId': item.id,
                          });
                          //code chap va :))
                          if (result == true) {
                            await reloadCartItems();
                          } else {
                            await reloadCartItems();
                          }
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
                                  Text(item.name,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Text(item.description),
                                  Text(
                                      "⏳ Thời gian chuẩn bị: ${item.prepareTime.round()} phút"),
                                  SizedBox(height: 4),
                                  Text(
                                      "Giá: ${(item.price).toStringAsFixed(0)} xu",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            // Only keep the ADD button
                            ElevatedButton(
                              onPressed: () {
                                if (item.addonSections != null &&
                                    item.addonSections!.isNotEmpty) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => AddToCartPopup(
                                      product: item,
                                      restaurantId: widget.restaurantId,
                                      onCartUpdated: () {
                                        fetchItemsInCart(user: _user!);
                                      },
                                    ),
                                  );
                                } else {
                                  addToCart(product: item);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                minimumSize: const Size(32, 32),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 18),
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
                              padding: EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 16,
                                  bottom: MediaQuery.of(context)
                                      .viewPadding
                                      .bottom),
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
                                              List<dynamic> addons =
                                                  item['cartAddOnItems'] ?? [];

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ListTile(
                                                    leading: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: Image.network(
                                                        item['image'],
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    title: Row(
                                                      children: [
                                                        Text(item[
                                                            'productName']),
                                                        SizedBox(width: 8),
                                                        // Show quantity
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 2),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey[200],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          child: Text(
                                                            "x${item['quantity']}",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    subtitle: () {
                                                      // Calculate item total price including addons
                                                      double itemUnitPrice =
                                                          item['price'];
                                                      double totalAddonPrice =
                                                          0;

                                                      // Add prices of all addons
                                                      for (var addon
                                                          in addons) {
                                                        totalAddonPrice +=
                                                            addon['price'] *
                                                                addon[
                                                                    'quantity'];
                                                      }

                                                      double itemTotalPrice =
                                                          (itemUnitPrice +
                                                                  totalAddonPrice) *
                                                              item['quantity'];

                                                      return Text(
                                                          "Giá: ${(itemTotalPrice).toStringAsFixed(0)} xu");
                                                    }(),
                                                    trailing: IconButton(
                                                      icon: Icon(Icons.delete,
                                                          color: Colors.red),
                                                      onPressed: () async {
                                                        await removeSpecificCartItem(
                                                            item);
                                                        setModalState(() {});
                                                      },
                                                    ),
                                                  ),

                                                  // Display addon items if any
                                                  if (addons.isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 70,
                                                              bottom: 8),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: addons
                                                            .map<Widget>(
                                                                (addon) {
                                                          return Text(
                                                            "- ${addon['addOnItemName']} (+${addon['price'].toStringAsFixed(0)} xu)",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .grey),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),

                                                  Divider(),
                                                ],
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
                                        'Tổng: ${NumberFormat("#,###", "vi_VN").format(_cartTotal)} xu',
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
                'Tổng: ${NumberFormat("#,###", "vi_VN").format(_cartTotal)} xu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go(
                      '/protected/confirm-order-cart/${widget.restaurantId}');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text("Thanh toán"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
