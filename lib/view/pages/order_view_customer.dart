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

class OrderListCustomerPage extends StatefulWidget {
  final int customerId;
  const OrderListCustomerPage({super.key, required this.customerId});

  @override
  State<OrderListCustomerPage> createState() => _OrderListCustomerPageState();
}

class _OrderListCustomerPageState extends State<OrderListCustomerPage> {
  final _storage = SecureStorage.instance;

  final AppLogger _logger = AppLogger.instance;

  final OrderRepository _orderRepository = OrderRepository.instance;

  List<OrderDto>? _orderDto;

  List<String> filterStatuses = [
    "ORDERED",
    "RESTAURANT_ACCEPTED",
    "SHIPPING",
    "HUB_ARRIVED"
  ];

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

  Future<bool> fetchOrder(String accessToken) async {
    List<OrderDto>? fetchOrder = await _orderRepository.getOrdersByCustomerId(
        accessToken, widget.customerId);

    if (fetchOrder != null) {
      setState(() {
        _orderDto = fetchOrder;
        filteredOrders = filterOrdersByStatus(_orderDto, filterStatuses);
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
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
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

          if (filteredOrders != null)
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
                              "${order.expectedDeliveryTime.hour.toString().padLeft(2, '0')}:" +
                                  "${order.expectedDeliveryTime.minute.toString().padLeft(2, '0')} - " +
                                  "${order.expectedDeliveryTime.day}/${order.expectedDeliveryTime.month}",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
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
                                  color: Colors.orange.shade900,
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
                                    order.image,
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
                              top: BorderSide(
                                  color: Colors.grey[300]!, width: 1),
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
          if (filteredOrders == null || filteredOrders!.isEmpty)
            Expanded(
              child: Center(child: Text("Không có đơn hàng nào")),
            ),
          // Footer với trạng thái đơn hàng
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
