import 'package:flutter/material.dart';
import 'package:foodygo/view/pages/order_history.dart';
import 'package:foodygo/view/pages/order_view_customer.dart';

class OrderTabsPage extends StatelessWidget {
  final int customerId;

  const OrderTabsPage({super.key, required this.customerId});

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
            OrderListCustomerPage(customerId: customerId),
            OrderHistory(customerId: customerId),
          ],
        ),
      ),
    );
  }
}
