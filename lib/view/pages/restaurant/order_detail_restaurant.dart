import 'package:flutter/material.dart';
import 'package:foodygo/view/theme.dart';

class OrderDetailRestaurant extends StatelessWidget {
  const OrderDetailRestaurant({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chi tiết đơn hàng",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => {},
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
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
                        Text("Nguyễn Thế Anh",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("0337895404",
                            style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  ),
                  Icon(Icons.phone, color: AppColors.primary),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Danh sách món
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  OrderItem(name: "Trái Cây Thập Cẩm", price: "30.000"),
                  Divider(),
                  OrderItem(name: "Đùi gà rán", price: "45.000"),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Tổng tiền
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Tổng tiền món:   75.000đ",
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
                  OrderInfoRow(label: "Mã đơn hàng", value: "30124-509192124"),
                  OrderInfoRow(
                      label: "Thời gian đặt hàng", value: "Hôm nay 14:08"),
                  OrderInfoRow(label: "Khoảng cách", value: "2.2km"),
                  OrderInfoRow(label: "Quán xác nhận", value: "1.6m"),
                  OrderInfoRow(
                      label: "Thời gian lấy hàng dự kiến",
                      value: "Hôm nay 14:38"),
                  OrderInfoRow(
                      label: "Ghi chú của khách", value: "Thêm gói tương ớt"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget hiển thị một món ăn
class OrderItem extends StatelessWidget {
  final String name;
  final String price;

  const OrderItem({super.key, required this.name, required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("1 x  $name"),
        Text(price, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// Widget hiển thị thông tin đơn hàng
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
