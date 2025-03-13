import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/cart_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';

class AddToCartPopup extends StatefulWidget {
  final dynamic product;
  final dynamic restaurantId;
  final _logger = AppLogger.instance;
  final VoidCallback onCartUpdated;
  AddToCartPopup(
      {super.key,
      required this.product,
      required this.restaurantId,
      required this.onCartUpdated});

  @override
  _AddToCartPopupState createState() => _AddToCartPopupState();
}

class _AddToCartPopupState extends State<AddToCartPopup> {
  final CartRepository _cartRepository = CartRepository.instance;
  SavedUser? _user;
  Map<int, bool> _selectedAddonsMap = {};
  final _storage = SecureStorage.instance;
  final AppLogger _logger = AppLogger.instance;

  @override
  void initState() {
    super.initState();
    widget._logger.info("Product Name: ${widget.product.name}, "
        "Description: ${widget.product.description}, "
        "Price: ${widget.product.price}, "
        "AddOnSections: ${widget.product.addonSections}");
    loadUser();
  }

  Future<void> loadUser() async {
    String? userData = await _storage.get(key: 'user');
    SavedUser? user =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
    if (user != null) {
      setState(() {
        _user = user;
      });
    } else {
      _logger.info('Failed to load user');
      setState(() {});
    }
  }

  Future<void> addToCart() async {
    if (_user == null) {
      widget._logger.info("User not found! Please log in.");
      return;
    }

    List<Map<String, dynamic>> selectedAddons = [];
    for (var section in widget.product.addonSections ?? []) {
      for (var item in section.items) {
        if (_selectedAddonsMap[item.id] == true) {
          selectedAddons.add({
            "addOnItemId": item.id,
            "addOnItemName": item.name,
            "price": item.price,
            "quantity": 1,
          });
        }
      }
    }

    bool result = await _cartRepository.addToCart(
      accessToken: _user!.token,
      userId: _user!.userId,
      restaurantId: widget.restaurantId,
      productId: widget.product.id,
      productName: widget.product.name,
      price: widget.product.price,
      quantity: 1,
      image: widget.product.image,
      cartAddonItems: selectedAddons,
    );

    if (result) {
      widget._logger.info("Add to cart successfully!");
      widget.onCartUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã thêm vào giỏ hàng!"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildToppingItem(
      String name, String price, int itemId, int maxChoice) {
    return ListTile(
      title: Text(name),
      subtitle:
          Text(price, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Checkbox(
        value: _selectedAddonsMap[itemId] ?? false,
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              if (_selectedAddonsMap.values.where((v) => v).length >=
                  maxChoice) {
                // Lấy ID của phần tử đầu tiên đang được chọn
                int firstSelectedKey = _selectedAddonsMap.entries
                    .firstWhere((entry) => entry.value,
                        orElse: () => const MapEntry(-1, false))
                    .key;

                if (firstSelectedKey != -1) {
                  _selectedAddonsMap[firstSelectedKey] = false;
                }
              }
              _selectedAddonsMap[itemId] = true;
            } else {
              _selectedAddonsMap[itemId] = false;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Thêm món mới",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 10),
                if (widget.product.addonSections != null &&
                    widget.product.addonSections!.isNotEmpty)
                  ...widget.product.addonSections!
                      .map((section) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                    "${section.name} (Tối đa ${section.maxChoice})",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 10),
                              ...section.items
                                  .map((item) => _buildToppingItem(
                                      item.name,
                                      "${item.price.toInt()}đ",
                                      item.id,
                                      section.maxChoice))
                                  .toList(),
                            ],
                          ))
                      .toList(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      addToCart();
                    },
                    child: const Text("Thêm vào giỏ hàng",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
