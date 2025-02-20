import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConfirmOrderPage extends StatelessWidget {
  const ConfirmOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Xác nhận giao hàng"),
        leading: GestureDetector(
          onTap: () {
            GoRouter.of(context).pop();
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 16),
        child: Column(
          children: [
            //address section
            Divider(),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.location_on),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Địa chỉ giao hàng",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text("Quận Nguyễn | 0113114115"),
                      Text("Tòa C3"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(),
            const SizedBox(height: 10),
            //Restaurant name
            Row(
              children: [
                Icon(Icons.local_restaurant),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Xoài Non số dách - Mắm ruốt bao thêm - Nhà hàng Gil Lê",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow:
                        TextOverflow.ellipsis, // Add "..." if text is too long
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Order Details
            Row(
              children: [
                // Image Placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://images.immediate.co.uk/production/volatile/sites/30/2020/08/chorizo-mozarella-gnocchi-bake-cropped-9ab73a3.jpg?resize=768,574',
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
                SizedBox(width: 8),

                // Item Name & Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("1 x Xoài non mắm ruốt"),
                    ],
                  ),
                ),
                Text("59.000đ", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            // Price Breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tổng giá món"),
                Text("59.000đ"),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Phí giao hàng"),
                Text("59.000đ"),
              ],
            ),
            Divider(),

            // Total Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tổng thanh toán",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("59.000đ",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            Spacer(),
            // Order Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 189, 75, 3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "Đặt đơn - 59🙂",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
