import 'package:flutter/material.dart';
import 'package:foodygo/view/pages/restaurant/custome_appbar_order_restaurant_list.dart';
import 'package:go_router/go_router.dart';

class OrderListRestaurantPage extends StatefulWidget {
  const OrderListRestaurantPage({super.key});

  @override
  State<OrderListRestaurantPage> createState() =>
      _OrderListRestaurantPageState();
}

class _OrderListRestaurantPageState extends State<OrderListRestaurantPage> {
  int selectedTab = 0;

  int selectedSubTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: CustomFootageRestaurantOrderAppBar(
        title: "Cơm tấm Ngô Quyền",
      ),
      // 🔹 Nội dung theo Tab chính
      body: selectedTab == 0 ? _buildOrdersTab() : _buildPlaceholderTab(),
    );
  }

  /// 🔹 Giao diện Tab "Đơn"
  Widget _buildOrdersTab() {
    return Column(
      children: [
        // 🔹 Search Bar
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Tìm kiếm đơn hàng",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        // 🔹 Tab con: Mới - Đã xác nhận - Lịch sử
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _tabSelector("Mới", 0),
              _tabSelector("Đã xác nhận", 1),
              _tabSelector("Lịch sử", 2),
            ],
          ),
        ),

        // 🔹 Danh sách đơn hàng
        Expanded(
          child: ListView.builder(
            itemCount: 5, // Giả định có 5 đơn hàng
            itemBuilder: (context, index) {
              return _orderCard();
            },
          ),
        ),
      ],
    );
  }

  /// 🔹 Placeholder cho các Tab khác
  Widget _buildPlaceholderTab() {
    return Center(
      child: Text(
        selectedTab == 1
            ? "Thực đơn đang cập nhật..."
            : "Báo cáo đang cập nhật...",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  /// 🔹 Nút chọn tab chính
  // Widget _tabButton(String text,
  //     {bool isSelected = false, VoidCallback? onTap}) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Column(
  //       children: [
  //         Text(
  //           text,
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //             color: isSelected ? Colors.black : Colors.grey,
  //           ),
  //         ),
  //         if (isSelected)
  //           Container(
  //             margin: EdgeInsets.only(top: 5),
  //             height: 3,
  //             width: 40,
  //             color: Colors.black,
  //           ),
  //       ],
  //     ),
  //   );
  // }

  /// 🔹 Nút chọn tab con
  Widget _tabSelector(String text, int index) {
    return GestureDetector(
      onTap: () => setState(() => selectedSubTab = index),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  selectedSubTab == index ? FontWeight.bold : FontWeight.normal,
              color: selectedSubTab == index ? Colors.black : Colors.grey,
            ),
          ),
          if (selectedSubTab == index)
            Container(
              margin: EdgeInsets.only(top: 5),
              height: 3,
              width: 40,
              color: Colors.black,
            ),
        ],
      ),
    );
  }

  /// 🔹 Card đơn hàng mẫu
  Widget _orderCard() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Tiêu đề đơn hàng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Đơn hàng #12345",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Giờ đặt",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),

            SizedBox(height: 5),

            // 🔹 Thời gian & Trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedSubTab == 0
                      ? "Mới"
                      : selectedSubTab == 1
                          ? "Đã xác nhận"
                          : "Hoàn thành",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selectedSubTab == 0
                        ? Colors.orange
                        : selectedSubTab == 1
                            ? Colors.blue
                            : Colors.green,
                  ),
                ),
              ],
            ),

            Row(
              children: [Text("Tên khách hàng")],
            ),
            Row(
              children: [Text("Tổng số lượng món trong orderorder | giá tiền")],
            ),
            Row(
              children: [Text("Số lượng từng món x tên món")],
            ),
            Row(
              children: [Text("Số lượng từng món x tên món")],
            ),
            SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).push('/orderDetail');
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 141, 136, 133)),
                  child:
                      Text("Xem thêm", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedSubTab = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 235, 93, 4)),
                  child:
                      Text("Xác nhận", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
