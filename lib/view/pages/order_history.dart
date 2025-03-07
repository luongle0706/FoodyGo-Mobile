import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:foodygo/view/pages/welcome_screen.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  int _selectedIndex = 1;

  String selectedService = "Tất cả";
  String selectedStatus = "Tất cả";
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();

  List<String> services = ["Tất cả", "Giao hàng", "Mang đi"];
  List<String> statuses = ["Tất cả", "Đang xử lý", "Hoàn thành", "Đã hủy"];

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime(2025, 12, 31),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  final List<Map<String, dynamic>> orders = [
    {
      "id": "#P11111",
      "title": "Xoài non mắm ruốc",
      "restaurant": "Nhà hàng Gil Lê",
      "price": "59.000đ",
      "quantity": "2 món",
      "name": "Xoài non",
      "status": "Hoàn thành",
      "time": "Hôm nay 11:02",
    },
    {
      "id": "#P11112",
      "title": "Gỏi cuốn tôm thịt",
      "restaurant": "Nhà hàng Phúc",
      "price": "75.000đ",
      "quantity": "3 cuốn",
      "name": "Xoài non",
      "status": "Hoàn thành",
      "time": "Hôm qua 18:45"
    },
    {
      "id": "#P11112",
      "title": "Gỏi cuốn tôm thịt",
      "restaurant": "Nhà hàng Phúc",
      "price": "75.000đ",
      "quantity": "3 cuốn",
      "name": "Xoài non",
      "status": "Hoàn thành",
      "time": "Hôm qua 18:45"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => _selectedIndex = 0),
              child: Text(
                "Đang đến",
                style: TextStyle(
                  color: _selectedIndex == 0 ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 20),
            GestureDetector(
              onTap: () => setState(() => _selectedIndex = 1),
              child: Text(
                "Lịch sử",
                style: TextStyle(
                  color: _selectedIndex == 1 ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _selectedIndex == 1
          ? filter()
          : Center(child: Text("Không có đơn hàng đang đến")),
    );
  }

  Widget filter() {
    return Column(
      children: [
        // lọc
        Container(
          color: Colors.grey[600],
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: selectedService,
                dropdownColor: Colors.white,
                style: TextStyle(color: Colors.white),
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                items: services.map((String service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedService = value!;
                  });
                },
              ),
              DropdownButton<String>(
                value: selectedStatus,
                dropdownColor: Colors.white,
                style: TextStyle(color: Colors.white),
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                items: statuses.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
              GestureDetector(
                onTap: () => _selectDateRange(context),
                child: Row(
                  children: [
                    Text(
                      "${DateFormat('dd/MM/yy').format(startDate)} - ${DateFormat('dd/MM/yy').format(endDate)}",
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(child: buildHistoryList()),
      ],
    );
  }

  Widget buildHistoryList() {
    List<Map<String, dynamic>> filteredOrders = orders.where((order) {
      DateTime orderDate;
      if (order["time"].contains("Hôm nay")) {
        orderDate = DateTime.now();
      } else if (order["time"].contains("Hôm qua")) {
        orderDate = DateTime.now().subtract(Duration(days: 1));
      } else {
        orderDate = DateFormat("dd/MM/yyyy HH:mm").parse(order["time"]);
      }

      bool isInDateRange =
          orderDate.isAfter(startDate.subtract(Duration(days: 1))) &&
              orderDate.isBefore(endDate.add(Duration(days: 1)));

      bool matchesService =
          selectedService == "Tất cả" || order["service"] == selectedService;

      bool matchesStatus =
          selectedStatus == "Tất cả" || order["status"] == selectedStatus;

      return isInDateRange && matchesService && matchesStatus;
    }).toList();

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Đồ ăn ${order["id"]}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(order["time"], style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Text("${order["title"]} - ${order["restaurant"]}",
                    style: TextStyle(color: Colors.grey)),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    );
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: Center(child: Text("Ảnh")),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: 5, top: 25),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(order["price"],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(order["quantity"],
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        Icon(Icons.arrow_forward_ios,
                                            size: 14, color: Colors.grey),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(order["name"],
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order["status"],
                        style: TextStyle(color: Colors.green)),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomeScreen()),
                        );
                      },
                      child: Text("Đặt lại"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
