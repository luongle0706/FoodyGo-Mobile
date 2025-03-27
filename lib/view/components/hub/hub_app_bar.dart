import 'package:flutter/material.dart';
import 'package:foodygo/view/theme.dart';

class HubAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String hubName;
  final int selectedIndex;
  final void Function(int) onTapTapped;

  const HubAppBar(
      {super.key,
      required this.hubName,
      required this.selectedIndex,
      required this.onTapTapped});

  @override
  State<HubAppBar> createState() => _HubAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(150);
}

class _HubAppBarState extends State<HubAppBar> {
  @override
  Widget build(BuildContext context) {
    // String currentRoute = GoRouterState.of(context).matchedLocation;

    return Column(
      mainAxisSize: MainAxisSize.min, // Prevent unnecessary overflow
      children: [
        AppBar(
          backgroundColor: AppColors.text,
          elevation: 2,
          title: Text(
            widget.hubName,
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
          initialIndex: widget.selectedIndex,
          child: SizedBox(
            height: 50, // Fixed height for TabBar
            child: TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              onTap: widget.onTapTapped,
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
}
