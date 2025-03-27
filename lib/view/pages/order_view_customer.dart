import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/order_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/pages/detail_order.dart';
import 'package:foodygo/view/pages/welcome_screen.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrderListCustomerPage extends StatefulWidget {
  const OrderListCustomerPage({super.key});

  @override
  State<OrderListCustomerPage> createState() => _OrderListCustomerPageState();
}

class _OrderListCustomerPageState extends State<OrderListCustomerPage> {
  final _storage = SecureStorage.instance;
  final AppLogger _logger = AppLogger.instance;
  final OrderRepository _orderRepository = OrderRepository.instance;

  List<OrderDto>? _orderDto;

  // Active orders filters
  List<String> activeOrderStatuses = [
    "ORDERED",
    "RESTAURANT_ACCEPTED",
    "SHIPPING",
    "HUB_ARRIVED"
  ];

  // History filters
  String selectedService = "Tất cả";
  String selectedStatus = "Tất cả";
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();
  List<String> services = ["Tất cả", "Giao hàng", "Mang đi"];
  List<String> statuses = ["Tất cả", "Hoàn thành", "Đã hủy"];

  List<OrderDto>? filteredOrders;
  bool _isLoading = true;
  int selectedSubTab = 0;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  List<OrderDto> filterOrdersByStatus(
      List<OrderDto>? orders, List<String> statuses) {
    if (orders == null || statuses.isEmpty) {
      return [];
    }

    Set<String> statusSet = statuses.map((s) => s.toLowerCase()).toSet();

    return orders
        .where((order) => statusSet.contains(order.status.toLowerCase()))
        .toList();
  }

  List<OrderDto> filterOrdersByStatusString(
      List<OrderDto>? orders, String status) {
    if (orders == null || status.isEmpty) {
      return [];
    }

    return orders
        .where((order) => order.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  Future<bool> fetchOrder({required SavedUser user}) async {
    List<OrderDto>? fetchOrder = await _orderRepository.getOrdersByCustomerId(
        user.token, user.customerId!);

    if (fetchOrder != null) {
      if (!mounted) return false;
      setState(() {
        _orderDto = fetchOrder;

        // Apply initial filter based on selected tab
        if (selectedSubTab == 0) {
          filteredOrders = filterOrdersByStatus(_orderDto, activeOrderStatuses);
        } else {
          filteredOrders = filterOrdersByStatusString(_orderDto, "COMPLETED");
        }
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
      bool fetchOrderData = await fetchOrder(user: user);

      if (!mounted) return;

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
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Stunning header with tabs
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade800,
                  Colors.orange.shade600,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 15,
              bottom: 15,
              left: 10,
              right: 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Đơn Hàng Của Bạn",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(child: _tabSelector("Đang đến", 0)),
                      Expanded(child: _tabSelector("Lịch sử", 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Show history filters only when history tab is selected
          if (selectedSubTab == 1)
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

          // Content based on selected tab
          if (selectedSubTab == 0)
            _buildActiveOrders()
          else
            _buildOrderHistory(),
        ],
      ),
    );
  }

  Widget _buildActiveOrders() {
    if (filteredOrders == null || filteredOrders!.isEmpty) {
      return Expanded(
        child: Center(child: Text("Không có đơn hàng nào")),
      );
    }

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredOrders!.length,
              itemBuilder: (context, index) {
                final order = filteredOrders![index];
                return Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.shade900,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
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
                                color: Colors.orange.shade900),
                          ),
                          Text(
                            "${order.expectedDeliveryTime.hour.toString().padLeft(2, '0')}:"
                                    "${order.expectedDeliveryTime.minute.toString().padLeft(2, '0')} - " +
                                "${order.expectedDeliveryTime.day}/${order.expectedDeliveryTime.month}",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          GoRouter.of(context).go(
                            "/protected/restaurant-detail",
                            extra: order.restaurantId,
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios,
                                size: 14, color: Colors.grey),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailOrder(orderId: order.id),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.orange.shade50,
                              ),
                              alignment: Alignment.center,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  order.restaurantImage,
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Đơn hàng ${order.id}",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "${order.totalPrice.toStringAsFixed(0)} xu - ${order.orderDetails.length} món",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translateStatus(order.status),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                "Đơn sẽ được giao đến bạn",
                                textAlign: TextAlign.right,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          // Footer with order status
          Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.orange.shade200, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Đã đặt",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                Flexible(
                  child: Text(
                    "Đơn hàng sẽ được giao đến bạn",
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOrderHistory() {
    if (filteredOrders == null || filteredOrders!.isEmpty) {
      return Expanded(
        child: Center(child: Text("Không có đơn hàng nào")),
      );
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

    return Expanded(
      child: ListView.builder(
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
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
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
                        // Restaurant image
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
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
      ),
    );
  }

  Widget _tabSelector(String text, int index) {
    final isSelected = selectedSubTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSubTab = index;

          // Update filtered orders based on selected tab
          if (index == 0) {
            filteredOrders =
                filterOrdersByStatus(_orderDto, activeOrderStatuses);
          } else {
            filteredOrders = filterOrdersByStatusString(_orderDto, "COMPLETED");
          }
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: Offset(0, 1),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Icon(
                index == 0 ? Icons.local_shipping : Icons.history,
                color: Colors.orange.shade800,
                size: 16,
              ),
            if (isSelected) SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.orange.shade800 : Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String translateStatus(String status) {
    switch (status.toUpperCase()) {
      case "ORDERED":
        return "Chờ xác nhận";
      case "RESTAURANT_ACCEPTED":
        return "Nhà hàng đã xác nhận";
      case "SHIPPING":
        return "Đang giao hàng";
      case "HUB_ARRIVED":
        return "Đã đến hub";
      default:
        return "Không xác định";
    }
  }
}
