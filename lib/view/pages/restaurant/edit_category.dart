import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/category_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/category_repostory.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/components/input_field.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class EditCategory extends StatefulWidget {
  final CategoryDto categoryDto;
  const EditCategory({super.key, required this.categoryDto});

  @override
  _EditCategoryState createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  bool _isLoading = true;
  final AppLogger _logger = AppLogger.instance;
  final SecureStorage storage = SecureStorage.instance;
  SavedUser? _user;
  final CategoryRepostory _categoryRepostory = CategoryRepostory.instance; 

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    String? userData = await storage.get(key: 'user');
    SavedUser? user =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;

    setState(() {
      nameController.text = widget.categoryDto.name;
      descriptionController.text = widget.categoryDto.description;
    });
    if (user != null) {
      setState(() {
        _user = user;
      });
    } else {
      _logger.info('Failed to load user');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCategory() async {
    try {
      CategoryDto updateCategory = CategoryDto(
        id: widget.categoryDto.id, 
        name: nameController.text, 
        description: descriptionController.text);

      bool isUpdated =
          await _categoryRepostory.updateCategory(_user!.token, updateCategory);
      if (isUpdated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Danh mục đã được cập nhật thành công!")),
        );
        GoRouter.of(context)
            .go('/protected/manage-categories');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cập nhật danh mục thất bại!")),
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Sửa danh mục",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ô nhập tên danh mục
            InputField(label: "Tên danh mục *", controller: nameController, hintText: "Nhập tên danh mục", expand: true),
            const SizedBox(height: 20),

            // Ô nhập mô tả danh mục
            InputField(label: "Mô tả *", controller: descriptionController, hintText: "Nhập mô tả", expand: true),
            const Spacer(),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _updateCategory();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "Lưu",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
