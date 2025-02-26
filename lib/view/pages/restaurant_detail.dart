import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RestaurantDetailPage extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailPage({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  int cartTotal = 59000; // Sample cart total
  int cartItemCount = 1;

  // Mock restaurant and menu data
  final Map<String, dynamic> restaurantInfo = {
    "name": "Cơm tấm Ngô Quyền",
    "image": "https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp",
    "description":
        "Tiệm này bán cơm sườn, ba rọi, xiên nướng, gà nướng, bì, chả. Cơm thêm, canh thêm miễn phí. Mại dô, mại dô!",
    "phone": "0123 456 789",
    "email": "ngoquyenfood@gmail.com",
    "address": "123 phố ẩm thực khu B"
  };

  final List<Map<String, dynamic>> menuItems = [
    {
      "name": "Cơm tấm sườn, bì, chả, trứng",
      "description": "Cơm tấm siêu cấp ngon",
      "prep_time": "15 phút",
      "price": 25000
    },
    {
      "name": "Cơm tấm sườn, bì, chả, trứng",
      "description": "Cơm tấm siêu cấp ngon",
      "prep_time": "15 phút",
      "price": 25000
    },
    {
      "name": "Cơm tấm sườn, bì, chả, trứng",
      "description": "Cơm tấm siêu cấp ngon",
      "prep_time": "15 phút",
      "price": 25000
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: Text(restaurantInfo['name']),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // Restaurant Info
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                restaurantInfo['image'],
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
                SizedBox(height: 8),
                Text(
                  restaurantInfo['name'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(restaurantInfo['description']),
                      SizedBox(height: 8),
                      Text("📞 ${restaurantInfo['phone']}"),
                      Text("✉️ ${restaurantInfo['email']}"),
                      Text("📍 ${restaurantInfo['address']}"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          // Menu List
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: Text("Ảnh đồ ăn"),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(item['description']),
                            Text("⏳ ${item['prep_time']}"),
                            SizedBox(height: 4),
                            Text("${item['price']}đ",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Bottom Cart Summary
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, size: 24),
                SizedBox(width: 8),
                Text("Tổng cộng: ${cartTotal}đ",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Handle checkout
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text("Thanh toán"),
            )
          ],
        ),
      ),
    );
  }
}
