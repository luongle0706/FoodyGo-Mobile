import 'package:flutter/material.dart';
import 'package:foodygo/view/components/button.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class FoodDetailPage extends StatelessWidget {
  const FoodDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Food image and back button
          Stack(
            children: [
              // Food image
              Image.asset(
                'assets/images/com_tam_suon.jpeg',
                height: 300,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
              // Back button
              Positioned(
                top: 40,
                left: 10,
                child: GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Food detail
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Cơm tấm sườn trứng",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Food description
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Cơm tấm siêu cấp ngon"),
                        SizedBox(height: 4),
                        Text("Thời gian chuẩn bị: 15 phút"),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Add to cart
                  MyButton(
                      onTap: () {},
                      text: 'Thêm vào giỏ hàng',
                      color: AppColors.primary)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
