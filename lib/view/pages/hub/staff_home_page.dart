import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  final _orderRepository = OrderRepository.instance;
  final _logger = AppLogger.instance;
  final String status = "RESTAURANT_ACCEPTED";
  final String updatedStatus = "HUB_ARRIVED";
  bool _isLoading = true;
  SavedUser? user;
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
    SavedUser? savedUser =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
    if (savedUser != null) {
      setState(() {
        user = savedUser;
      });
      bool fetchedOrders = await fetchOrders(user: savedUser);
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

  Future<void> updateStatus({required int orderId, required context}) async {
    bool response = await _orderRepository.updateStatusOrder(
        accessToken: user?.token,
        orderId: orderId,
        status: updatedStatus,
        userId: user!.userId);
    if (response) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cập nhật trạng thái thành công!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      await fetchOrders(user: user!);
      return;
    }
    _logger.error("FAILED");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Cập nhật thất bại!"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (orders == null || orders!.isEmpty) {
      return Center(
        child: Text("Không có đơn hàng nào."),
      );
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
                Text("${order['totalItems']} món | ${order['totalPrice']}đ"),
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
                    Row(
                      children: [
                        OutlinedButton(
                            onPressed: () {}, child: Text("Xem thêm")),
                        const SizedBox(width: 8),
                        ElevatedButton(
                            onPressed: () {
                              updateStatus(
                                  orderId: order['id'], context: context);
                            },
                            child: Text("Đã đến")),
                      ],
                    )
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
