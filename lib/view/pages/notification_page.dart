import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<Map<String, String>> orders = [
    {"store": "Cơm Gà Xối Mỡ - Kim Ký", "date": "11/02/2025 17:32"},
    {"store": "Ba Lê - Bánh Mì Thổ Nhĩ Kỳ", "date": "10/02/3026"},
    {"store": "Cơm Tấm 3 Chị Em", "date": "09/02/2025"},
    {"store": "Cơm Gà Xối Mỡ - Kim Ký", "date": "08/02/2025"},
    {"store": "Cơm Gà Xối Mỡ - Kim Ký", "date": "11/02/2025 17:32"},
    {"store": "Cơm Gà Xối Mỡ - Kim Ký", "date": "11/02/2025 17:32"},
    {"store": "Ba Lê - Bánh Mì Thổ Nhĩ Kỳ", "date": "10/02/3026"},
    {"store": "Cơm Tấm 3 Chị Em", "date": "09/02/2025"},
    {"store": "Cơm Gà Xối Mỡ - Kim Ký", "date": "08/02/2025"},
    {"store": "Cơm Gà Xối Mỡ - Kim Ký", "date": "11/02/2025 17:32"},
    {"store": "Cơm Gà Xối Mỡ - Kim Ký", "date": "11/02/2025 17:32"},
    {"store": "Ba Lê - Bánh Mì Thổ Nhĩ Kỳ", "date": "10/02/3026"},
    {"store": "Cơm Tấm 3 Chị Em", "date": "09/02/2025"},
    {"store": "Cơm Gà Xối Mỡ - Kim Ký", "date": "08/02/2025"},
    {"store": "Cơm Gà Xối Mỡ - Kim Ký", "date": "11/02/2025 17:32"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        title: Text(
          "Thông báo",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: 1, color: Colors.grey),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Thông báo quan trọng",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.shade300,
                      child: Center(
                        child: Text(
                          "Ảnh\nsản\nphẩm",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    title: Text(
                        "Đơn hàng tại ${orders[index]['store']} đã hoàn tất"),
                    subtitle: Text(orders[index]['date']!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: "FoodyGo"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: "Ví"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Thông báo"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tài khoản"),
        ],
      ),
    );
  }
}
