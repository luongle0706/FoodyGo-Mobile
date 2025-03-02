import 'package:flutter/material.dart';
import 'package:foodygo/view/pages/restaurant/custome_appbar_order_restaurant_list.dart';

class ConfirmedOrderRestaurantScreen extends StatelessWidget {
  const ConfirmedOrderRestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomFootageRestaurantOrderAppBar(title: "Cơm tấm Ngô Quyền"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Tìm kiếm đơn hàng",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return ConfirmedOrderCard();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmedOrderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("02 #2124",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 5),
            Text("Xác nhận lúc 14:08",
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text("Lộc Test"),
            Text("Trạng thái: Chờ giao"),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("2 món", style: TextStyle(fontSize: 14)),
                Text("75.000đ", style: TextStyle(fontSize: 14)),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () {}, child: Text("Xác nhận giao hàng")),
          ],
        ),
      ),
    );
  }
}
