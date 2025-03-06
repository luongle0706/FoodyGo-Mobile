import 'package:flutter/material.dart';
import 'package:foodygo/view/theme.dart';

class AddEditCategory extends StatefulWidget {
  const AddEditCategory({super.key});

  @override
  _AddEditCategoryState createState() => _AddEditCategoryState();
}

class _AddEditCategoryState extends State<AddEditCategory> {
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
          "Thêm/Sửa danh mục",
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
                hintText: "VD: Cơm",
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
                labelText: "Mô tả",
                border: const OutlineInputBorder(),
                suffixText: "VD: Món chính với cơm",
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
