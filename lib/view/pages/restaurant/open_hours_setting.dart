import 'package:flutter/material.dart';
import 'package:foodygo/view/theme.dart';

class OpenHoursSetting extends StatefulWidget {
  const OpenHoursSetting({super.key});

  @override
  _OpenHoursSettingState createState() => _OpenHoursSettingState();
}

class _OpenHoursSettingState extends State<OpenHoursSetting> {
  final Map<int, bool> isOpen = {};
  final Map<int, bool> is24Hours = {};
  final Map<int, TimeOfDay> openTime = {};
  final Map<int, TimeOfDay> closeTime = {};
  bool currentState = true; // true = Mở cửa, false = Đóng cửa

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

  @override
  Widget build(BuildContext context) {
    _updateCurrentState();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Trạng thái hoạt động",
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
                itemCount: 7, // Hiển thị đủ 7 ngày trong tuần
                itemBuilder: (context, index) {
                  int day =
                      index + 1; // Lấy ngày từ 1 (Thứ Hai) đến 7 (Chủ Nhật)
                  String dayName = [
                    "Thứ Hai",
                    "Thứ Ba",
                    "Thứ Tư",
                    "Thứ Năm",
                    "Thứ Sáu",
                    "Thứ Bảy",
                    "Chủ Nhật"
                  ][index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dayName,
                                  style: const TextStyle(fontSize: 16)),
                              Switch(
                                value: isOpen[day] ??
                                    false,
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
                    _updateCurrentState();
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
