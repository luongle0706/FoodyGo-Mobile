import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderSuccessPage extends StatelessWidget {
  final int orderId;
  const OrderSuccessPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FoodyGo"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(90),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.grey[300],
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(Icons.check, size: 200, color: Colors.green),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Bạn đã đặt hàng thành công!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                backgroundColor: Color.fromARGB(255, 189, 75, 3),
              ),
              onPressed: () {
                GoRouter.of(context)
                    .go("/protected/detail-order", extra: orderId);
              },
              child: Text(
                "Xem đơn mua",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                backgroundColor: Color.fromARGB(255, 189, 75, 3),
              ),
              onPressed: () {
                GoRouter.of(context).go("/protected/home");
              },
              child: Text(
                "Về trang chủ",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
