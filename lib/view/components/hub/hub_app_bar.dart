import 'package:flutter/material.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class HubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String hubName;
  const HubAppBar({super.key, required this.hubName});

  @override
  Widget build(BuildContext context) {
    String currentRoute = GoRouterState.of(context).matchedLocation;

    int selectedIndex = 0;
    if (currentRoute.contains("/protected/staff-home-arrived")) {
      selectedIndex = 1;
    } else if (currentRoute.contains("/procted/staff-home-history")) {
      selectedIndex = 2;
    }

    return Column(
      mainAxisSize: MainAxisSize.min, // Prevent unnecessary overflow
      children: [
        AppBar(
          backgroundColor: AppColors.text,
          elevation: 2,
          title: Text(
            hubName,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          centerTitle: true,
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              hintText: "Tìm kiếm đơn hàng",
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        DefaultTabController(
          length: 3,
          initialIndex: selectedIndex,
          child: SizedBox(
            height: 50, // Fixed height for TabBar
            child: TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              onTap: (index) {
                switch (index) {
                  case 0:
                    GoRouter.of(context).go("/protected/staff-home");
                    break;
                  case 1:
                    GoRouter.of(context).go("/protected/staff-home-arrived");
                    break;
                  case 2:
                    GoRouter.of(context).go("/protected/staff-home-history");
                    break;
                }
              },
              tabs: const [
                Tab(text: "Đang đến"),
                Tab(text: "Đã giao đến Hub"),
                Tab(text: "Lịch sử"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(150);
}
