import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/restaurant_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/components/restaurant/restaurant_preview.dart';
import 'package:foodygo/view/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic>? _filteredRestaurants;
  bool _isLoading = true;
  bool _isSearching = false;
  final SecureStorage _storage = SecureStorage.instance;
  final RestaurantRepository _repository = RestaurantRepository.instance;
  final AppLogger _logger = AppLogger.instance;
  final TextEditingController _searchController = TextEditingController();
  SavedUser? _user;

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
          _user = user;
          _filteredRestaurants = data;
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

  void _searchRestaurants(String query) async {
    if (_user?.token == null) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final result = await _repository.searchRestaurants(_user!.token, query);
      setState(() {
        _filteredRestaurants = result;
        _isSearching = false;
      });
    } catch (e) {
      _logger.error("Search failed: $e");
      setState(() {
        _isSearching = false;
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
          // Header với thanh tìm kiếm
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "FoodyGo",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.background,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _searchRestaurants(_searchController
                              .text), // Gọi hàm tìm kiếm khi nhấn icon
                          child: const Icon(Icons.search, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (value) => _searchRestaurants(
                                value), // Cũng gọi khi nhấn Enter
                            decoration: const InputDecoration(
                              hintText: "Tìm kiếm nhà hàng...",
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined,
                          size: 28, color: Colors.white),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          "3",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
            child: _isSearching
                ? Center(child: CircularProgressIndicator())
                : _filteredRestaurants == null || _filteredRestaurants!.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sentiment_dissatisfied,
                                size: 60, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              "Không tìm thấy nhà hàng nào!",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
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
                            itemCount: _filteredRestaurants?.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> restaurant =
                                  _filteredRestaurants![index];
                              return RestaurantPreview(
                                restaurant: restaurant,
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
