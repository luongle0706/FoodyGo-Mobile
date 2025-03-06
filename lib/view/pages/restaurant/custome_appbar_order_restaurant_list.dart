import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomFootageRestaurantOrderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  const CustomFootageRestaurantOrderAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container chung bao gồm AppBar và phần chứa các button
        Container(
          padding: EdgeInsets.only(top: 30),
          color: const Color.fromARGB(255, 98, 97, 97),
          child: Column(
            children: [
              AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent, // Để AppBar trong suốt
                elevation: 0,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        Text("Mở cửa", style: TextStyle(color: Colors.black)),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.black),
                      ],
                    ),
                  ],
                ),
              ),
              // Phần chứa các button dưới AppBar
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildTabButton(
                        context, "Đơn", "/protected/restaurant-foodygo"),
                    SizedBox(width: 10),
                    _buildTabButton(
                        context, "Thực đơn", "/protected/restaurant_menu"),
                    SizedBox(width: 10),
                    _buildTabButton(context, "Báo cáo", "/report"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(BuildContext context, String text, String route) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push(route);
      },
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 235, 93, 4),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(150);
}
