import 'package:flutter/material.dart';

class TransferPointsPage extends StatefulWidget {
  const TransferPointsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TransferPointsPageState createState() => _TransferPointsPageState();
}

class _TransferPointsPageState extends State<TransferPointsPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  double _points = 0;
  final double _balance = 100; // Giả sử số dư hiện tại là 100 FoodyXu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chuyển điểm'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CHỌN NGƯỜI NHẬN',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Số điện thoại người nhận',
                suffixIcon: Icon(Icons.contacts),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            Text('SỐ UTOP CẦN CHUYỂN',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('Số dư: $_balance FoodyXu',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_points FoodyXu',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${(_points * 1000).toInt()} đ',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _points,
                    min: 0,
                    max: _balance,
                    divisions: _balance.toInt(),
                    label: _points.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _points = value;
                      });
                    },
                  ),
                  Text('Số FoodyXu cần chuyển không được vượt quá số hiện có.',
                      style: TextStyle(color: Colors.grey)),
                  Text('(1.000đ = 1 FoodyXu)',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('Lời nhắn',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nhập lời nhắn',
              ),
              maxLines: 3,
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (_phoneController.text.isEmpty || _points == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Vui lòng nhập đủ thông tin!')),
                    );
                  } else {
                    // Xử lý chuyển điểm
                  }
                },
                child: Text('Chuyển điểm', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
