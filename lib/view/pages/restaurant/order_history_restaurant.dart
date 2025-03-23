import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:intl/intl.dart';

class OrderHistoryRestaurantScreen extends StatefulWidget {
  const OrderHistoryRestaurantScreen({super.key});

  @override
  State<OrderHistoryRestaurantScreen> createState() =>
      _OrderHistoryRestaurantScreenState();
}

class _OrderHistoryRestaurantScreenState
    extends State<OrderHistoryRestaurantScreen> {
  final _orderRepository = OrderRepository.instance;

  final _storage = SecureStorage.instance;

  final _logger = AppLogger.instance;

  int selectedSubTab = 0;

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
        status: "COMPLETED",
      );

      setState(() {
        _futureOrders = Future.value(ordersRepo);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
              return OrderHistoryCard(order: snapshot.data![index]);
            },
          );
        },
      ),
    );
  }
}

class OrderHistoryCard extends StatelessWidget {
  final dynamic order;

  const OrderHistoryCard({super.key, required this.order});

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
                  "Hoàn thành lúc: ${formatDateTime(order['completedAt'] as String?)}",
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
          ],
        ),
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
