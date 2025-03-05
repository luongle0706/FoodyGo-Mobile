import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
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
  List<dynamic>? _restaurants;
  bool _isLoading = true;
  final SecureStorage _storage = SecureStorage.instance;
  final RestaurantRepository _repository = RestaurantRepository.instance;
  final AppLogger _logger = AppLogger.instance;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    String? userData = await _storage.get(key: 'user');
    SavedUser? user =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
    if (user != null) {
      Map<String, dynamic> restaurants =
          await _repository.loadRestaurants(user.token);
      if (restaurants['data'] != null) {
        List<dynamic> data = restaurants['data'];
        setState(() {
          _restaurants = data;
          _isLoading = false;
        });
      } else {
        _logger.info("Failed to load restaurants!");
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                  itemCount: _restaurants?.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> restaurant = _restaurants?[index];
                    return RestaurantPreview(
                      restaurant: restaurant,
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
