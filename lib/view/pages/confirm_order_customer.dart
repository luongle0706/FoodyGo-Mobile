import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/restaurant_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/cart_repository.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/repository/restaurant_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ConfirmOrderPage extends StatefulWidget {
  final int restaurantId;
  final int? chosenHubId;
  final String? chosenHubName;
  const ConfirmOrderPage(
      {super.key,
      required this.restaurantId,
      this.chosenHubId,
      this.chosenHubName});

  @override
  State<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  final _storage = SecureStorage.instance;
  final _logger = AppLogger.instance;
  final _cartRepository = CartRepository.instance;
  final _restaurantRepository = RestaurantRepository.instance;
  final _orderRepository = OrderRepository.instance;
  List<dynamic>? _cartItems;
  SavedUser? _user;
  RestaurantDto? _restaurant;
  bool _isLoading = true;
  int _totalPrice = 0;
  int? chosenHubId;
  String? chosenHubName;
  // Need to dynamically change (TODO)
  final int _shippingFee = 5;
  final DateTime _expectedDeliveryTime = DateTime.now().add(Duration(hours: 1));
  final String _customerPhone = '+84938762971';
  final String _notes = 'Not implemented';

  @override
  void initState() {
    super.initState();
    loadUser();
    setState(() {
      chosenHubId = widget.chosenHubId;
      chosenHubName = widget.chosenHubName;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      chosenHubId = widget.chosenHubId;
      chosenHubName = widget.chosenHubName;
    });
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
      bool fetchedRestaurant = await fetchRestaurantById(user: user);

      if (fetchedCartItems && fetchedRestaurant) {
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
      int totalPrice = data.fold(
            0,
            (sum, item) =>
                sum! +
                ((item['price'] as num).toInt() *
                    (item['quantity'] as num).toInt()),
          ) ??
          0;
      setState(() {
        _totalPrice = totalPrice;
        _cartItems = data;
      });
      return true;
    }
    return false;
  }

  Future<bool> fetchRestaurantById({required SavedUser user}) async {
    RestaurantDto? restaurant = await _restaurantRepository.loadRestaurantById(
        user.token, widget.restaurantId);
    if (restaurant != null) {
      setState(() {
        _restaurant = restaurant;
      });
      return true;
    }
    return false;
  }

  Future<void> placeOrder(BuildContext context) async {
    if (chosenHubId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn Hub trước khi đặt hàng!")),
      );
      return;
    }
    int? result = await _orderRepository.pay(
        accessToken: _user!.token,
        shippingFee: _shippingFee * 1.0,
        productFee: _totalPrice * 1.0,
        time: DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now()),
        expectedDeliveryTime:
            DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(_expectedDeliveryTime),
        customerPhone: _customerPhone,
        notes: _notes,
        customerId: _user!.customerId!,
        restaurantId: widget.restaurantId,
        hubId: chosenHubId!,
        cartLists: _cartItems!);
    if (result != null) {
      _logger.info("Successfully ordered: Order ID=$result");
      if (context.mounted) {
        GoRouter.of(context).go('/order-success', extra: result);
        return;
      }
    }
    _logger.error('Unable to make order');
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
        ),
      );
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
            // Address Section
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
                      GestureDetector(
                          onTap: () {
                            GoRouter.of(context).go('/map/hub', extra: {
                              'callOfOrigin':
                                  '/protected/confirm-order-cart/${widget.restaurantId}'
                            });
                          },
                          child: Text(chosenHubName ?? "Chọn Hub")),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(),
            const SizedBox(height: 10),

            // Restaurant Name
            Row(
              children: [
                Icon(Icons.local_restaurant),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _restaurant!.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Order Details
            Expanded(
              child: ListView.builder(
                itemCount: _cartItems?.length ?? 0,
                itemBuilder: (context, index) {
                  final item = _cartItems![index];

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
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
                              item['image'] ??
                                  'https://via.placeholder.com/60', // Placeholder image
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) {
                                  return child;
                                } else {
                                  return Center(
                                      child: CircularProgressIndicator());
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
                              Text(
                                  "${item['quantity']} x ${item['productName']}"),
                            ],
                          ),
                        ),
                        Text(
                          "${NumberFormat("#,###", "vi_VN").format(item['price'])} xu",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Price Breakdown
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tổng giá món"),
                Text(
                    "${NumberFormat("#,###", "vi_VN").format(_totalPrice)} xu"),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Phí giao hàng"),
                Text('$_shippingFee xu'),
              ],
            ),
            Divider(),

            // Total Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tổng thanh toán",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    "${NumberFormat("#,###", "vi_VN").format(_totalPrice + _shippingFee)} xu",
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
                onPressed: () async {
                  await placeOrder(context);
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
