import 'package:flutter/material.dart';
import 'package:foodygo/view/pages/welcome_screen.dart';

class DetailOrder extends StatelessWidget {
  final int status = 3;

  const DetailOrder({super.key}); // 1: Đơn hàng đã được xác nhận,
  // 2: Đơn đang được chuẩn bị,
  // 3: Đơn hàng đang được giao,
  // 4: Đơn hàng đã đến nơi,
  // other: Đang xử lý đơn hàng

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // back privious page
          },
        ),
      ),
      body: SingleChildScrollView(
        // thêm vào để cuon man hình
        physics: BouncingScrollPhysics(), // Scroll smouth
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
                                'Lưu Hữu Phước, Đông Hòa, Dĩ An, Bình Dương, Việt Nam, TP.HCM\nQuân Nguyễn - 0823574803',
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

              // List san pham
              Column(
                children: List.generate(
                  5,
                  (index) => // 5 sản pham
                      Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: Center(child: Text('Ảnh $index')),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('1 x Xoài non',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Text('Muối tôm',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                              Spacer(), // đẩy 2 vật giống space-bêtween

                              Text(
                                '59.000 đ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Divider(),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tổng (5 món)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('295.000đ',
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
                        Text('16.000đ'),
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
                        Text('311.000đ',
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
                        Text('Không có',
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
                        Text('O1111',
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
                        Text('Hôm nay 11:02',
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
              SizedBox(height: 20), // Khoảng cách để tránh bị che mất nút
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
      return 'Đang xử lý đơn hàng';
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
      return Icons.receipt; // 1
    case 2:
      return Icons.kitchen; // 2
    case 3:
      return Icons.delivery_dining; // 3
    case 4:
      return Icons.apartment; // 4
    default:
      return Icons.pending_actions; // other
  }
}
