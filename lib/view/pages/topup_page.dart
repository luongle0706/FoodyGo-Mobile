import 'package:flutter/material.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TopupPageState createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  double _points = 30;
  String _selectedPaymentMethod = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mua điểm'),
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
            Text('Nhập số FoodyXu cần mua',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_points.toInt().toString(),
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('FoodyXu', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Slider(
                    value: _points,
                    min: 10,
                    max: 100,
                    divisions: 9,
                    label: _points.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _points = value;
                      });
                    },
                  ),
                  Text('Tổng tiền: ${(1000 * _points).toInt()} đ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('(1.000đ = 1 FoodyXu)',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('PHƯƠNG THỨC THANH TOÁN',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            RadioListTile(
              title: Row(
                children: [
                  Image.asset('assets/images/vnpay_logo.png', height: 24),
                  SizedBox(width: 10),
                  Text('VNPAY'),
                ],
              ),
              value: 'VNPAY',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value.toString();
                });
              },
            ),
            RadioListTile(
              title: Row(
                children: [
                  Image.asset('assets/images/momo_logo.png', height: 24),
                  SizedBox(width: 10),
                  Text('Momo'),
                ],
              ),
              value: 'Momo',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value.toString();
                });
              },
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
                  if (_selectedPaymentMethod.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Vui lòng chọn phương thức thanh toán!')),
                    );
                  } else {
                    // Xử lý mua điểm
                  }
                },
                child:
                    Text('Thực hiện mua điểm', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
