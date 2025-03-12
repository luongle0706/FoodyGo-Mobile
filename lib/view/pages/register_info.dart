import 'package:flutter/material.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/view/components/button.dart';
import 'package:foodygo/view/components/date_picker_field.dart';
import 'package:foodygo/view/components/input_field_w_icon.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

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

  final fullNameController = TextEditingController();
  final dobController = TextEditingController();
  final mobileController = TextEditingController();
  final buildingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    chosenBuildingId = widget.chosenBuildingId;
    _chosenBuildingName = widget.chosenBuildingName;
    buildingController.text = _chosenBuildingName ?? ''; // Set initial text
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      chosenBuildingId = widget.chosenBuildingId;
      _chosenBuildingName = widget.chosenBuildingName;
      buildingController.text = _chosenBuildingName ?? ''; // Update UI
    });
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

            // Profile image
            SizedBox(
              height: 120,
              child: Image.asset('assets/icons/ellispe-icon.png'),
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
              obscureText: true,
              iconPath: 'assets/icons/profile-icon.png',
            ),
            SizedBox(height: 20),
            DatePickerField(
              controller: dobController,
              hintText: "Ngày sinh",
              iconPath: 'assets/icons/calendar-icon.png',
            ),
            SizedBox(height: 20.0),
            IconTextField(
              controller: mobileController,
              hintText: "Số điện thoại",
              obscureText: true,
              iconPath: 'assets/icons/phone-icon.png',
            ),
            SizedBox(height: 20),
            IconTextField(
              controller: buildingController,
              hintText: "Chọn tòa bạn đang ở",
              obscureText: false,
              iconPath: 'assets/icons/location-icon.png',
            ),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/map/building',
                    extra: {'callOfOrigin': '/register-info'});
              },
              child: Text('Chọn tòa'),
            ),

            SizedBox(height: 50),
            MyButton(
              onTap: () => {GoRouter.of(context).push('/otp')},
              text: 'Đăng ký',
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
