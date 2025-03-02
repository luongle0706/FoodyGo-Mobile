import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/restaurant_dto.dart';
import 'package:foodygo/repository/restaurant_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/components/header.dart';
import 'package:foodygo/view/components/restaurant/restaurant_preview.dart';
import 'package:foodygo/view/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<RestaurantDto>>? _restaurants;

  final SecureStorage storage = SecureStorage.instance;
  final RestaurantRepository repository = RestaurantRepository.instance;
  final AppLogger logger = AppLogger.instance;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  void _loadRestaurants() {
    setState(() {
      _restaurants = fetchRestaurant();
    });
  }

  Future<List<RestaurantDto>> fetchRestaurant() async {
    String? savedUser = await storage.get(key: 'user');
    Map<String, dynamic> userMap = json.decode(savedUser!);
    String? accessToken = userMap['token'];

    return repository.loadRestaurants(accessToken!);
  }

  @override
  Widget build(BuildContext context) {
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
          FutureBuilder(
              future: _restaurants,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final res = snapshot.data!;
                  return Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount =
                            (constraints.maxWidth ~/ 180).clamp(2, 4);

                        return GridView.builder(
                          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: res.length,
                          itemBuilder: (context, index) {
                            final restaurant = res[index];
                            return RestaurantPreview(
                              id: restaurant.id,
                              imageUrl: restaurant.image,
                              restaurantName: restaurant.name,
                              address: restaurant.address,
                            );
                          },
                        );
                      },
                    ),
                  );
                }
                return Center(
                  child: Text("Đang lấy dữ liệu"),
                );
              })
        ],
      ),
    );
  }
}
