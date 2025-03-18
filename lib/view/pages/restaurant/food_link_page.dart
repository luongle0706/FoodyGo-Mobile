import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/product_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';

class FoodLinkPage extends StatefulWidget {
  final int addonSectionId;
  const FoodLinkPage({super.key, required this.addonSectionId});

  @override
  State<FoodLinkPage> createState() => _FoodLinkPageState();
}

class _FoodLinkPageState extends State<FoodLinkPage> {
  SavedUser? user;

  final ProductRepository productRepository = ProductRepository.instance;
  final AppLogger logger = AppLogger.instance;

  List<dynamic>? linkedProducts;
  List<dynamic>? unlinkedProducts;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    String? userString = await SecureStorage.instance.get(key: 'user');
    SavedUser? userData =
        userString != null ? SavedUser.fromJson(json.decode(userString)) : null;
    if (userData != null) {
      setState(() {
        user = userData;
      });
      bool result = await getLinkedProducts(userData);
      if (result) {
        setState(() {
          isLoading = false;
        });
        return;
      }
    }
    logger.error("Unable to fetch data");
    setState(() {
      isLoading = false;
    });
  }

  Future<bool> getLinkedProducts(SavedUser user) async {
    List<ProductDto>? productsData = await productRepository
        .getProductsByRestaurantId(user.restaurantId!, user.token);
    List<dynamic>? unlinkedProductsData = [];
    List<dynamic>? linkedProductsData = [];
    if (productsData != null) {
      for (ProductDto product in productsData) {
        List<AddonSectionDto>? addonSections = product.addonSections;
        if (addonSections != null) {
          bool containsCurrentSection =
              addonSections.any((e) => e.id == widget.addonSectionId);
          if (containsCurrentSection) {
            linkedProductsData.add({
              "id": product.id,
              "name": product.name,
              "price": product.price
            });
            continue;
          }
        }
        unlinkedProductsData.add(
            {"id": product.id, "name": product.name, "price": product.price});
      }
      setState(() {
        unlinkedProducts = unlinkedProductsData;
        linkedProducts = linkedProductsData;
      });
      return true;
    }
    return false;
  }

  Future<void> linkAddonSection(int productId, BuildContext context) async {
    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      await productRepository.linkProduct(
          productId: productId,
          addonSectionId: widget.addonSectionId,
          accessToken: user!.token);
      await getLinkedProducts(user!);
    } catch (e) {
      logger.error('Error linking addon section: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể liên kết nhóm topping')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> unlinkAddonSection(int productId, BuildContext context) async {
    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      await productRepository.linkProduct(
          productId: productId,
          addonSectionId: widget.addonSectionId,
          accessToken: user!.token);
      await getLinkedProducts(user!);
    } catch (e) {
      logger.error('Error unlinking addon section: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể hủy liên kết nhóm topping')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Liên kết món ăn',
                style: TextStyle(color: Colors.black)),
            backgroundColor: AppColors.background,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ));
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text('Liên kết món ăn',
              style: TextStyle(color: Colors.black)),
          backgroundColor: AppColors.background,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            _buildSection('Đã liên kết', linkedProducts ?? [], isLinked: true),
            _buildSection('Chưa liên kết', unlinkedProducts ?? [],
                isLinked: false),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic> products,
      {required bool isLinked}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.grey[300],
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          color: isLinked ? Colors.grey[100] : AppColors.background,
          child: Column(
            children: products.map((product) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Row(
                  children: [
                    if (!isLinked)
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                        onPressed: () =>
                            linkAddonSection(product['id'], context),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Colors.red,
                        onPressed: () =>
                            unlinkAddonSection(product['id'], context),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product['name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${product['price']}đ',
                      style: TextStyle(
                        color: isLinked ? AppColors.text : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
