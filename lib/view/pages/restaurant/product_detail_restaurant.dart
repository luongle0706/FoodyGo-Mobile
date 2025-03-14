import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/category_dto.dart';
import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/addon_section_repository.dart';
import 'package:foodygo/repository/category_repostory.dart';
import 'package:foodygo/repository/product_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class ProductDetailRestaurant extends StatefulWidget {
  final int productId;

  const ProductDetailRestaurant({super.key, required this.productId});

  @override
  State<ProductDetailRestaurant> createState() =>
      _ProductDetailRestaurantState();
}

class _ProductDetailRestaurantState extends State<ProductDetailRestaurant> {
  final _storage = SecureStorage.instance;
  final ProductRepository _productRepository = ProductRepository.instance;
  final CategoryRepostory _categoryRepostory = CategoryRepostory.instance;
  final AddonSectionRepository _addonSectionRepository =
      AddonSectionRepository.instance;
  final AppLogger _logger = AppLogger.instance;
  //SavedUser? _user;
  bool _isLoading = true;
  ProductDto? _productDto;
  List<CategoryDto>? _categoryDtoList;
  List<AddonSectionDto>? addonSectionList;

  bool isAvailable = true;
  int? selectedCategoryId;
  List<int>? selectedAddonSectionId;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<bool> fetchProduct(String accessToken, int productId) async {
    ProductDto? fetchData =
        await _productRepository.getProductById(productId, accessToken);

    if (fetchData != null) {
      setState(() {
        selectedCategoryId = fetchData.category?.id;
        if (fetchData.addonSections != null) {
          for (var addonSection in fetchData.addonSections!) {
            selectedAddonSectionId?.add(addonSection.id);
          }
        }
        _productDto = fetchData;
      });
      return true;
    }
    return false;
  }

  Future<bool> fetchCategory(String accessToken, int restaurantId) async {
    List<CategoryDto>? fetchData =
        await _categoryRepostory.getCategoriesByRestaurantId(
            accessToken: accessToken, restaurantId: restaurantId);

    if (fetchData != null) {
      setState(() {
        _categoryDtoList = fetchData;
      });
      return true;
    }
    return false;
  }

  Future<bool> fetchAddonSection(String accessToken, int restaurantId) async {
    List<AddonSectionDto>? fetchData =
        await _addonSectionRepository.getAddonSectionByRestaurantId(
            accessToken: accessToken, restaurantId: restaurantId);

    if (fetchData != null) {
      setState(() {
        addonSectionList = fetchData;
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
      setState(() {
        //_user = user;
      });
      bool fetchProductData = await fetchProduct(user.token, widget.productId);
      bool fetchCategoryData =
          await fetchCategory(user.token, user.restaurantId!);
      bool fetchAddonSectionData =
          await fetchAddonSection(user.token, user.restaurantId!);

      if (fetchProductData && fetchCategoryData && fetchAddonSectionData) {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              "Chi tiết món",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
              // Show loading indicator
            ),
          ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chi tiết món",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mã món
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Mã món ăn",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${_productDto?.id}",
                    style: TextStyle(color: Colors.black87)),
              ],
            ),
            SizedBox(height: 12),

            // Hình ảnh
            Text("Hình ảnh", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image, color: Colors.grey[600]),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  child: Text("Sửa"),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Nhập tên món
            _buildInputField(
                label: "Tên *", hintText: "${_productDto?.name}", expand: true),
            SizedBox(height: 12),

            // Nhập giá
            _buildInputField(
                label: "Giá *", hintText: "${_productDto?.price.round()} xu"),
            SizedBox(height: 12),

            // Danh mục (Dropdown)
            Text("Danh mục *", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: selectedCategoryId, // ID của category đang chỉnh sửa
              items: _categoryDtoList?.map((category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),

            SizedBox(height: 12),

            // Mô tả
            _buildInputField(
                label: "Mô tả",
                hintText: "${_productDto?.description}",
                expand: true),
            SizedBox(height: 12),

            // Nhóm topping
            ListTile(
              title: Text("Nhóm topping"),
              subtitle: Text("Size nhỏ, Size lớn, ..."),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            SizedBox(height: 12),

            // Còn món (Switch)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Còn món *",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: _productDto!.available,
                  onChanged: (value) => setState(() => isAvailable = value),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Nút Xóa món
            ElevatedButton(
              onPressed: () => _showDeleteConfirmation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Xóa món"),
            ),
            SizedBox(height: 12),

            // Nút Lưu
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Lưu"),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo ô nhập liệu
  Widget _buildInputField(
      {required String label, required String hintText, bool expand = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(minHeight: 50),
          child: TextField(
            maxLines: expand ? null : 1,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận xóa"),
          content: Text("Bạn có chắc chắn muốn xóa món này không?"),
          actions: [
            TextButton(
              onPressed: () {
                GoRouter.of(context).pop(); // Đóng hộp thoại
              },
              child: Text("Hủy", style: TextStyle(color: Colors.black45)),
            ),
            TextButton(
              onPressed: () {
                // Xử lý xóa món tại đây
                GoRouter.of(context).pop(); // Đóng hộp thoại sau khi xác nhận
              },
              child: Text("Xóa", style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }
}
