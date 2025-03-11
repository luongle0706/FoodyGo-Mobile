import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/order_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/pages/detail_order.dart';
import 'package:intl/intl.dart';
import 'package:foodygo/view/pages/welcome_screen.dart';

class OrderHistory extends StatefulWidget {
  final int orderId;
  const OrderHistory({super.key, required this.orderId});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  String selectedService = "Tất cả";

  String selectedStatus = "Tất cả";

  DateTime startDate = DateTime.now().subtract(Duration(days: 30));

  DateTime endDate = DateTime.now();

  List<String> services = ["Tất cả", "Giao hàng", "Mang đi"];

  List<String> statuses = ["Tất cả", "Hoàn thành", "Đã hủy"];

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime(2025, 12, 31),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  final _storage = SecureStorage.instance;

  final AppLogger _logger = AppLogger.instance;

  final OrderRepository _orderRepository = OrderRepository.instance;

  List<OrderDto>? _orderDto;

  List<OrderDto>? filteredOrders;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  List<OrderDto> filterOrdersByStatus(List<OrderDto>? orders, String status) {
    if (orders == null || status.isEmpty) {
      return [];
    }

    return orders
        .where((order) => order.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  Future<bool> fetchOrder(String accessToken) async {
    List<OrderDto>? fetchOrder = await _orderRepository.getOrdersByCustomerId(
        accessToken, widget.orderId);

    if (fetchOrder != null) {
      setState(() {
        _orderDto = fetchOrder;
        filteredOrders = filterOrdersByStatus(_orderDto, "COMPLETED");
        _isLoading = false;
      });
      return true;
    }
    return false;
  }

  Future<void> loadUser() async {
    String? userData = await _storage.get(key: 'user');
    SavedUser? user =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
    if (user != null) {
      bool fetchOrderData = await fetchOrder(user.token);

      if (fetchOrderData) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : filter(),
    );
  }

  Widget filter() {
    return Column(
      children: [
        // lọc
        Container(
          color: Colors.grey[600],
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: selectedService,
                dropdownColor: Colors.white,
                style: TextStyle(color: Colors.white),
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                items: services.map((String service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedService = value!;
                  });
                },
              ),
              DropdownButton<String>(
                value: selectedStatus,
                dropdownColor: Colors.white,
                style: TextStyle(color: Colors.white),
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                items: statuses.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
              GestureDetector(
                onTap: () => _selectDateRange(context),
                child: Row(
                  children: [
                    Text(
                      "${DateFormat('dd/MM/yy').format(startDate)} - ${DateFormat('dd/MM/yy').format(endDate)}",
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(child: buildHistoryList()),
      ],
    );
  }

  Widget buildHistoryList() {
    if (filteredOrders == null || filteredOrders!.isEmpty) {
      return Center(child: Text("Không có đơn hàng nào"));
    }

    List<OrderDto> filteredOrdersByDate = filteredOrders!.where((order) {
      DateTime orderDate = DateTime.parse("${order.time}");
      bool isInDateRange =
          orderDate.isAfter(startDate.subtract(Duration(days: 1))) &&
              orderDate.isBefore(endDate.add(Duration(days: 1)));

      bool matchesService =
          selectedService == "Tất cả" || order.status == selectedService;

      bool matchesStatus =
          selectedStatus == "Tất cả" || order.status == selectedStatus;

      return isInDateRange && matchesService && matchesStatus;
    }).toList();

    return ListView.builder(
      itemCount: filteredOrdersByDate.length,
      itemBuilder: (context, index) {
        final order = filteredOrdersByDate[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Đồ ăn #${order.id}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        "${order.time.day}/${order.time.month}/${order.time.year} ${order.time.hour}:${order.time.minute}"),
                  ],
                ),
                Text("${order.restaurantName}",
                    style: TextStyle(color: Colors.grey)),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailOrder(orderId: order.id)),
                    );
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: Center(child: Text("Ảnh")),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: 5, top: 25),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        "${order.totalPrice.toStringAsFixed(2)}đ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text("${order.orderDetails.length} món",
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        Icon(Icons.arrow_forward_ios,
                                            size: 14, color: Colors.grey),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text("Đơn hàng ${order.id}",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.status, style: TextStyle(color: Colors.green)),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomeScreen()),
                        );
                      },
                      child: Text("Đặt lại"),
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
