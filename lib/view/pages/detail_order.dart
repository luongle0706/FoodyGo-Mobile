import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/order_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/pages/welcome_screen.dart';
import 'package:go_router/go_router.dart';

class DetailOrder extends StatefulWidget {
  final int orderId;
  const DetailOrder({super.key, required this.orderId});

  @override
  State<DetailOrder> createState() => _DetailOrderState();
}

class _DetailOrderState extends State<DetailOrder> {
  final _storage = SecureStorage.instance;

  final AppLogger _logger = AppLogger.instance;

  final OrderRepository _orderRepository = OrderRepository.instance;

  OrderDto? _orderDto;

  bool _isLoading = true;

  int status = 1;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<bool> fetchOrder(String accessToken) async {
    OrderDto? fetchOrder =
        await _orderRepository.loadOrderById(accessToken, widget.orderId);

    if (fetchOrder != null) {
      setState(() {
        _orderDto = fetchOrder;
        if (_orderDto?.status == "HUB_ARRIVED") {
          status = 4;
        } else if (_orderDto?.status == "SHIPPING") {
          status = 3;
        } else if (_orderDto?.status == "RESTAURANT_ACCEPTED") {
          status = 2;
        } else if (_orderDto?.status == "ORDERED") {
          status = 1;
        } else if (_orderDto?.status == "COMPLETED") {
          status = 5;
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
        title: Text('Chi tiết đơn hàng', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getStatusText(status),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                      SizedBox(height: 16),
                      Container(
                        margin: EdgeInsets.only(
                            left: 8, right: 8, top: 40, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildStep(1, Icons.receipt, status),
                            buildLine(status >= 2),
                            buildStep(2, Icons.kitchen, status),
                            buildLine(status >= 3),
                            buildStep(3, Icons.delivery_dining, status),
                            buildLine(status >= 4),
                            buildStep(4, Icons.apartment, status),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 16,
                    child: Container(
                      width: 70,
                      height: 70,
                      margin: EdgeInsets.only(bottom: 40),
                      child: Icon(
                        getStepIcon(status),
                        size: 60,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 8),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Từ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text(
                                'Xoài non mắm ruốc - Cửa hàng Gì Lê\nNhà văn hóa sinh viên, Quận 9, TP.Thủ Đức',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Đến',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text(
                                'Lưu Hữu Phước, Đông Hòa, Dĩ An, Bình Dương, Việt Nam, TP.HCM\n${_orderDto?.customerName} - ${_orderDto?.customerPhone}',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 20),
                child: Text(
                  'Chi tiết đơn hàng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                children: _orderDto?.orderDetails
                        .map((orderDetail) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Text('Ảnh ${orderDetail.id}'),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${orderDetail.quantity} x ${orderDetail.productName}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              orderDetail.addonItems
                                                      ?.toString() ??
                                                  'Không có món thêm',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Text(
                                          '${orderDetail.price.toStringAsFixed(0)} xu', // Hiển thị giá
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList() ??
                    [],
              ),
              Divider(),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tổng (${_orderDto?.orderDetails.length} món)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${_orderDto?.serviceFee.toStringAsFixed(2)} xu',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Phí giao hàng'),
                        Text('${_orderDto?.shippingFee.toStringAsFixed(2)} xu'),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tổng cộng',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${_orderDto?.totalPrice.toStringAsFixed(2)} xu',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text('Ghi chú',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Spacer(),
                        Text('${_orderDto?.notes}',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text('Mã đơn hàng',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Spacer(),
                        Text('${_orderDto?.id}',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text('Thời gian đặt hàng',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Spacer(),
                        Text(
                            "${_orderDto?.time.day}/${_orderDto?.time.month}/${_orderDto?.time.year} ${_orderDto?.time.hour}:${_orderDto?.time.minute}",
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text('Thanh toán',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Spacer(),
                        Text('FoodyXu',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
              );
            },
            child: Text('Đặt lại',
                style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

String getStatusText(int status) {
  switch (status) {
    case 1:
      return 'Đơn hàng đã được xác nhận';
    case 2:
      return 'Đơn đang được chuẩn bị';
    case 3:
      return 'Đơn hàng đang được giao';
    case 4:
      return 'Đơn hàng đã đến nơi';
    default:
      return 'Đơn hàng đã giao thành công';
  }
}

Widget buildStep(int step, IconData icon, int currentStatus) {
  bool isActive = step <= currentStatus;
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: isActive ? Colors.green : Colors.grey[300],
      shape: BoxShape.circle,
    ),
    child: Icon(
      isActive ? Icons.check : icon,
      color: isActive ? Colors.white : Colors.black,
    ),
  );
}

Widget buildLine(bool isActive) {
  return Expanded(
    child: Container(
      height: 3,
      color: isActive ? Colors.green : Colors.grey[300],
    ),
  );
}

IconData getStepIcon(int status) {
  switch (status) {
    case 1:
      return Icons.receipt;
    case 2:
      return Icons.kitchen;
    case 3:
      return Icons.delivery_dining;
    case 4:
      return Icons.apartment;
    default:
      return Icons.pending_actions;
  }
}
