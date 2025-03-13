import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/dto/restaurant_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/restaurant_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
// import 'package:foodygo/view/pages/restaurant/custome_appbar_order_restaurant_list.dart';
import 'package:go_router/go_router.dart';

class RestaurantMenu extends StatefulWidget {
  final int restaurantId;

  const RestaurantMenu({super.key, required this.restaurantId});

  @override
  State<RestaurantMenu> createState() => _RestaurantMenuState();
}

class _RestaurantMenuState extends State<RestaurantMenu> {
  final _storage = SecureStorage.instance;
  final AppLogger _logger = AppLogger.instance;
  final RestaurantRepository _restaurantRepository =
      RestaurantRepository.instance;
  RestaurantDto? _restaurantDto;
  List<ProductDto>? _productDto;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<bool> fetchRestaurant(String accessToken) async {
    RestaurantDto? fetchOrder = await _restaurantRepository.loadRestaurantById(
        accessToken, widget.restaurantId);

    List<ProductDto>? fetchProduct = await _restaurantRepository
        .getProductsByRestaurantId(accessToken, widget.restaurantId);

    if (fetchOrder != null) {
      setState(() {
        _restaurantDto = fetchOrder;
        _productDto = fetchProduct;
        _isLoading = false;
      });
      return true;
    }
    return false;
  }

  Future<void> loadUser() async {
    String? userData = await _storage.get(key: 'user');
    SavedUser? user =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
    if (user != null) {
      bool fetchOrderData = await fetchRestaurant(user.token);

      if (fetchOrderData) {
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = true;
        });
      }
    } else {
      _logger.info('Failed to load user');
      setState(() {
        _isLoading = false;
      });
    }
  }

  int selectedTab = 1;

  List<Map<String, dynamic>> toppingGroups = [
    {"name": "Topping 1", "description": "Mô tả topping 1"},
    {"name": "Topping 2", "description": "Mô tả topping 2"},
    {"name": "Topping 3", "description": "Mô tả topping 3"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _restaurantDto != null
                ? Text(
                    _restaurantDto!.name,
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  )
                : SizedBox(),
            GestureDetector(
              onTap: () {
                GoRouter.of(context)
                    .push("/protected/open-hours-setting", extra: 1);
              },
              child: _restaurantDto != null
                  ? Row(
                      children: [
                        Icon(Icons.circle,
                            size: 11,
                            color: _restaurantDto!.available
                                ? Colors.green
                                : Colors.grey),
                        SizedBox(width: 5),
                        Text(
                          _restaurantDto!.available ? "Mở cửa " : "Đóng cửa ",
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: _restaurantDto!.available
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 15, color: Colors.grey),
                      ],
                    )
                  : SizedBox(),
            )
          ],
        ),
      ),
      backgroundColor: Colors.grey[300],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: MenuScreen(
                      toppingGroups: toppingGroups, productDto: _productDto),
                ),
              ],
            ),
    );
  }

  Widget buildTabButton(String title, int index) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selectedTab == index ? Colors.grey[400] : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: selectedTab == index ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class MenuScreen extends StatefulWidget {
  final List<Map<String, dynamic>> toppingGroups;
  final List<ProductDto>? productDto;
  const MenuScreen(
      {super.key, required this.toppingGroups, required this.productDto});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int selectedTab = 0; // 0: Món, 1: Nhóm Topping
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<ProductDto> filteredProducts = widget.productDto!
        .where((product) =>
            product.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: "Nhập tên món ăn",
              prefixIcon: Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
          ),
        ),
        // Thanh menu
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => setState(() => selectedTab = 0),
                child: Text(
                  "Món",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selectedTab == 0 ? Colors.blue : Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => selectedTab = 1),
                child: Text(
                  "Nhóm Topping",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selectedTab == 1 ? Colors.blue : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(),

        Container(
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          // padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  // Xử lý khi nhấn nút Vị trí
                },
                icon: Icon(Icons.list, color: Colors.black),
                label: Text("Vị trí", style: TextStyle(color: Colors.black)),
              ),
              TextButton.icon(
                onPressed: () {
                  GoRouter.of(context).push('/protected/add-dish');
                },
                icon: Icon(Icons.add, color: Colors.black),
                label: Text("Thêm", style: TextStyle(color: Colors.black)),
              ),
              TextButton.icon(
                onPressed: () {
                  GoRouter.of(context).push('/protected/manage-categories');
                },
                icon: Icon(Icons.edit, color: Colors.black),
                label: Text("Chỉnh sửa danh mục",
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: selectedTab == 0
                ? filteredProducts.length
                : widget.toppingGroups.length,
            itemBuilder: (context, categoryIndex) {
              if (selectedTab == 0) {
                var product = filteredProducts[categoryIndex];
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[400],
                    child: Center(child: Text("Ảnh")),
                  ),
                  onTap: () {
                    GoRouter.of(context).push(
                        "/protected/product-detail-restaurant",
                        extra: product.id);
                  },
                  title: Text(product.name),
                  subtitle: Text("${product.price.toStringAsFixed(0)}đ"),
                  trailing: Switch(
                    value: product.available,
                    onChanged: (value) {
                      setState(() {
                        // product.available = value;
                      });
                    },
                  ),
                );
              } else {
                var item = widget.toppingGroups[categoryIndex];
                return ListTile(
                  title: Text(item["name"]),
                  subtitle: Text("Số lượng topping: ${item["count"]}"),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
