import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/order_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class OrderDetailRestaurant extends StatefulWidget {
  final int orderId;

  const OrderDetailRestaurant({super.key, required this.orderId});

  @override
  State<StatefulWidget> createState() => _OrderDetailRestaurantState();
}

class _OrderDetailRestaurantState extends State<OrderDetailRestaurant> {
  final _storage = SecureStorage.instance;
  final AppLogger _logger = AppLogger.instance;
  final OrderRepository _orderRepository = OrderRepository.instance;
  OrderDto? _orderDto;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<bool> fetchOrder(String accessToken) async {
    OrderDto? fetchOrder =
        await _orderRepository.loadOrderById(accessToken, widget.orderId);
    if (fetchOrder != null) {
      if (mounted) {
        setState(() {
          _orderDto = fetchOrder;
        });
      }
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
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      _logger.info('Failed to load user');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
          appBar: AppBar(
        title: Text(
          "Chi tiết đơn hàng",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go('/');
            }
          },
        ),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chi tiết đơn hàng",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Khách đặt đơn
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_orderDto!.customerName,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_orderDto!.customerPhone,
                              style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                    ),
                    Icon(Icons.phone, color: AppColors.primary),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Danh sách món ăn
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _orderDto!.orderDetails
                      .map((detail) => OrderItem(
                            name: detail.productName,
                            price: "${detail.price.toStringAsFixed(2)} xu",
                            quantity: detail.quantity,
                          ))
                      .toList(),
                ),
              ),

              SizedBox(height: 12),

              // Tổng tiền
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Tổng tiền: ${_orderDto!.totalPrice.toStringAsFixed(2)} xu",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              SizedBox(height: 16),

              // Thông tin đơn hàng
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    OrderInfoRow(
                        label: "Mã đơn hàng", value: _orderDto!.id.toString()),
                    OrderInfoRow(
                        label: "Thời gian đặt hàng",
                        value: _orderDto!.time.toString()),
                    OrderInfoRow(label: "Khoảng cách", value: "2.2km"),
                    OrderInfoRow(label: "Quán xác nhận", value: "1.6m"),
                    OrderInfoRow(
                        label: "Thời gian giao dự kiến",
                        value: _orderDto!.expectedDeliveryTime.toString()),
                    OrderInfoRow(
                        label: "Ghi chú của khách",
                        value: _orderDto!.notes ?? "Không có ghi chú"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget hiển thị một món ăn trong đơn hàng
class OrderItem extends StatelessWidget {
  final String name;
  final String price;
  final int quantity;

  const OrderItem(
      {super.key,
      required this.name,
      required this.price,
      required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$quantity x $name"),
          Text(price, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Widget hiển thị một dòng thông tin đơn hàng
class OrderInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const OrderInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.black87)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
