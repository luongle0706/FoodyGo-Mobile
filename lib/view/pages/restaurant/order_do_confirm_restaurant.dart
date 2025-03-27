import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/hub_repository.dart';
import 'package:foodygo/repository/order_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final dynamic order;
  const OrderConfirmationScreen({super.key, required this.order});

  @override
  // ignore: library_private_types_in_public_api
  _OrderConfirmationScreenState createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final OrderRepository orderRepository = OrderRepository.instance;
  final hubRepository = HubRepository.instance;
  SavedUser? user;
  bool _isLoading = true;
  final SecureStorage _storage = SecureStorage.instance;
  final _logger = AppLogger.instance;
  late final String hubName;
  dynamic hub;

  Future<void> fetchHubInfo(String accessToken) async {
    dynamic hubData = await hubRepository.getHubById(
        accessToken: accessToken, hubId: widget.order['hubId']);
    _logger.debug(hubData.toString());
    setState(() {
      hub = hubData;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchOrders();
    hubName = widget.order['hubName'].toString();
  }

  Future<void> _confirmDelivery() async {
    if (user == null) return;

    bool success = await orderRepository.updateStatusOrder(
      accessToken: user!.token,
      orderId: widget.order['id'],
      status: "SHIPPING",
      userId: user!.userId,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật trạng thái thành công!")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật trạng thái thất bại!")),
      );
    }
  }

  Future<void> _loadUserAndFetchOrders() async {
    try {
      String? userData = await _storage.get(key: 'user');
      SavedUser? fakeUser =
          userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
      if (fakeUser != null) {
        fetchHubInfo(fakeUser.token);
        setState(() {
          user = fakeUser;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _logger.info('Error loading user: $e');
      setState(() => _isLoading = false);
    }
  }

  String formatDateTime(dynamic dateTimeInput) {
    if (dateTimeInput == null) return 'N/A';

    try {
      DateTime dateTime;

      if (dateTimeInput is String && dateTimeInput.isNotEmpty) {
        dateTime = DateTime.parse(dateTimeInput);
      } else if (dateTimeInput is DateTime) {
        dateTime = dateTimeInput;
      } else {
        return 'N/A'; // Nếu không phải String hoặc DateTime, trả về 'N/A'
      }

      return DateFormat('HH:mm dd/MM').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.info("Order Data: ${jsonEncode(widget.order)}");
    if (_isLoading) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác nhận đơn hàng"),
        backgroundColor: const Color(0xFFEE4D2D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Đơn hàng đã được xác nhận bởi quán",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            _buildCustomerInfo(),
            const SizedBox(height: 10),
            _buildOrderDetails(),
            const SizedBox(height: 10),
            _buildOrderInfo(),
            const Spacer(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.person, size: 40, color: Colors.black54),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Khách đặt đơn",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.order['customerPhone'] ?? "Không có số điện thoại",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.phone, color: Color(0xFFEE4D2D)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Chi tiết đơn hàng",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.order['orderDetails'].length,
              itemBuilder: (context, index) {
                final item = widget.order['orderDetails'][index];
                return _buildOrderItem(
                    item['productName'], item['quantity'], item['price']);
              },
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tổng tiền món",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${widget.order['totalPrice'].toStringAsFixed(0)} xu",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderDetail("Mã đơn hàng", widget.order['id'].toString()),
            _buildOrderDetail(
                "Thời gian đặt hàng", formatDateTime(widget.order['time'])),
            _buildOrderDetail("Thời gian lấy hàng dự kiến",
                formatDateTime(widget.order['expectedDeliveryTime'])),
            // if (hub != null)
            //   Text(
            //     "$locationURL/?orderId=${widget.order['id']}&destination=${hub['latitude']},${hub['longitude']}",
            //   ),
            if (hub != null)
              Center(
                child: QrImageView(
                  data:
                      "$locationURL/?orderId=${widget.order['id']}&destination=${hub['latitude']},${hub['longitude']}",
                  version: QrVersions.auto,
                  size: 200.0,
                  gapless: false,
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 120, // Giới hạn chiều rộng của button trái
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Sửa/Hủy",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        SizedBox(
          width: 220,
          child: ElevatedButton(
            onPressed: _confirmDelivery,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE4D2D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Xác nhận giao hàng",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(String name, int quantity, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$quantity x $name", style: const TextStyle(fontSize: 14)),
          Text("${price.toStringAsFixed(0)} xu",
              style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildOrderDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
