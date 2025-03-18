import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodygo/dto/register_dto.dart';
import 'package:foodygo/repository/auth_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/view/components/button.dart';
import 'package:foodygo/view/components/input_field_w_icon.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterInfo extends StatefulWidget {
  final int? chosenBuildingId;
  final String? chosenBuildingName;

  const RegisterInfo(
      {super.key, this.chosenBuildingId, this.chosenBuildingName});

  @override
  State<RegisterInfo> createState() => _RegisterInfoState();
}

class _RegisterInfoState extends State<RegisterInfo> {
  int? chosenBuildingId;
  String? _chosenBuildingName;
  final logger = AppLogger.instance;
  final _registerRepo = AuthRepository.instance;

  final fullNameController = TextEditingController();
  final dobController = TextEditingController();
  final mobileController = TextEditingController();
  final buildingController = TextEditingController();
  late String _email = "";
  late String _password = "";
  File? _selectedImage;

  bool isValidVietnamesePhoneNumber(String phoneNumber) {
    final RegExp regex = RegExp(r'^(03|05|07|08|09)[0-9]{8,9}$');
    return regex.hasMatch(phoneNumber);
  }

  @override
  void initState() {
    super.initState();
    chosenBuildingId = widget.chosenBuildingId;
    _chosenBuildingName = widget.chosenBuildingName;
    buildingController.text = _chosenBuildingName ?? ''; // Set initial text
    _loadAuthData();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    // Gán trực tiếp giá trị vào biến thay vì dùng setState
    _email = prefs.getString('email') ?? "";
    _password = prefs.getString('password') ?? "";
    logger.info("Email loaded: $_email");
    logger.info("Password loaded: $_password");
  }

  Future<void> _saveAuthData(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    logger.info("Saved Email: ${prefs.getString('email')}");
    logger.info("Saved Password: ${prefs.getString('password')}");
  }

  Future<void> _registerUser() async {
    final String fullName = fullNameController.text.trim();
    final String phoneNumber = mobileController.text.trim();
    final String dobString = dobController.text.trim();

    if (fullName.isEmpty || phoneNumber.isEmpty || dobString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng điền đầy đủ thông tin!")),
      );
      return;
    }

    if (!isValidVietnamesePhoneNumber(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Số điện thoại không hợp lệ!")),
      );
      return;
    }

    try {
      DateTime dob = DateFormat('dd/MM/yyyy').parse(dobString);

      RegisterRequestDTO request = RegisterRequestDTO(
          email: _email,
          password: _password,
          fullname: fullName,
          phoneNumber: phoneNumber,
          buildingID: chosenBuildingId,
          image: _selectedImage,
          dob: dob);
      RegisterResponseDTO response = await _registerRepo.register(request);
      logger.info(response.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng ký thành công!")),
      );

      GoRouter.of(context).push('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng ký thất bại: $e")),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;

    if (extra is Map<String, dynamic>) {
      if (extra.containsKey('email') && extra['email'] != null) {
        _email = extra['email'];
      }
      if (extra.containsKey('password') && extra['password'] != null) {
        _password = extra['password'];
      }

      logger.info("Email didChangeDependencies: $_email");
      logger.info("Password didChangeDependencies: $_password");

      if (_email.isNotEmpty && _password.isNotEmpty) {
        _saveAuthData(_email, _password);
        _loadAuthData();
      }
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    dobController.dispose();
    mobileController.dispose();
    buildingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),

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
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!) // Hiển thị ảnh đã chọn
                    : AssetImage('assets/icons/ellispe-icon.png')
                        as ImageProvider,
                child: _selectedImage == null
                    ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Tải ảnh đại diện',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 70),

            // Input fields
            IconTextField(
              controller: fullNameController,
              hintText: "Họ và tên",
              obscureText: false,
              iconPath: 'assets/icons/profile-icon.png',
            ),
            SizedBox(height: 20.0),
            IconTextField(
              controller: mobileController,
              hintText: "Số điện thoại",
              obscureText: false,
              iconPath: 'assets/icons/phone-icon.png',
            ),
            SizedBox(height: 20),
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

            SizedBox(height: 20.0),

            InkWell(
              onTap: () {
                GoRouter.of(context).push('/map/building',
                    extra: {'callOfOrigin': '/register-info'});
              },
              child: IgnorePointer(
                child: IconTextField(
                  controller: buildingController,
                  hintText: "Chọn tòa bạn đang ở",
                  obscureText: false,
                  iconPath: 'assets/icons/location-icon.png',
                ),
              ),
            ),
            SizedBox(height: 50),
            MyButton(
              onTap: () async {
                await _registerUser();
              },
              text: 'Đăng ký',
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
