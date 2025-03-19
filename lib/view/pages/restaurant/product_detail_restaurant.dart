import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodygo/dto/category_dto.dart';
import 'package:foodygo/dto/edit_product_dto.dart';
import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/addon_section_repository.dart';
import 'package:foodygo/repository/category_repostory.dart';
import 'package:foodygo/repository/product_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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
  SavedUser? _user;
  bool _isLoading = true;
  ProductDto? _productDto;
  List<CategoryDto>? _categoryDtoList;
  List<dynamic>? addonSectionList;

  List<String>? selectedAddonSections;

  int? selectedCategoryId;
  File? _selectedImage;
  final name = TextEditingController();
  final price = TextEditingController();
  final description = TextEditingController();
  final prepareTime = TextEditingController();
  final code = TextEditingController();
  bool isAvailable = true;

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
            selectedAddonSections?.add(addonSection.name);
          }
        }
        _productDto = fetchData;
        name.text = fetchData.name;
        price.text = fetchData.price.toString();
        description.text = fetchData.description;
        prepareTime.text = fetchData.prepareTime.toString();
        code.text = fetchData.code;
        isAvailable = fetchData.available;
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
    List<dynamic>? fetchData =
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
        _user = user;
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery); // Mở thư viện ảnh

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _deleteProduct() async {
    try {
      bool isDeleted =
          await _productRepository.deleteProduct(_productDto!.id, _user!.token);
      if (isDeleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Món ăn đã được xóa thành công!")),
        );
        // Quay về trang menu và reload dữ liệu
        GoRouter.of(context)
            .go('/protected/restaurant_menu', extra: _user!.restaurantId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xóa món ăn thất bại!")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi mạng, vui lòng thử lại!")),
      );
    }
  }

  Future<void> _saveEditProduct() async {
    if (_productDto == null || _user == null) return;

    try {
      final editProduct = EditProductDto(
          code: code.text,
          name: name.text,
          price: double.tryParse(price.text) ?? 0.0,
          description: description.text,
          prepareTime: prepareTime.text.isNotEmpty
              ? double.tryParse(prepareTime.text)
              : null,
          available: isAvailable,
          categoryId: selectedCategoryId);

      bool success = await _productRepository.updateProduct(
        _productDto!.id,
        _selectedImage!,
        editProduct,
        _user!.token,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cập nhật thành công!")),
        );
        GoRouter.of(context)
            .go('/protected/restaurant_menu', extra: _user!.restaurantId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cập nhật thất bại!")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi mạng, vui lòng thử lại!")),
      );
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _selectedImage == null
                      ? Image.network(
                          _productDto!.image, // Ảnh mặc định từ server
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          _selectedImage!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _pickImage, // Gọi hàm chọn ảnh
                  child: Text("Sửa"),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Nhập code món
            _buildInputField(
                label: "Code *", hintText: "Nhập code món", controller: code),
            SizedBox(height: 12),

            // Nhập tên món
            _buildInputField(
                label: "Tên *",
                hintText: "Nhập tên món",
                controller: name,
                expand: true),
            SizedBox(height: 12),

            // Nhập giá
            _buildNumberInputField(
                label: "Giá * (Xu)",
                hintText: "Nhập giá món",
                controller: price),
            SizedBox(height: 12),

            // Nhập thời gian chuẩn bị
            _buildNumberInputField(
                label: "Thời gian chuẩn bị * (Phút)",
                hintText: "Nhập thời gian chuẩn bị món",
                controller: prepareTime),
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
                hintText: "Nhập mô tả",
                controller: description,
                expand: true),
            SizedBox(height: 12),

            // Nhóm topping
            ListTile(
              title: Text("Nhóm topping"),
              subtitle: Text(selectedAddonSections?.join(", ") ?? ""),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                GoRouter.of(context).push('/protected/topping-selection',
                    extra: {"productId": widget.productId});
              },
            ),
            SizedBox(height: 12),

            // Còn món (Switch)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Còn món *",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: isAvailable,
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
              onPressed: () => _saveEditProduct(),
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
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String hintText = '',
    bool expand = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(minHeight: 50),
          child: TextField(
            controller: controller,
            maxLines: expand ? null : 1,
            keyboardType: expand ? TextInputType.multiline : TextInputType.text,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInputField({
    required String label,
    required TextEditingController controller,
    String hintText = '',
    bool expand = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(minHeight: 50),
          child: TextField(
            controller: controller,
            maxLines: expand ? null : 1,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(),
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
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
                _deleteProduct();
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
