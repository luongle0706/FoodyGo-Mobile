import 'package:flutter/material.dart';
import 'package:foodygo/view/components/header.dart';
import 'package:foodygo/view/components/restaurant/restaurant_preview.dart';
import 'package:foodygo/view/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Danh sách sản phẩm mẫu
    final List<Map<String, String>> restaurants = [
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'address': '123 phố ẩm thực, đường Đông Hòa',
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'address': '123 phố ẩm thực, đường Đông Hòa',
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'address': '123 phố ẩm thực, đường Đông Hòa',
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'address': '123 phố ẩm thực, đường Đông Hòa',
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'address': '123 phố ẩm thực, đường Đông Hòa',
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'address': '123 phố ẩm thực, đường Đông Hòa',
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'address': '123 phố ẩm thực, đường Đông Hòa',
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'address': '123 phố ẩm thực, đường Đông Hòa',
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'address': '123 phố ẩm thực, đường Đông Hòa',
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'address': '123 phố ẩm thực, đường Đông Hòa',
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'address': '123 phố ẩm thực, đường Đông Hòa',
      },
      {
        'imageUrl':
            'https://img-global.cpcdn.com/recipes/49876fe80303b991/640x640sq70/photo.webp',
        'restaurantName': 'Cơm tấm Ngô Quyền',
        'address': '123 phố ẩm thực, đường Đông Hòa',
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
                "Quán ăn phổ biến",
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
                    childAspectRatio: 1,
                  ),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index];
                    return RestaurantPreview(
                      imageUrl: restaurant['imageUrl']!,
                      restaurantName: restaurant['restaurantName']!,
                      address: restaurant['address']!,
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
