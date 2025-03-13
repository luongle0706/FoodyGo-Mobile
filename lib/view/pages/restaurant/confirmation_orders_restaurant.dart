import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/pages/restaurant/custome_appbar_order_restaurant_list.dart';
import 'package:foodygo/view/pages/restaurant/order_do_confirm_restaurant.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ConfirmedOrderRestaurantScreen extends StatefulWidget {
  const ConfirmedOrderRestaurantScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConfirmedOrderRestaurantScreenState createState() =>
      _ConfirmedOrderRestaurantScreenState();
}

class _ConfirmedOrderRestaurantScreenState
    extends State<ConfirmedOrderRestaurantScreen> {
  final _orderRepository = OrderRepository.instance;
  final _storage = SecureStorage.instance;
  final _logger = AppLogger.instance;

  int selectedSubTab = 1;

  SavedUser? _user;
  Future<List<dynamic>?>? _futureOrders;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchOrders();
  }

  Future<void> _loadUserAndFetchOrders() async {
    try {
      String? userData = await _storage.get(key: 'user');
      if (userData != null) {
        setState(() {
          _user = SavedUser.fromJson(json.decode(userData));
        });
        _fetchOrders();
      } else {
        _logger.info('Failed to load user');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _logger.error('Error loading user: $e');
      setState(() => _isLoading = false);
    }
  }

  void _fetchOrders() async {
    if (_user != null) {
      _logger.info("User Access: ${_user!.token}");
      setState(() {
        _isLoading = true;
      });

      List<dynamic>? ordersRepo = await _orderRepository.getOrdersByStatus(
        accessToken: _user!.token,
        status: "RESTAURANT_ACCEPTED",
      );

      setState(() {
        _futureOrders = Future.value(ordersRepo);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          const CustomFootageRestaurantOrderAppBar(title: "Cơm tấm Ngô Quyền"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: _futureOrders,
              builder: (context, snapshot) {
                if (_isLoading ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text("Đã xảy ra lỗi, vui lòng thử lại!"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Không có đơn hàng nào!"));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ConfirmedOrderCard(
                      order: snapshot.data![index],
                      onOrderConfirmed: _fetchOrders,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabSelector(String text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSubTab = index;
        });
        if (index == 0) {
          GoRouter.of(context).push('/protected/restaurant-foodygo');
        }
        if (index == 1) {
          GoRouter.of(context).push('/protected/confirm-order');
        }
        if (index == 2) {
          GoRouter.of(context).push('/protected/history-order-page');
        }
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

String formatDateTime(String? dateTimeString) {
  if (dateTimeString == null || dateTimeString.isEmpty) {
    return 'N/A';
  }

  try {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('HH:mm dd/MM').format(dateTime);
  } catch (e) {
    return 'N/A';
  }
}

class ConfirmedOrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onOrderConfirmed;

  const ConfirmedOrderCard({
    super.key,
    required this.order,
    required this.onOrderConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "#${order['id']}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey, size: 16),
                const SizedBox(width: 5),
                Text(
                  "Xác nhận lúc: ${formatDateTime(order['confirmedAt'] as String?)}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey, size: 16),
                const SizedBox(width: 5),
                Text("Khách hàng: ${order['customerName'] ?? 'N/A'}"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.assignment_turned_in,
                    color: Colors.grey, size: 16),
                const SizedBox(width: 5),
                Text(
                  "Trạng thái: ${order['status'] == 'RESTAURANT_ACCEPTED' ? 'Chưa giao' : (order['status'] ?? 'N/A')}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${order['totalItems']} món",
                    style: const TextStyle(fontSize: 14)),
                Text(
                  "${order['totalPrice'].round()} xu",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEE4D2D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderConfirmationScreen(order: order),
                  ),
                ).then((result) {
                  if (result == true) {
                    onOrderConfirmed();
                  }
                });
              },
              child: const Center(
                child: Text(
                  "Xác nhận giao hàng",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
