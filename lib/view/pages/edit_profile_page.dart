import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/customer_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  final String fieldKey;
  final String fieldValue;
  final String fieldTitle;
  final Map<String, dynamic> userDetails;

  const EditProfilePage({
    super.key,
    required this.fieldKey,
    required this.fieldValue,
    required this.fieldTitle,
    required this.userDetails,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  SavedUser? user;
  late TextEditingController _controller;
  DateTime? selectedDate;
  final CustomerRepository customerRepository = CustomerRepository.instance;
  bool isLoading = false;
  final _logger = AppLogger.instance;
  File? selectedImage;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.fieldValue);

    if (widget.fieldKey == 'dob' && widget.fieldValue.isNotEmpty) {
      try {
        selectedDate = DateTime.parse(widget.fieldValue);

        _controller.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
      } catch (e) {
        _logger.error("Lỗi parse ngày sinh: $e");
      }
    }
    initUser();
  }

  void initUser() async {
    try {
      String? userString = await SecureStorage.instance.get(key: 'user');
      if (userString != null) {
        SavedUser savedUser = SavedUser.fromJson(json.decode(userString));
        setState(() {
          user = savedUser;
        });
      } else {
        _logger.error("User not found in storage");
      }
    } catch (e) {
      _logger.error("Error initializing profile: $e");
    }
  }

  Future<void> updateCustomerInfo() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không tìm thấy thông tin người dùng!")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String accessToken = user!.token;
      int userId = user!.userId;

      DateTime? dobToUpdate;
      if (widget.fieldKey == 'dob' && selectedDate != null) {
        dobToUpdate = selectedDate;
      } else if (widget.userDetails["dob"] is DateTime) {
        dobToUpdate = widget.userDetails["dob"];
      } else if (widget.userDetails["dob"] is String) {
        dobToUpdate = DateTime.tryParse(widget.userDetails["dob"]);
      }

      bool result = await customerRepository.updateCustomer(
        userId: userId,
        accessToken: accessToken,
        buildingId: widget.userDetails["buildingID"] as int,
        dob: dobToUpdate,
        phone: widget.fieldKey == 'phone'
            ? _controller.text
            : widget.userDetails["phone"],
        image: null,
      );

      if (result) {
        Navigator.of(context).pop(_controller.text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cập nhật thông tin thất bại!")),
        );
      }
    } catch (e) {
      _logger.error("Lỗi cập nhật thông tin: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        // Use the format expected by your backend
        _controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chỉnh sửa ${widget.fieldTitle}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            widget.fieldKey == 'dob'
                ? TextField(
                    controller: _controller,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      labelText: widget.fieldTitle,
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  )
                : TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: widget.fieldTitle),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : updateCustomerInfo,
              child: isLoading ? CircularProgressIndicator() : Text("Lưu"),
            ),
          ],
        ),
      ),
    );
  }
}
