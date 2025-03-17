import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/addon_section_repository.dart';
import 'package:foodygo/repository/product_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';

class ToppingSelectionPage extends StatefulWidget {
  final int productId;
  const ToppingSelectionPage({super.key, required this.productId});

  @override
  State<ToppingSelectionPage> createState() => _ToppingSelectionPageState();
}

class _ToppingSelectionPageState extends State<ToppingSelectionPage> {
  final AppLogger logger = AppLogger.instance;
  final ProductRepository productRepository = ProductRepository.instance;
  final AddonSectionRepository addonSectionRepository =
      AddonSectionRepository.instance;

  List<AddonSectionDto> linkedAddonSections = [];
  List<AddonSectionDto> unlinkedAddonSections = [];

  bool isLoading = true;
  SavedUser? currentUser;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    try {
      String? userData = await SecureStorage.instance.get(key: 'user');
      currentUser =
          userData != null ? SavedUser.fromJson(json.decode(userData)) : null;

      if (currentUser != null) {
        await fetchAddonSections();
      }
    } catch (e) {
      logger.error('Error initializing topping selection: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAddonSections() async {
    if (currentUser == null) return;

    // Fetch product data
    ProductDto? productData = await productRepository.getProductById(
        widget.productId, currentUser!.token);

    // Fetch all addon sections for the restaurant
    List<dynamic>? allAddonSectionsData =
        await addonSectionRepository.getAddonSectionByRestaurantId(
            accessToken: currentUser!.token,
            restaurantId: currentUser!.restaurantId);

    if (productData != null && allAddonSectionsData != null) {
      // Convert dynamic list to List<AddonSectionDto>
      List<AddonSectionDto> allAddonSections =
          allAddonSectionsData.map((e) => AddonSectionDto.fromJson(e)).toList();

      // Categorize addon sections
      _categorizeAddonSections(
          productData.addonSections ?? [], allAddonSections);
    }
  }

  void _categorizeAddonSections(List<AddonSectionDto> productAddonSections,
      List<AddonSectionDto> allAddonSections) {
    // Reset lists
    linkedAddonSections.clear();
    unlinkedAddonSections.clear();

    // Categorize addon sections
    for (var addonSection in allAddonSections) {
      bool isLinked =
          productAddonSections.any((pa) => pa.id == addonSection.id);
      if (isLinked) {
        linkedAddonSections.add(addonSection);
      } else {
        unlinkedAddonSections.add(addonSection);
      }
    }
  }

  // Function to link an addon section to the product
  Future<void> linkAddonSection(
      int addonSectionId, BuildContext context) async {
    if (currentUser == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Call the link product API
      await productRepository.linkProduct(
          productId: widget.productId,
          addonSectionId: addonSectionId,
          accessToken: currentUser!.token);

      // Update local state directly instead of fetching all data again
      // Move addon section from unlinked to linked
      setState(() {
        final sectionIndex = unlinkedAddonSections
            .indexWhere((section) => section.id == addonSectionId);
        if (sectionIndex != -1) {
          final section = unlinkedAddonSections.removeAt(sectionIndex);
          linkedAddonSections.add(section);
        }
      });
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

// Function to unlink an addon section from the product
  Future<void> unlinkAddonSection(
      int addonSectionId, BuildContext context) async {
    if (currentUser == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Call the unlink product API - this should be different from linkProduct!
      // If your repository doesn't have an unlinkProduct method, you'll need to add one
      await productRepository.linkProduct(
          productId: widget.productId,
          addonSectionId: addonSectionId,
          accessToken: currentUser!.token);

      // Update local state directly instead of fetching all data again
      // Move addon section from linked to unlinked
      setState(() {
        final sectionIndex = linkedAddonSections
            .indexWhere((section) => section.id == addonSectionId);
        if (sectionIndex != -1) {
          final section = linkedAddonSections.removeAt(sectionIndex);
          unlinkedAddonSections.add(section);
        }
      });
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
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: const Text('Nhóm Topping',
                style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                GoRouter.of(context).pop();
              },
            ),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ));
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title:
            const Text('Nhóm Topping', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          _buildSection('Đã liên kết', linkedAddonSections, isLinked: true),
          _buildSection('Chưa liên kết', unlinkedAddonSections,
              isLinked: false),
          _buildCompleteButton(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<AddonSectionDto> addonSections,
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          color: isLinked ? Colors.grey[100] : Colors.white,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: addonSections.length,
            itemBuilder: (context, index) {
              final addonSection = addonSections[index];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: isLinked,
                      onChanged: isLoading
                          ? null // Disable checkbox when loading
                          : (value) {
                              if (isLinked) {
                                unlinkAddonSection(addonSection.id, context);
                              } else {
                                linkAddonSection(addonSection.id, context);
                              }
                            },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addonSection.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (addonSection.items != null)
                            Text(
                              addonSection.items!
                                  .map((item) => item.name)
                                  .join(', '),
                              style: const TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          GoRouter.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[600],
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Hoàn tất',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
