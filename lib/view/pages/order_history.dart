import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/order_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/pages/detail_order.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:foodygo/view/pages/welcome_screen.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  final _storage = SecureStorage.instance;
  final AppLogger _logger = AppLogger.instance;
  final OrderRepository _orderRepository = OrderRepository.instance;

  String selectedService = "Tất cả";
  String selectedStatus = "Tất cả";
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();
  List<String> services = ["Tất cả", "Giao hàng", "Mang đi"];
  List<String> statuses = ["Tất cả", "Hoàn thành", "Đã hủy"];
  List<OrderDto>? _orderDto;
  List<OrderDto>? filteredOrders;
  bool _isLoading = true;
  int selectedSubTab = 0;

  @override
  void initState() {
    super.initState();
    final currentPath =
        GoRouter.of(context).routeInformationProvider.value.uri.toString();
    _logger.info("path $currentPath");
    if (currentPath.contains('/order-history')) {
      selectedSubTab = 1;
    } else {
      selectedSubTab = 0;
    }
    loadUser();
  }

  Future<void> loadUser() async {
    String? userString = await _storage.get(key: 'user');
    SavedUser? userData =
        userString != null ? SavedUser.fromJson(json.decode(userString)) : null;
    if (userData != null) {
      bool fetchOrderData = await fetchOrder(user: userData);

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

  Future<bool> fetchOrder({required SavedUser user}) async {
    List<OrderDto>? fetchOrder = await _orderRepository.getOrdersByCustomerId(
        user.token, user.customerId!);

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

  List<OrderDto> filterOrdersByStatus(List<OrderDto>? orders, String status) {
    if (orders == null || status.isEmpty) {
      return [];
    }

    return orders
        .where((order) => order.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? Center(child: CircularProgressIndicator()) : filter(),
    );
  }

  Widget filter() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.orange.shade700,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.3),
                blurRadius: 6,
                spreadRadius: 2,
                offset: Offset(0, 3),
              ),
            ],
          ),
          height: 100,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 10,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _tabSelector("Đang đến", 0),
                  _tabSelector("Lịch sử", 1),
                ],
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: selectedService,
                dropdownColor: Colors.white,
                style: TextStyle(color: AppColors.primary),
                icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                items: services.map((String service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service,
                        style: TextStyle(color: AppColors.primary)),
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
                style: TextStyle(color: AppColors.primary),
                icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                items: statuses.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status,
                        style: TextStyle(color: AppColors.primary)),
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
                      style: TextStyle(color: AppColors.primary),
                    ),
                    Icon(Icons.arrow_drop_down, color: AppColors.primary),
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
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.shade900, width: 2),
          ),
          color: Colors.white,
          elevation: 3,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Đồ ăn #P${order.id}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(order.time),
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  order.restaurantName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailOrder(orderId: order.id),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      // Ảnh nhà hàng
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          order.restaurantImage,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${order.totalPrice.toStringAsFixed(2)}đ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "${order.orderDetails.length} món",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),

                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Divider(thickness: 1, color: Colors.grey.shade300),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Đã hoàn thành",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        elevation: 2,
                      ),
                      child: Text(
                        "Đặt lại",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tabSelector(String text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSubTab = index;
        });
        if (index == 0) {
          GoRouter.of(context).push('/protected/order-list-customer');
        }
        if (index == 1) {
          GoRouter.of(context).push('/protected/order-history');
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
              color: selectedSubTab == index
                  ? Colors.black
                  : const Color.fromARGB(255, 245, 245, 245),
            ),
          ),
          if (selectedSubTab == index)
            Container(
              margin: EdgeInsets.only(top: 5),
              height: 3,
              width: 150,
              color: Colors.black,
            ),
        ],
      ),
    );
  }
}
