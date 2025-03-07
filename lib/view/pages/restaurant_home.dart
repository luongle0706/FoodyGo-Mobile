import 'package:flutter/material.dart';
import 'package:foodygo/view/pages/welcome_screen.dart';

class Restaurant {
  String name;
  bool isOpen;

  Restaurant({required this.name, required this.isOpen});
}

class RestaurantHome extends StatefulWidget {
  const RestaurantHome({super.key});

  @override
  State<RestaurantHome> createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends State<RestaurantHome> {
  Restaurant restaurant = Restaurant(name: "Cơm tấm Ngô Quyền", isOpen: true);

  List<Map<String, dynamic>> menuItems = [
    {"icon": Icons.receipt_long, "title": "Đơn hàng"},
    {"icon": Icons.restaurant_menu, "title": "Thực đơn"},
    {"icon": Icons.bar_chart, "title": "Báo cáo"},
    {"icon": Icons.storefront, "title": "Thông tin"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              restaurant.name,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Icon(Icons.circle,
                    size: 11,
                    color: restaurant.isOpen ? Colors.green : Colors.grey),
                SizedBox(width: 5),
                Text(
                  restaurant.isOpen ? "Mở cửa " : "Đóng cửa ",
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: restaurant.isOpen ? Colors.green : Colors.grey,
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 15, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 0),
        child: Container(
          color: Colors.grey.shade300,
          padding: EdgeInsets.all(35),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              return _buildMenuItem(
                  menuItems[index]["icon"], menuItems[index]["title"]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        if (title == "Thực đơn") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade400, blurRadius: 3, spreadRadius: 1),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black),
            SizedBox(height: 10),
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
