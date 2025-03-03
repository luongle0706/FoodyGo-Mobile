import 'package:flutter/material.dart';
import 'package:foodygo/view/theme.dart';

class AddToppingItem extends StatefulWidget {
  const AddToppingItem({super.key});

  @override
  _AddToppingItemState createState() => _AddToppingItemState();
}

class _AddToppingItemState extends State<AddToppingItem> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Thêm topping",
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
            // Ô nhập tên topping
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Tên*",
                hintText: "VD: Tương ớt",
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 20),

            // Ô nhập giá topping
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Giá*",
                border: const OutlineInputBorder(),
                suffixText: "đ",
              ),
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
                  backgroundColor: AppColors.primary, // Chưa nhập sẽ bị disable
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
