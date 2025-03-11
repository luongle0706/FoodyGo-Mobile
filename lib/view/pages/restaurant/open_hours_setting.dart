import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/operating_hour_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/operating_hour_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class OpenHoursSetting extends StatefulWidget {
  final int restaurantId;
  const OpenHoursSetting({super.key, required this.restaurantId});

  @override
  State<OpenHoursSetting> createState() => _OpenHoursSettingState();
}

class _OpenHoursSettingState extends State<OpenHoursSetting> {
  final _storage = SecureStorage.instance;

  final AppLogger _logger = AppLogger.instance;

  final OperatingHourRepository _operatingHourRepository =
      OperatingHourRepository.instance;

  SavedUser? _user;

  bool _isLoading = true;

  List<OperatingHourDTO>? _operatingHourList;

  final Map<int, bool> isOpen = {};

  final Map<int, bool> is24Hours = {};

  final Map<int, TimeOfDay> openTime = {};

  final Map<int, TimeOfDay> closeTime = {};

  bool currentState = true;
  // true = Mở cửa, false = Đóng cửa
  @override
  void initState() {
    super.initState();
    for (int i = 1; i <= 7; i++) {
      // Khởi tạo từ Thứ Hai (1) đến Chủ Nhật (7)
      isOpen[i] = true;
      is24Hours[i] = true;
      openTime[i] = const TimeOfDay(hour: 0, minute: 0);
      closeTime[i] = const TimeOfDay(hour: 0, minute: 0);
    }
    _updateCurrentState();
    loadUser();
  }

  Future<bool> fetchOperatingHour(String accessToken) async {
    List<OperatingHourDTO>? fetchData = await _operatingHourRepository
        .loadOperatingHoursByRestaurantId(accessToken, widget.restaurantId);
    if (fetchData != null) {
      setState(() {
        _operatingHourList = fetchData;
        for (var item in fetchData) {
          int dayIndex = _convertDayToIndex(item.day);
          isOpen[dayIndex] = item.open;
          is24Hours[dayIndex] = item.hours;
          openTime[dayIndex] = _parseTime(item.openingTime);
          closeTime[dayIndex] = _parseTime(item.closingTime);
        }
      });
      return true;
    }
    return false;
  }

  int _convertDayToIndex(String day) {
    Map<String, int> days = {
      "Thứ 2": 1,
      "Thứ 3": 2,
      "Thứ 4": 3,
      "Thứ 5": 4,
      "Thứ 6": 5,
      "Thứ 7": 6,
      "Chủ Nhật": 7,
    };
    return days[day] ?? 1;
  }

  TimeOfDay _parseTime(String time) {
    List<String> parts = time.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> loadUser() async {
    String? userData = await _storage.get(key: 'user');
    SavedUser? user =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
    if (user != null) {
      setState(() {
        _user = user;
      });
      bool fetchData = await fetchOperatingHour(user.token);

      if (fetchData) {
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

  Future<void> _pickTime(int day, bool isOpening) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpening ? openTime[day]! : closeTime[day]!,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary, // Màu chính (nút xác nhận)
              onPrimary: Colors.white, // Màu chữ trên nút chính
              onSurface: Colors.black, // Màu chữ trên nền picker
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Màu của nút "Hủy" và "OK"
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          openTime[day] = picked;
        } else {
          closeTime[day] = picked;
        }
      });
    }
  }

  void _updateCurrentState() {
    DateTime now = DateTime.now();
    int currentDay = now.weekday; // Giữ nguyên 1 = Thứ Hai, 7 = Chủ Nhật
    TimeOfDay nowTime = TimeOfDay(hour: now.hour, minute: now.minute);

    if (isOpen[currentDay] == true) {
      if (is24Hours[currentDay] == true ||
          (nowTime.hour >= openTime[currentDay]!.hour &&
              nowTime.hour <= closeTime[currentDay]!.hour)) {
        currentState = true; // Đang mở cửa
      } else {
        currentState = false; // Đóng cửa
      }
    } else {
      currentState = false; // Đóng cửa
    }
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _saveOperatingHours() async {
    String accessToken = _user!.token;

    // Chuyển đổi dữ liệu thành JSON
    List<Map<String, dynamic>> operatingHourList =
        _operatingHourList!.map((item) {
      int dayIndex = _convertDayToIndex(item.day);
      return {
        "id": item.id,
        "open": isOpen[dayIndex] ?? false,
        "hours": is24Hours[dayIndex] ?? false,
        "openingTime": _formatTime(openTime[dayIndex]!),
        "closingTime": _formatTime(closeTime[dayIndex]!),
      };
    }).toList();

    // Body JSON cần gửi
    Map<String, dynamic> body = {"operatingHourList": operatingHourList};

    try {
      final response = await http.put(
        Uri.parse('$globalURL/api/v1/operating-hours'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cập nhật thành công!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi cập nhật: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    _updateCurrentState();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: const Text(
          "Trạng thái hoạt động",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text(
                    "Cơm tấm Ngô Quyền",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "● ${currentState ? "Mở cửa" : "Đóng cửa"}",
                    style: TextStyle(
                      color: currentState ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Giờ mở cửa: 7:00 - 23:00",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Danh sách ngày trong tuần
            Expanded(
              child: ListView.builder(
                itemCount: _operatingHourList?.length ?? 0,
                itemBuilder: (context, index) {
                  final item = _operatingHourList![index];
                  int day = _convertDayToIndex(item.day); // Chuyển "Monday" → 1

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.day,
                                  style: const TextStyle(fontSize: 16)),
                              Switch(
                                value: isOpen[day]!,
                                activeColor: Colors.green[600],
                                onChanged: (value) {
                                  setState(() {
                                    isOpen[day] = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: is24Hours[day],
                                activeColor: AppColors.primary,
                                onChanged: (value) {
                                  setState(() {
                                    is24Hours[day] = value!;
                                    if (value) {
                                      openTime[day] =
                                          const TimeOfDay(hour: 0, minute: 0);
                                      closeTime[day] =
                                          const TimeOfDay(hour: 0, minute: 0);
                                    }
                                  });
                                },
                              ),
                              const Text("24 giờ"),
                            ],
                          ),
                          if (!is24Hours[day]!)
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Mở cửa:"),
                                    TextButton(
                                      onPressed: () => _pickTime(day, true),
                                      child: Text(
                                        "${openTime[day]!.hour.toString().padLeft(2, '0')}:${openTime[day]!.minute.toString().padLeft(2, '0')}",
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Đóng cửa:"),
                                    TextButton(
                                      onPressed: () => _pickTime(day, false),
                                      child: Text(
                                        "${closeTime[day]!.hour.toString().padLeft(2, '0')}:${closeTime[day]!.minute.toString().padLeft(2, '0')}",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _saveOperatingHours();
                  });
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
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
