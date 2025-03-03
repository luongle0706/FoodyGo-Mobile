import 'package:flutter/material.dart';
import 'package:foodygo/view/theme.dart';

class ToppingSectionSetting extends StatefulWidget {
  const ToppingSectionSetting({super.key});

  @override
  _ToppingSectionSettingState createState() => _ToppingSectionSettingState();
}

class _ToppingSectionSettingState extends State<ToppingSectionSetting> {
  bool isRequired = false; 
  int selectedMaxOptions = 1; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Quyền tùy chọn",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Khách hàng có bắt buộc phải tùy chọn không?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),

            // Radio Button: Không bắt buộc
            RadioListTile<bool>(
              title: const Text("Không bắt buộc"),
              value: false,
              groupValue: isRequired,
              onChanged: (value) {
                setState(() {
                  isRequired = value!;
                });
              },
            ),

            // Dropdown chọn số lượng tối đa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Số lượng tùy chọn tối đa",
                      style: TextStyle(fontSize: 16)),
                  DropdownButton<int>(
                    value: selectedMaxOptions,
                    onChanged: (value) {
                      setState(() {
                        selectedMaxOptions = value!;
                      });
                    },
                    items: List.generate(
                      5,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text("${index + 1}"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Radio Button: Bắt buộc với số lượng tùy chọn
            RadioListTile<bool>(
              title: const Text("Bắt buộc với số lượng tùy chọn"),
              value: true,
              groupValue: isRequired,
              onChanged: (value) {
                setState(() {
                  isRequired = value!;
                });
              },
            ),

            const Spacer(),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý lưu dữ liệu
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "Lưu",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
