import 'package:flutter/material.dart';

class AddToCartPage extends StatelessWidget {
  const AddToCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(150, 150, 150, 0.82),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                "Màn hình trước đó bị làm mờ",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          _buildBottomSheet(context),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh tiêu đề
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Thêm món mới",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          // Thông tin sản phẩm
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Text("Ảnh sản phẩm"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Xoài Non",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text("Hộp 300g"),
                    const Text("35 Đã bán | 1 lượt thích",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 5),
                    const Text("59.000đ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {},
                  ),
                  const Text("1", style: TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),

          // Danh sách Topping
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("Thêm Món Chấm (Topping, tối đa 1)",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),

          _buildToppingItem("Muối tôm", "2.000đ", true),
          _buildToppingItem("Mắm ruốc", "7.000đ", false),

          // Ghi chú
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Ghi chú cho quán",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // Nút thêm vào giỏ hàng
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {},
              child: const Text(
                "Thêm vào giỏ hàng - 59.000đ",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToppingItem(String name, String price, bool selected) {
    return ListTile(
      title: Text(name),
      subtitle:
          Text(price, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Checkbox(value: selected, onChanged: (bool? value) {}),
    );
  }
}
