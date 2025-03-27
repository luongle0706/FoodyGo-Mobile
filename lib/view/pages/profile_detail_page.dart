import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/user_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';

class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage({super.key});

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  SavedUser? user;
  final UserRepository userRepository = UserRepository.instance;
  final _logger = AppLogger.instance;
  Map<String, dynamic>? userDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    try {
      String? userString = await SecureStorage.instance.get(key: 'user');
      if (userString != null) {
        SavedUser savedUser = SavedUser.fromJson(json.decode(userString));
        setState(() {
          user = savedUser;
        });

        await fetchUserDetails(savedUser.userId, savedUser.token);
      } else {
        _logger.error("User not found in storage");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      _logger.error("Error initializing profile: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserDetails(int userId, String accessToken) async {
    try {
      final data = await userRepository.getUserById(userId, accessToken);
      if (data != null) {
        setState(() {
          userDetails = data;
        });
      } else {
        _logger.error("Failed to fetch user details");
      }
    } catch (e) {
      _logger.error("Error fetching user details: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToEditProfile(
      String title, String fieldKey, String fieldValue) {
    GoRouter.of(context).push('/edit-profile', extra: {
      'fieldKey': fieldKey,
      'fieldValue': fieldValue,
      'fieldTitle': title,
      'userDetails': userDetails,
    }).then((updatedValue) {
      if (updatedValue != null) {
        setState(() {
          userDetails![fieldKey] = updatedValue;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: Text("Thông tin người dùng"),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: userDetails?['image'] != null &&
                                userDetails?['image'].isNotEmpty
                            ? NetworkImage(userDetails!['image'])
                            : null,
                        child: userDetails?['image'] == null ||
                                userDetails?['image'].isEmpty
                            ? Icon(Icons.person,
                                color: Colors.black54, size: 40)
                            : null,
                      ),
                      SizedBox(width: 16),
                      Expanded(child: Text("Đổi hình đại diện")),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
                Divider(),
                _buildRow("Số điện thoại", "phone",
                    userDetails?['phone'] ?? "Chưa có",
                    withArrow: true),
                _buildRow(
                    "Tên", "fullName", userDetails?['fullName'] ?? "Chưa có",
                    withArrow: true),
                _buildRow("Email", "email", userDetails?['email'] ?? "Chưa có",
                    withArrow: true),
                _buildRow("Ngày sinh", "dob", userDetails?['dob'] ?? "Chưa có",
                    withArrow: true),
                _buildRow("Tòa", "buildingName",
                    userDetails?['buildingName'] ?? "Chưa có",
                    withArrow: true),
              ],
            ),
    );
  }

  Widget _buildRow(String title, String key, String value,
      {bool withArrow = false}) {
    return InkWell(
      onTap: withArrow ? () => _navigateToEditProfile(title, key, value) : null,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title)),
                Text(value, style: TextStyle(color: Colors.black54)),
                if (withArrow) Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
