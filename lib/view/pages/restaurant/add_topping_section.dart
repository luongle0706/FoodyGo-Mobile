import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/addon_section_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/components/input_field.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddToppingSection extends StatefulWidget {
  const AddToppingSection({super.key});

  @override
  State<AddToppingSection> createState() => _AddToppingSectionState();
}

class _AddToppingSectionState extends State<AddToppingSection> {
  bool isLoading = true;
  final AppLogger _logger = AppLogger.instance;
  final SecureStorage storage = SecureStorage.instance;
  SavedUser? _user;
  final AddonSectionRepository addonSectionRepository =
      AddonSectionRepository.instance;

  bool isRequired = false;
  int selectedMaxOptions = 1;
  List<Map<String, dynamic>> _toppings = [];
  final toppingSectionName = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
    loadToppings();
  }

  @override
  void dispose() {
    super.dispose();
    deleteToppings();
  }

  Future<void> deleteToppings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('tempToppings');
  }

  Future<void> loadToppings() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> toppingList = prefs.getStringList('tempToppings') ?? [];

    setState(() {
      _toppings = toppingList
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> init() async {
    String? userData = await storage.get(key: 'user');
    SavedUser? user =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;

    setState(() {});
    if (user != null) {
      setState(() {
        _user = user;
      });
    } else {
      _logger.info('Failed to load user');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildToppingList() {
    return SingleChildScrollView(
      child: Column(
        children: _toppings.map((topping) {
          return ListTile(
            title: Text(topping['name']),
            subtitle: Text("Giá: ${topping['price']}đ"),
          );
        }).toList(),
      ),
    );
  }

  Future<void> saveToppingSection(BuildContext context) async {
    if (toppingSectionName.text.isEmpty) {
      // Báo lỗi nếu chưa nhập tên
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên nhóm topping")),
      );
      return;
    }
    // Tạo JSON body
    final Map<String, dynamic> body = {
      "name": toppingSectionName.text,
      "maxChoice": isRequired ? selectedMaxOptions : 0,
      "required": isRequired,
      "addonItems": _toppings,
    };

    var isCreated =
        await addonSectionRepository.createAddonSection(_user!.token, body);
    if (isCreated) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lưu thành công!")),
        );
      }

      // Xóa temp data
      deleteToppings();

      // Quay về trang trước
      if (context.mounted) {
        GoRouter.of(context).pop();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi đã xảy ra")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () async {
                deleteToppings();
                if (context.mounted) {
                  GoRouter.of(context).pop(); // Quay lại màn hình trước
                }
              },
            ),
            title: const Text(
              "Thêm nhóm Topping",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.primary,
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ));
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () async {
              deleteToppings();
              if (context.mounted) {
                GoRouter.of(context).pop(); // Quay lại màn hình trước
              }
            },
          ),
          title: const Text(
            "Thêm nhóm Topping",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.primary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên Topping
              InputField(
                  label: "Tên nhóm topping: *",
                  controller: toppingSectionName,
                  hintText: "Vd: Topping trà sữa",
                  expand: false),
              const SizedBox(height: 16),

              const Divider(),

              // Món thêm
              const Text(
                "Món thêm",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      bool? result = await context
                          .push<bool>('/protected/add-topping-item');

                      if (result == true) {
                        loadToppings();
                      }
                    },
                    child: const Text("+ Thêm Topping"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200, // Giới hạn chiều cao để tránh lỗi
                child: buildToppingList(),
              ),

              const Divider(),

              // Quyền tùy chọn
              const Text(
                "Quyền tùy chọn",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 8),

              const Text(
                "Khách hàng có bắt buộc phải tùy chọn không?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 8),

              // Radio Button: Không bắt buộc
              RadioListTile<bool>(
                title: const Text("Không bắt buộc"),
                value: false,
                groupValue: isRequired,
                onChanged: (value) {
                  setState(() {
                    isRequired = value!;
                  });
                },
              ),

              // Radio Button: Bắt buộc với số lượng tùy chọn
              RadioListTile<bool>(
                title: const Text("Bắt buộc với số lượng tùy chọn"),
                value: true,
                groupValue: isRequired,
                onChanged: (value) {
                  setState(() {
                    isRequired = value!;
                  });
                },
              ),

              if (isRequired)
                // Dropdown chọn số lượng tối đa
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Số lượng tùy chọn tối đa",
                          style: TextStyle(fontSize: 16)),
                      DropdownButton<int>(
                        value: selectedMaxOptions,
                        onChanged: (value) {
                          setState(() {
                            selectedMaxOptions = value!;
                          });
                        },
                        items: List.generate(
                          5,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text("${index + 1}"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Nút Lưu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    saveToppingSection(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Lưu",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
