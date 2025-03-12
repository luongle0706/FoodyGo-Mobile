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
        Container(
          padding: const EdgeInsets.only(top: 30),
          color: const Color(0xFFEE4D2D),
          child: Column(
            children: [
              AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Đổi thành trắng để nổi bật
                      ),
                    ),
                    Row(
                      children: const [
                        Text(
                          "Mở cửa",
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              // Phần chứa các button dưới AppBar
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildTabButton(
                        context, "Đơn", "/protected/restaurant-foodygo"),
                    const SizedBox(width: 10),
                    _buildTabButton(
                        context, "Thực đơn", "/protected/restaurant_menu"),
                    const SizedBox(width: 10),
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
          color: const Color(0xFFFF7043), // Màu cam nhạt hơn khi chưa chọn
          borderRadius: BorderRadius.circular(8), // Bo góc mượt hơn
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
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
  Size get preferredSize => const Size.fromHeight(150);
}
