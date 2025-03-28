import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/customer_repository.dart';
import 'package:foodygo/repository/user_repository.dart';
import 'package:foodygo/service/auth_service.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  SavedUser? user;
  bool isLoading = true;
  final authService = AuthService.instance;
  final logger = AppLogger.instance;
  final storage = SecureStorage.instance;
  final customerRepo = CustomerRepository.instance;
  Map<String, dynamic>? userDetails;
  final UserRepository userRepository = UserRepository.instance;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    String? data = await storage.get(key: 'user');
    SavedUser? userData =
        data != null ? SavedUser.fromJson(json.decode(data)) : null;
    if (userData != null) {
      logger.info('Data $data');
      await fetchUserDetails(userData.userId, userData.token);
      setState(() {
        user = userData;
        isLoading = false;
      });
    } else {
      isLoading = false;
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
        AppLogger.instance.error("Failed to fetch user details");
      }
    } catch (e) {
      AppLogger.instance.error("Error fetching user details: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildWallet(BuildContext context) {
    if (user != null && !isLoading) {
      if (user?.role == 'ROLE_STAFF') {
        return Container();
      }
      return GestureDetector(
        onTap: () => GoRouter.of(context).push("/protected/wallet"),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ví Foody', style: TextStyle(fontSize: 16)),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.black54),
                ],
              ),
            ),
            Divider(),
          ],
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              GoRouter.of(context).push("/protected/user/detail").then((_) {
                loadUser();
              });
            },
            child: Padding(
              padding:
                  EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    backgroundImage: userDetails?['image'] != null &&
                            userDetails?['image'].isNotEmpty
                        ? NetworkImage(userDetails!['image'])
                        : AssetImage('assets/images/profile_pic.png')
                            as ImageProvider,
                  ),
                  SizedBox(width: 16),
                  Text('${user?.fullName}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Divider(),
          _buildWallet(context),
          _buildListTile("Địa chỉ", () {}),
          _buildListTile("Chính sách quy định", () {
            GoRouter.of(context).push("/protected/policy");
          }),
          _buildListTile("Về FoodyGo", () {
            GoRouter.of(context).push("/protected/about");
          }),
          SizedBox(height: 20),
          _buildLogoutButton(context),
          Spacer(),
          Text("Phiên bản 0.1", style: TextStyle(color: Colors.black87)),
          SizedBox(height: 4),
          Text("FoodyGo Corporation", style: TextStyle(color: Colors.black87)),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 16)),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
              ],
            ),
          ),
        ),
        Divider(),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => authService.signOut(context),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 48),
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text("Đăng Xuất",
            style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
