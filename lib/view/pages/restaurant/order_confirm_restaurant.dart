import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/pages/restaurant/custome_appbar_order_restaurant_list.dart';

class ConfirmedOrderRestaurantScreen extends StatefulWidget {
  const ConfirmedOrderRestaurantScreen({super.key});

  @override
  _ConfirmedOrderRestaurantScreenState createState() =>
      _ConfirmedOrderRestaurantScreenState();
}

class _ConfirmedOrderRestaurantScreenState
    extends State<ConfirmedOrderRestaurantScreen> {
  final _orderRepository = OrderRepository.instance;
  final _storage = SecureStorage.instance;
  final _logger = AppLogger.instance;

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
      _logger.info("User Access: " + _user!.token);
      setState(() {
        _isLoading = true; // Chuyển _isLoading về true khi bắt đầu tải
      });

      List<dynamic>? ordersRepo = await _orderRepository.getOrdersByStatus(
        accessToken: _user!.token,
        status: "RESTAURANT_ACCEPTED",
      );

      setState(() {
        _futureOrders = Future.value(ordersRepo); // Gán Future thay vì List
        _isLoading = false; // Đặt _isLoading = false khi đã tải xong
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomFootageRestaurantOrderAppBar(title: "Cơm tấm Ngô Quyền"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Tìm kiếm đơn hàng",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
                    return ConfirmedOrderCard(order: snapshot.data![index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmedOrderCard extends StatelessWidget {
  final dynamic order;

  const ConfirmedOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("#${order['id']}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text("Xác nhận lúc ${order['confirmedAt'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text("Khách hàng: ${order['customerName'] ?? 'N/A'}"),
            Text(
              "Trạng thái: ${order['status'] == 'RESTAURANT_ACCEPTED' ? 'Chưa giao' : (order['status'] ?? 'N/A')}",
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${order['totalItems']} món",
                    style: const TextStyle(fontSize: 14)),
                Text(
                  "${order['totalPrice'].toStringAsFixed(2)}đ",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () {}, child: const Text("Xác nhận giao hàng")),
          ],
        ),
      ),
    );
  }
}
