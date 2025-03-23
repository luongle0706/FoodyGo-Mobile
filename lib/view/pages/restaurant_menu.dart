import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/dto/restaurant_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/addon_section_repository.dart';
import 'package:foodygo/repository/product_repository.dart';
import 'package:foodygo/repository/restaurant_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';

class RestaurantMenu extends StatefulWidget {
  const RestaurantMenu({super.key});

  @override
  State<RestaurantMenu> createState() => _RestaurantMenuState();
}

class _RestaurantMenuState extends State<RestaurantMenu> {
  final _storage = SecureStorage.instance;
  final AppLogger _logger = AppLogger.instance;
  final RestaurantRepository _restaurantRepository =
      RestaurantRepository.instance;
  final AddonSectionRepository _addonSectionRepository =
      AddonSectionRepository.instance;
  List<ProductDto>? _productDto;
  List<dynamic>? _addonSection;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<bool> fetchRestaurant({required SavedUser user}) async {
    RestaurantDto? fetchOrder = await _restaurantRepository.loadRestaurantById(
        user.token, user.restaurantId!);

    List<ProductDto>? fetchProduct = await _restaurantRepository
        .getProductsByRestaurantId(user.token, user.restaurantId!);

    if (fetchOrder != null) {
      setState(() {
        _productDto = fetchProduct;
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
      bool fetchOrderData = await fetchRestaurant(user: user);
      List<dynamic>? fetchAddonSection =
          await _addonSectionRepository.getAddonSectionByRestaurantId(
              accessToken: user.token, restaurantId: user.restaurantId);
      _logger.info("addonSection: $fetchAddonSection");

      if (fetchOrderData) {
        setState(() {
          _addonSection = fetchAddonSection;
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
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: MenuScreen(
            toppingGroups: toppingGroups,
            productDto: _productDto,
            addonSections: _addonSection,
          ),
        ),
      ],
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
  final List<dynamic>? addonSections;
  const MenuScreen({
    super.key,
    required this.toppingGroups,
    required this.productDto,
    this.addonSections,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int selectedTab = 0; // 0: Món, 1: Nhóm Topping
  String searchQuery = "";

  final ProductRepository _productRepository = ProductRepository.instance;

  final AppLogger logger = AppLogger.instance;
  final _storage = SecureStorage.instance;

  @override
  Widget build(BuildContext context) {
    List<ProductDto> filteredProducts = widget.productDto!
        .where((product) =>
            product.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    Future<void> switchAvailability(int productId) async {
      try {
        String? userData = await _storage.get(key: 'user');
        SavedUser? user =
            userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
        if (user != null) {
          final success = await _productRepository.switchAvailabilityProduct(
              user.token, productId);

          if (success) {
            final productIndex =
                widget.productDto!.indexWhere((p) => p.id == productId);
            if (productIndex != -1) {
              final updatedProduct = widget.productDto![productIndex].copyWith(
                available: !widget.productDto![productIndex].available,
              );

              setState(() {
                widget.productDto![productIndex] = updatedProduct;
              });
            }
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error switching availability: $e'),
          ),
        );
      }
    }

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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.orange),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.orange),
              ),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
          ),
        ),
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
                    color: selectedTab == 0 ? Colors.orange : Colors.grey[500],
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
                    color: selectedTab == 1 ? Colors.orange : Colors.grey[500],
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
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  // Xử lý khi nhấn nút Vị trí
                },
                icon: Icon(Icons.list, color: Colors.orange),
                label: Text("Vị trí", style: TextStyle(color: Colors.orange)),
              ),
              TextButton.icon(
                onPressed: () {
                  if (selectedTab == 0) {
                    GoRouter.of(context).push('/protected/add-dish');
                  } else {
                    GoRouter.of(context).push('/protected/add-topping-section');
                  }
                },
                icon: Icon(Icons.add, color: Colors.orange),
                label: Text("Thêm", style: TextStyle(color: Colors.orange)),
              ),
              TextButton.icon(
                onPressed: () {
                  GoRouter.of(context).push('/protected/manage-categories');
                },
                icon: Icon(Icons.edit, color: Colors.orange),
                label: Text("Chỉnh sửa danh mục",
                    style: TextStyle(color: Colors.orange)),
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
                  title: Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text("${product.price.toStringAsFixed(0)}đ"),
                  trailing: Switch(
                    value: product.available,
                    onChanged: (value) {
                      setState(() {
                        switchAvailability(product.id);
                      });
                    },
                    activeColor: Colors.orange,
                  ),
                );
              } else {
                if (widget.addonSections != null &&
                    widget.addonSections!.isNotEmpty) {
                  final addonSection = widget.addonSections![categoryIndex];
                  final itemsList = addonSection['items'] as List<dynamic>;

                  return GestureDetector(
                    onTap: () {
                      GoRouter.of(context).push('/protected/food-link',
                          extra: {'addonSectionId': addonSection['id']});
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    addonSection['name'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text("Số lượng topping: ${itemsList.length}"),
                                  SizedBox(height: 8),
                                  Text(
                                    itemsList
                                        .map((item) => item['name'])
                                        .join(', '),
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  var item = widget.toppingGroups[categoryIndex];
                  return GestureDetector(
                    onTap: () {
                      GoRouter.of(context).push('/protected/food-link',
                          extra: {'addonSectionId': 1});
                    },
                    child: ListTile(
                      title: Text(item["name"]),
                      subtitle: Text("Số lượng topping: ${item["count"]}"),
                    ),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
