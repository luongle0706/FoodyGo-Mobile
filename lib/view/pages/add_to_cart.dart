import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/cart_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';

class AddToCartPopup extends StatefulWidget {
  final dynamic product;
  final dynamic restaurantId;
  final _logger = AppLogger.instance;
  final VoidCallback onCartUpdated;
  final List<dynamic>? existingAddons;

  AddToCartPopup({
    super.key,
    required this.product,
    required this.restaurantId,
    required this.onCartUpdated,
    this.existingAddons,
  });

  @override
  State<AddToCartPopup> createState() => _AddToCartPopupState();
}

class _AddToCartPopupState extends State<AddToCartPopup> {
  final CartRepository _cartRepository = CartRepository.instance;
  SavedUser? _user;
  final Map<int, bool> _selectedAddonsMap = {};
  final Map<int, int> _addonToSectionMap = {};
  final _storage = SecureStorage.instance;
  final AppLogger _logger = AppLogger.instance;

  @override
  void initState() {
    super.initState();
    widget._logger.info("Product Name: ${widget.product.name}, "
        "Description: ${widget.product.description}, "
        "Price: ${widget.product.price}, "
        "AddOnSections: ${widget.product.addonSections}");
    // Map each addon item to its section ID for later reference
    if (widget.product.addonSections != null) {
      for (var section in widget.product.addonSections) {
        for (var item in section.items) {
          _addonToSectionMap[item.id] = section.id;
        }
      }
    }
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

  Future<void> addToCart(BuildContext context) async {
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

    // Ensure price calculation includes addons in the UI
    // double totalPrice = widget.product.price;
    // for (var addon in selectedAddons) {
    //   totalPrice += (addon["price"] as double) * (addon["quantity"] as int);
    // }

    // Pass the calculated price or let backend do it
    bool result = await _cartRepository.addToCart(
      accessToken: _user!.token,
      userId: _user!.userId,
      restaurantId: widget.restaurantId,
      productId: widget.product.id,
      productName: widget.product.name,
      price: widget.product.price, // Base price only
      quantity: 1,
      image: widget.product.image,
      cartAddonItems: selectedAddons,
    );

    if (result) {
      widget._logger.info("Add to cart successfully!");
      widget.onCartUpdated();
      if (context.mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text("Đã thêm vào giỏ hàng!"),
        //     duration: Duration(seconds: 2),
        //     backgroundColor: Colors.green,
        //   ),
        // );
        GoRouter.of(context).pop();
      }
    }
  }

  // Get the number of selected items in a specific section
  int getSelectedCountForSection(int sectionId) {
    int count = 0;
    _selectedAddonsMap.forEach((itemId, isSelected) {
      if (isSelected && _addonToSectionMap[itemId] == sectionId) {
        count++;
      }
    });
    return count;
  }

  Widget _buildToppingItem(
      String name, String price, int itemId, int sectionId, int maxChoice) {
    return ListTile(
      title: Text(name),
      subtitle:
          Text(price, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Checkbox(
        value: _selectedAddonsMap[itemId] ?? false,
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              // Check if adding this item would exceed the section's max choice
              if (getSelectedCountForSection(sectionId) >= maxChoice) {
                // Find the first selected item in this section to unselect
                int? firstSelectedKey;
                _selectedAddonsMap.forEach((id, selected) {
                  if (selected &&
                      _addonToSectionMap[id] == sectionId &&
                      firstSelectedKey == null) {
                    firstSelectedKey = id;
                  }
                });

                if (firstSelectedKey != null) {
                  _selectedAddonsMap[firstSelectedKey!] = false;
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
                                      section.id,
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
                      addToCart(context);
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
