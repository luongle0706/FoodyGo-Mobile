import 'package:flutter/material.dart';
import 'package:foodygo/view/theme.dart';

class ProductDetailRestaurant extends StatefulWidget {
  const ProductDetailRestaurant({super.key});

  @override
  _ProductDetailRestaurantState createState() =>
      _ProductDetailRestaurantState();
}

class _ProductDetailRestaurantState extends State<ProductDetailRestaurant> {
  bool isAvailable = true;
  String selectedCategory = "Chọn danh mục";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chi tiết món",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mã món
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Mã món ăn",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("160373066", style: TextStyle(color: Colors.black87)),
              ],
            ),
            SizedBox(height: 12),

            // Hình ảnh
            Text("Hình ảnh", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image, color: Colors.grey[600]),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  child: Text("Sửa"),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Nhập tên món
            _buildInputField(
                label: "Tên *", hintText: "Khoai tây chiên", expand: true),
            SizedBox(height: 12),

            // Nhập giá
            _buildInputField(label: "Giá *", hintText: "59.000đ"),
            SizedBox(height: 12),

            // Danh mục (Dropdown)
            Text("Danh mục *", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: ["Chọn danh mục", "Món chính", "Đồ ăn vặt"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => selectedCategory = value!),
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 12),

            // Mô tả
            _buildInputField(
                label: "Mô tả",
                hintText: "Cà chua + Khoai tây chiên + Tương ớt",
                expand: true),
            SizedBox(height: 12),

            // Nhóm topping
            ListTile(
              title: Text("Nhóm topping"),
              subtitle: Text("Size nhỏ, Size lớn, ..."),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            SizedBox(height: 12),

            // Còn món (Switch)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Còn món *",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: isAvailable,
                  onChanged: (value) => setState(() => isAvailable = value),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Nút Xóa món
            ElevatedButton(
              onPressed: () => _showDeleteConfirmation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Xóa món"),
            ),
            SizedBox(height: 12),

            // Nút Lưu
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Lưu"),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo ô nhập liệu
  Widget _buildInputField(
      {required String label, required String hintText, bool expand = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(minHeight: 50),
          child: TextField(
            maxLines: expand ? null : 1,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận xóa"),
          content: Text("Bạn có chắc chắn muốn xóa món này không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text("Hủy", style: TextStyle(color: Colors.black45)),
            ),
            TextButton(
              onPressed: () {
                // Xử lý xóa món tại đây
                Navigator.of(context).pop(); // Đóng hộp thoại sau khi xác nhận
                print("Món đã bị xóa!");
              },
              child: Text("Xóa", style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }
}
