import 'package:flutter/material.dart';
import 'package:foodygo/view/components/header.dart';
import 'package:foodygo/view/components/product/product_preview.dart';
import 'package:foodygo/view/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Danh sách sản phẩm mẫu
    final List<Map<String, String>> products = [
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'productName': 'Cơm sườn trứng',
        'price': '25.000đ'
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'productName': 'Cơm sườn trứng',
        'price': '25.000đ'
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'productName': 'Cơm sườn trứng',
        'price': '25.000đ'
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'productName': 'Cơm sườn trứng',
        'price': '25.000đ'
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'productName': 'Cơm sườn trứng',
        'price': '25.000đ'
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'productName': 'Cơm sườn trứng',
        'price': '25.000đ'
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'productName': 'Cơm sườn trứng',
        'price': '25.000đ'
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'productName': 'Cơm sườn trứng',
        'price': '25.000đ'
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'productName': 'Cơm sườn trứng',
        'price': '25.000đ'
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'productName': 'Cơm sườn trứng',
        'price': '25.000đ'
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'productName': 'Cơm sườn trứng',
        'price': '25.000đ'
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'productName': 'Cơm sườn trứng',
        'price': '25.000đ'
      },
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
                "Đồ ăn phổ biến",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = (constraints.maxWidth ~/ 180).clamp(2, 4);

                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductPreview(
                      imageUrl: product['imageUrl']!,
                      restaurantName: product['restaurantName']!,
                      productName: product['productName']!,
                      price: product['price']!,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
