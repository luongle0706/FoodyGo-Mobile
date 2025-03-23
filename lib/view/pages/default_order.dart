import 'package:flutter/material.dart';
import 'package:foodygo/view/pages/order_history.dart';
import 'package:foodygo/view/pages/order_view_customer.dart';

class OrderTabsPage extends StatelessWidget {
  const OrderTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "Đang đến"),
              Tab(text: "Lịch sử"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrderListCustomerPage(),
            OrderHistory(),
          ],
        ),
      ),
    );
  }
}
