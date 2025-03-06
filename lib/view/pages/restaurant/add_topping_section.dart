import 'package:flutter/material.dart';
import 'package:foodygo/view/theme.dart';

class AddToppingSection extends StatelessWidget {
  const AddToppingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            //Navigator.pop(context);
          },
        ),
        title: const Text(
          "Thêm nhóm Topping",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên Topping
            const Text(
              "Tên *",
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "VD: Thạch",
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
            const SizedBox(height: 16),

            // Món thêm
            const Text(
              "Món thêm",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Xử lý thêm topping
                  },
                  child: const Text("+ Thêm Topping"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quyền tùy chọn
            ListTile(
              title: const Text("Quyền tùy chọn *"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Chuyển sang màn hình chọn danh mục
              },
            ),
            const Divider(),

            // Món đã liên kết
            ListTile(
              title: const Text("Món đã liên kết"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Chuyển sang màn hình chọn món áp dụng
              },
            ),
            const Divider(),

            const Spacer(),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý lưu dữ liệu
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Lưu",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
