import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/view/components/input_field.dart';
import 'package:foodygo/view/components/input_number_field.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddToppingItem extends StatefulWidget {
  const AddToppingItem({super.key});

  @override
  _AddToppingItemState createState() => _AddToppingItemState();
}

class _AddToppingItemState extends State<AddToppingItem> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  Future<void> saveTopping() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> toppingList = prefs.getStringList('tempToppings') ?? [];

    Map<String, dynamic> newTopping = {
      'name': nameController.text,
      'price': double.tryParse(priceController.text) ?? 0,
      'quantity': int.tryParse(quantityController.text) ?? 0
    };

    toppingList.add(jsonEncode(newTopping));
    await prefs.setStringList('tempToppings', toppingList);

    GoRouter.of(context).pop(true); // Pop về và báo hiệu có thay đổi
  }

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
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
            InputField(
                label: "Tên topping: *",
                controller: nameController,
                hintText: "Vd: Trân châu đen",
                expand: false),
            const SizedBox(height: 20),

            // Ô nhập giá topping
            InputNumberField(
                label: "Đơn giá: *",
                controller: priceController,
                hintText: "Nhập giá topping",
                expand: false),
            const SizedBox(height: 20),

            // Ô nhập số lượng topping
            InputNumberField(
                label: "Số lượng: *",
                controller: quantityController,
                hintText: "Số lượng đặt tối đa cho topping",
                expand: false),
            const SizedBox(height: 20),

            const Spacer(),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  saveTopping();
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
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
