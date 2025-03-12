import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/order_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/pages/detail_order.dart';
import 'package:go_router/go_router.dart';

class OrderListCustomerPage extends StatefulWidget {
  final int orderId;
  const OrderListCustomerPage({super.key, required this.orderId});

  @override
  State<OrderListCustomerPage> createState() => _OrderListCustomerPageState();
}

class _OrderListCustomerPageState extends State<OrderListCustomerPage> {
  final _storage = SecureStorage.instance;

  final AppLogger _logger = AppLogger.instance;

  final OrderRepository _orderRepository = OrderRepository.instance;

  List<OrderDto>? _orderDto;

  // String status = 'ordered';

  List<String> filterStatuses = ["ORDERED", "RESTAURANT_ACCEPTED", "SHIPPING", "HUB_ARRIVED"];

  List<OrderDto>? filteredOrders;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  // List<OrderDto> filterOrdersByStatus(List<OrderDto>? orders, String status) {
  //   if (orders == null || status.isEmpty) {
  //     return [];
  //   }
  //
  //   return orders
  //       .where((order) => order.status.toLowerCase() == status.toLowerCase())
  //       .toList();
  // }

  List<OrderDto> filterOrdersByStatus(List<OrderDto>? orders, List<String> statuses) {
    if (orders == null || statuses.isEmpty) {
      return [];
    }

    Set<String> statusSet = statuses.map((s) => s.toLowerCase()).toSet();

    return orders.where((order) => statusSet.contains(order.status.toLowerCase())).toList();
  }

  Future<bool> fetchOrder(String accessToken) async {
    List<OrderDto>? fetchOrder = await _orderRepository.getOrdersByCustomerId(
        accessToken, widget.orderId);

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
      appBar: AppBar(
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (filteredOrders != null) ...[
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
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: Offset(0, 2),
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
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${order.expectedDeliveryTime.day}/${order.expectedDeliveryTime.month}/${order.expectedDeliveryTime.year} ${order.expectedDeliveryTime.hour}:${order.expectedDeliveryTime.minute}",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            GoRouter.of(context).go("/restaurant");
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order.restaurantName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                  color: Colors.grey[300],
                                ),
                                alignment: Alignment.center,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'https://images.immediate.co.uk/production/volatile/sites/30/2020/08/chorizo-mozarella-gnocchi-bake-cropped-9ab73a3.jpg?resize=768,574',
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.error);
                                    },
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
                                      "${order.totalPrice.toStringAsFixed(2)}đ - ${order.orderDetails.length} món",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
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
                                    color: Colors.grey[300]!, width: 1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.status,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Đơn sẽ được giao đến bạn",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ] else if (_orderDto == null) ...[
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
          Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              border:
                  Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Đã đặt",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  "Đơn sẽ được giao đến bạn",
                  style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
