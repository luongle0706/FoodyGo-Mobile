import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';

class StaffHomeHistoryPage extends StatefulWidget {
  const StaffHomeHistoryPage({super.key});

  @override
  State<StaffHomeHistoryPage> createState() => _StaffHomeHistoryPageState();
}

class _StaffHomeHistoryPageState extends State<StaffHomeHistoryPage> {
  final _orderRepository = OrderRepository.instance;
  final _logger = AppLogger.instance;
  final String status = "COMPLETED";
  bool _isLoading = true;
  List<dynamic>? orders;
  int pageNo = 1;
  int pageSize = 100;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final storage = SecureStorage.instance;
    String? userData = await storage.get(key: 'user');
    SavedUser? user =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
    if (user != null) {
      bool fetchedOrders = await fetchOrders(user: user);
      if (fetchedOrders) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }
    _logger.error("Unable to fetch API");
    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> fetchOrders({required SavedUser user}) async {
    Map<String, dynamic>? response = await _orderRepository.getOrders(
        accessToken: user.token,
        params:
            '?hubId=${user.hubId}&sortBy=time&status=$status&pageNo=$pageNo&pageSize=$pageSize');
    if (response != null && response['data'] != null) {
      setState(() {
        orders = response['data'];
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (orders == null || orders!.isEmpty) {
      return Center(child: Text("Không có đơn hàng hoàn thành nào."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders!.length,
      itemBuilder: (context, index) {
        final order = orders![index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("#${order['id']}",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(order['customerName'] ?? "Khách hàng ẩn danh"),
                Text("${order['totalItems']} Món | ${order['totalPrice']}đ"),
                ...order['orderDetails'].map<Widget>((item) {
                  return Text("${item['quantity']} x ${item['productName']}");
                }).toList(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order['time']
                        .toString()
                        .split('T')[1]), // Hiển thị giờ đặt
                    OutlinedButton(
                      onPressed: () {
                        GoRouter.of(context).push(
                            '/protected/order-detail-restaurant',
                            extra: order['id']);
                      },
                      child: Text("Xem thêm"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
