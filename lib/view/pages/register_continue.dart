import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/customer_repository.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/components/button.dart';
import 'package:foodygo/view/components/input_field_w_icon.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class RegisterContinue extends StatefulWidget {
  final int? chosenBuildingId;
  final String? chosenBuildingName;
  const RegisterContinue(
      {super.key, this.chosenBuildingId, this.chosenBuildingName});

  @override
  State<RegisterContinue> createState() => _RegisterContinueState();
}

class _RegisterContinueState extends State<RegisterContinue> {
  SavedUser? user;
  final CustomerRepository customerRepository = CustomerRepository.instance;

  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  File? selectedImage;

  bool isValidVietnamesePhoneNumber(String phoneNumber) {
    final RegExp regex = RegExp(r'^(03|05|07|08|09)[0-9]{8,9}$');
    return regex.hasMatch(phoneNumber);
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    String? userString = await SecureStorage.instance.get(key: 'user');
    SavedUser? userData =
        userString != null ? SavedUser.fromJson(json.decode(userString)) : null;
    if (userData != null) {
      setState(() {
        user = userData;
      });
    }
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

  Future<void> updateCustomerInfo() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không tìm thấy thông tin người dùng!")),
      );
      return;
    }

    final String phoneNumber = phoneController.text.trim();
    final String dobString = dobController.text.trim();

    if (phoneNumber.isEmpty ||
        dobString.isEmpty ||
        widget.chosenBuildingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin!")),
      );
      return;
    }

    if (!isValidVietnamesePhoneNumber(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Số điện thoại không hợp lệ!")),
      );
      return;
    }

    try {
      DateTime dob = DateFormat('dd/MM/yyyy').parse(dobString);

      bool result = await customerRepository.updateCustomer(
        userId: user!.userId,
        accessToken: user!.token,
        buildingId: widget.chosenBuildingId!,
        phone: phoneNumber,
        dob: dob,
        image: selectedImage,
      );

      if (result) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Cập nhật thông tin thành công!")),
        // );
        if (mounted) GoRouter.of(context).push('/protected/home');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cập nhật thông tin thất bại!")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cập nhật thất bại: $e")),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    phoneController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Back icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    context.pop();
                  },
                  child: SizedBox(
                    height: 20,
                    child: Image.asset('assets/icons/back-icon.png'),
                  ),
                ),
              ],
            ),

            // Profile image section
            InkWell(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: selectedImage != null
                    ? FileImage(selectedImage!)
                    : const AssetImage('assets/icons/ellispe-icon.png')
                        as ImageProvider,
                child: selectedImage == null
                    ? const Icon(Icons.camera_alt,
                        size: 40, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tải ảnh đại diện',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 70),

            // Input fields
            IconTextField(
              controller: phoneController,
              hintText: "Số điện thoại",
              obscureText: false,
              iconPath: 'assets/icons/phone-icon.png',
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  String formattedDate =
                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  setState(() {
                    dobController.text = formattedDate;
                  });
                }
              },
              child: IgnorePointer(
                child: IconTextField(
                  controller: dobController,
                  hintText: "Ngày sinh (DD/MM/YYYY)",
                  obscureText: false,
                  iconPath: 'assets/icons/calendar-icon.png',
                ),
              ),
            ),

            const SizedBox(height: 20.0),

            InkWell(
              onTap: () {
                GoRouter.of(context).push('/map/building',
                    extra: {'callOfOrigin': '/register-continue'});
              },
              child: IgnorePointer(
                child: IconTextField(
                  controller: TextEditingController(),
                  hintText: widget.chosenBuildingName ?? "Chọn tòa bạn đang ở",
                  obscureText: false,
                  iconPath: 'assets/icons/location-icon.png',
                ),
              ),
            ),
            const SizedBox(height: 50),
            MyButton(
              onTap: updateCustomerInfo,
              text: 'Cập nhật',
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
