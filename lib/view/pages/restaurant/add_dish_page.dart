import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/addon_section_repository.dart';
import 'package:foodygo/repository/category_repostory.dart';
import 'package:foodygo/repository/product_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AddDishPage extends StatefulWidget {
  const AddDishPage({super.key});

  @override
  State<AddDishPage> createState() => _AddDishPageState();
}

class _AddDishPageState extends State<AddDishPage> {
  final ProductRepository productRepository = ProductRepository.instance;
  final CategoryRepostory categoryRepostory = CategoryRepostory.instance;
  final AddonSectionRepository addonSectionRepository =
      AddonSectionRepository.instance;
  final AppLogger logger = AppLogger.instance;

  SavedUser? user;
  List<dynamic>? categories;
  List<dynamic>? addonSections;
  File? selectedImage;

  TextEditingController productCodeCon = TextEditingController();
  TextEditingController productNameCon = TextEditingController();
  TextEditingController descriptionCon = TextEditingController();
  TextEditingController priceCon = TextEditingController();
  TextEditingController prepareTimeCon = TextEditingController();

  int selectedCategoryId = 0;
  String selectedCategoryName = "Chọn danh mục";
  List<int> selectedAddonSectionIds = [];
  List<String> selectedAddonSectionNames = [];
  String addonSectionsText = "Size nhỏ, Size lớn, ...";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void getAddonSections({required SavedUser user}) async {
    List<dynamic>? addonSectionsData =
        await addonSectionRepository.getAddonSectionByRestaurantId(
            accessToken: user.token, restaurantId: user.restaurantId);
    if (addonSectionsData != null) {
      setState(() {
        addonSections = addonSectionsData;
      });
      return;
    }
    logger.error("Unable to get addon sections");
  }

  void getCategories({required SavedUser user}) async {
    Map<String, dynamic>? categoryData = await categoryRepostory.loadCategories(
        accessToken: user.token, pageNo: 1, pageSize: -1);
    if (categoryData != null && categoryData['data'] != null) {
      setState(() {
        categories = categoryData['data'];
      });
    }
  }

  void init() async {
    String? userString = await SecureStorage.instance.get(key: 'user');
    SavedUser? userData =
        userString != null ? SavedUser.fromJson(json.decode(userString)) : null;
    if (userData != null) {
      setState(() {
        user = userData;
        isLoading = false;
      });
      getCategories(user: userData);
      getAddonSections(user: userData);
      return;
    }
    logger.error('Unable to get user');
    setState(() {
      isLoading = false;
    });
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void createProduct(BuildContext context) async {
    if (user == null) return;

    if (selectedCategoryId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bạn phải chọn một danh mục!"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (productNameCon.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tên món không được để trống!"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (priceCon.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Giá không được để trống!"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int price = 0;
    int prepareTime = 0;

    try {
      price = int.parse(priceCon.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Giá phải là số!"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      prepareTime =
          prepareTimeCon.text.isNotEmpty ? int.parse(prepareTimeCon.text) : 0;
    } catch (e) {
      // Default to 0 if invalid
      prepareTime = 0;
    }

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bạn phải cho sản phẩm 1 ảnh!"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }

    bool response = await productRepository.createProduct(
        accessToken: user!.token,
        image: selectedImage,
        productCode: productCodeCon.text,
        productName: productNameCon.text,
        price: price * 1.0,
        description: descriptionCon.text,
        prepareTime: prepareTime * 1.0,
        restaurantId: user!.restaurantId!,
        categoryId: selectedCategoryId,
        addonSectionIds: selectedAddonSectionIds);

    if (response) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tạo sản phẩm thành công"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back after successful creation
        GoRouter.of(context).pop();
      }
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thất bại"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  void _showCategoryPicker(BuildContext context) {
    if (categories == null || categories!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Danh sách danh mục đang trống hoặc đang tải!"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chọn danh mục",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: categories!.length,
                  itemBuilder: (context, index) {
                    final category = categories![index];
                    return ListTile(
                      title: Text(category['name']),
                      onTap: () {
                        setState(() {
                          selectedCategoryId = category['id'];
                          selectedCategoryName = category['name'];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddonSectionPicker(BuildContext context) {
    if (addonSections == null || addonSections!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Danh sách nhóm topping đang trống hoặc đang tải!"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Create a local copy of currently selected IDs to handle cancellation
    List<int> tempSelectedIds = List.from(selectedAddonSectionIds);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Chọn nhóm topping",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: addonSections!.length,
                      itemBuilder: (context, index) {
                        final addonSection = addonSections![index];
                        final bool isSelected =
                            tempSelectedIds.contains(addonSection['id']);

                        return CheckboxListTile(
                          title: Text(addonSection['name']),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                tempSelectedIds.add(addonSection['id']);
                              } else {
                                tempSelectedIds.remove(addonSection['id']);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Hủy"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Save selected addon sections
                          List<String> names = [];
                          for (var section in addonSections!) {
                            if (tempSelectedIds.contains(section['id'])) {
                              names.add(section['name']);
                            }
                          }

                          this.setState(() {
                            selectedAddonSectionIds = tempSelectedIds;
                            selectedAddonSectionNames = names;
                            addonSectionsText = names.isEmpty
                                ? "Size nhỏ, Size lớn, ..."
                                : names.join(", ");
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Xác nhận"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.secondary,
        body: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.background,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: AppColors.primary),
                            onPressed: () => GoRouter.of(context).pop(),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Thêm món",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: AppColors.background,
                        child: ListView(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              color: Colors.grey[200],
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          "Hình ảnh",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Món có hình ảnh sẽ được khách đặt nhiều hơn. Tỷ lệ ảnh yêu cầu: 1:1",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: pickImage,
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        color: Colors.grey[300],
                                        image: selectedImage != null
                                            ? DecorationImage(
                                                image:
                                                    FileImage(selectedImage!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: selectedImage == null
                                          ? Center(
                                              child: TextButton(
                                                onPressed: pickImage,
                                                child: const Text(
                                                  "Chọn",
                                                  style: TextStyle(
                                                      color: AppColors.primary),
                                                ),
                                              ),
                                            )
                                          : Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Container(
                                                    color: Colors.black54,
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                      onPressed: pickImage,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Tên *",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: productNameCon,
                                    decoration: InputDecoration(
                                      hintText: "VD: Khoai tây chiên",
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Mã sản phẩm",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: productCodeCon,
                                    decoration: InputDecoration(
                                      hintText: "VD: KTC001",
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Giá *",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: priceCon,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "Xu",
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Thời gian chuẩn bị (phút)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: prepareTimeCon,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "VD: 10",
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Danh mục *",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _showCategoryPicker(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 16),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            selectedCategoryName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: selectedCategoryId == 0
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ),
                                          const Icon(Icons.arrow_drop_down,
                                              size: 24),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Mô tả",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: descriptionCon,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText:
                                          "VD: Cà chua + Khoai tây chiên + Tương ớt",
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      contentPadding: const EdgeInsets.all(12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Nhóm topping",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () =>
                                        _showAddonSectionPicker(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 16),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              addonSectionsText,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: selectedAddonSectionIds
                                                        .isEmpty
                                                    ? Colors.grey
                                                    : Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(Icons.arrow_drop_down,
                                              size: 24),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.background,
                      child: ElevatedButton(
                        onPressed: () => createProduct(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              "Lưu",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
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
