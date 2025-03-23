import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/order_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/pages/restaurant/confirmation_orders_restaurant.dart';
import 'package:foodygo/view/pages/restaurant/order_history_restaurant.dart';
import 'package:foodygo/view/pages/restaurant/restaurant_food_appbar.dart';
import 'package:foodygo/view/pages/restaurant_menu.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrderListRestaurantPage extends StatefulWidget {
  const OrderListRestaurantPage({super.key});

  @override
  State<OrderListRestaurantPage> createState() =>
      _OrderListRestaurantPageState();
}

class _OrderListRestaurantPageState extends State<OrderListRestaurantPage> {
  final _storage = SecureStorage.instance;
  final OrderRepository _orderRepository = OrderRepository.instance;
  final AppLogger _logger = AppLogger.instance;
  bool _isLoading = true;
  List<OrderDto>? _newOrders;

  int selectedTab = 0;
  int selectedSubTab = 0;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void selectTab({required int tabIndex}) async {
    setState(() {
      selectedTab = tabIndex;
    });
  }

  Future<bool> fetchNewOrder(
      String accessToken, int restaurantId, String status) async {
    List<OrderDto>? fetchOrders =
        await _orderRepository.getOrdersByStatusAndRestaurant(
            accessToken: accessToken,
            restaurantId: restaurantId,
            status: status);

    if (fetchOrders != null) {
      setState(() {
        _newOrders = fetchOrders;
      });
      return true;
    }
    return false;
  }

  Future<void> _confirmDelivery(int orderId) async {
    String? userData = await _storage.get(key: 'user');
    if (userData == null) return;

    SavedUser user = SavedUser.fromJson(json.decode(userData));

    bool success = await _orderRepository.updateStatusOrder(
      accessToken: user.token,
      orderId: orderId,
      status: "RESTAURANT_ACCEPTED",
      userId: user.userId,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật trạng thái thành công!")),
      );

      setState(() {
        _isLoading = true;
      });

      await loadUser();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật trạng thái thất bại!")),
      );
    }
  }

  Future<void> loadUser() async {
    String? userData = await _storage.get(key: 'user');
    SavedUser? user =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
    if (user != null) {
      bool fetchData =
          await fetchNewOrder(user.token, user.restaurantId!, "ORDERED");

      if (fetchData) {
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

  String formatDateTime(dynamic dateTimeInput) {
    if (dateTimeInput == null) return 'N/A';

    try {
      DateTime dateTime;

      if (dateTimeInput is String && dateTimeInput.isNotEmpty) {
        dateTime = DateTime.parse(dateTimeInput);
      } else if (dateTimeInput is DateTime) {
        dateTime = dateTimeInput;
      } else {
        return 'N/A'; // Nếu không phải String hoặc DateTime, trả về 'N/A'
      }

      return DateFormat('HH:mm dd/MM').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.info(_newOrders.toString());
    if (_isLoading) {
      return Scaffold(
          appBar: RestaurantFoodAppbar(
            title: "Cơm tấm Ngô Quyền",
            setTab: selectTab,
            selectedTab: selectedTab,
          ),
          body: SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ));
    }
    return Scaffold(
        appBar: RestaurantFoodAppbar(
          title: "Cơm tấm Ngô Quyền",
          setTab: selectTab,
          selectedTab: selectedTab,
        ),
        body: selectedTab == 0
            ? _buildOrdersTab()
            : selectedTab == 1
                ? RestaurantMenu()
                : _buildPlaceholderTab());
  }

  Widget _buildOrdersTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: "Tìm kiếm đơn hàng...",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color(0xFFEE4D2D), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _tabSelector("Mới", 0),
              _tabSelector("Đã xác nhận", 1),
              _tabSelector("Lịch sử", 2),
            ],
          ),
        ),
        if (selectedSubTab == 0) _buildNewOrders(),
        if (selectedSubTab == 1) ConfirmedOrderRestaurantScreen(),
        if (selectedSubTab == 2) OrderHistoryRestaurantScreen()
      ],
    );
  }

  Widget _buildNewOrders() {
    return Expanded(
      child: ListView.builder(
        itemCount: _newOrders?.length,
        itemBuilder: (context, index) {
          final item = _newOrders?[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "#${item!.id}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Đặt vào lúc: ${formatDateTime(item.time)}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [Text(item.customerName)],
                  ),
                  Row(
                    children: [
                      Text(
                          "${item.totalItems} Món | ${item.totalPrice.round()} xu")
                    ],
                  ),
                  for (OrderDetail detail in item.orderDetails)
                    Row(
                      children: [
                        Text("${detail.quantity} x ${detail.productName}")
                      ],
                    ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          GoRouter.of(context).push(
                              '/protected/order-detail-restaurant',
                              extra: item.id);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Color.fromARGB(255, 141, 136, 133)),
                        child: Text("Xem thêm",
                            style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _confirmDelivery(item.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEE4D2D),
                        ),
                        child: const Text(
                          "Xác nhận",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderTab() {
    return Center(
      child: Text(
        selectedTab == 1
            ? "Thực đơn đang cập nhật..."
            : "Báo cáo đang cập nhật...",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _tabSelector(String text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSubTab = index;
        });
        // if (index == 0) {
        //   GoRouter.of(context).push('/protected/restaurant-foodygo');
        // }
        // if (index == 1) {
        //   GoRouter.of(context).push('/protected/confirm-order');
        // }
        // if (index == 2) {
        //   GoRouter.of(context).push('/protected/history-order-page');
        // }
      },
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  selectedSubTab == index ? FontWeight.bold : FontWeight.normal,
              color: selectedSubTab == index ? Colors.black : Colors.grey,
            ),
          ),
          if (selectedSubTab == index)
            Container(
              margin: EdgeInsets.only(top: 5),
              height: 3,
              width: 40,
              color: Colors.black,
            ),
        ],
      ),
    );
  }
}
