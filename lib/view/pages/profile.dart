import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/service/auth_service.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
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

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    String? data = await storage.get(key: 'user');
    if (data != null) {
      logger.info('Data $data');
      setState(() {
        user = SavedUser.fromJson(json.decode(data));
        isLoading = false;
      });
    } else {
      isLoading = false;
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
              GoRouter.of(context).push("/protected/user/detail");
            },
            child: Padding(
              padding:
                  EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.person, color: Colors.black54),
                  ),
                  SizedBox(width: 16),
                  Text("Anh Nguyen",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Divider(),
          _buildWallet(context),
          _buildListTile("Địa chỉ"),
          _buildListTile("Chính sách quy định"),
          _buildListTile("Về FoodyGo"),
          SizedBox(height: 20),
          _buildLogoutButton(context),
          Spacer(),
          Text("Phiên bản 0.1", style: TextStyle(color: Colors.black54)),
          SizedBox(height: 4),
          Text("FoodyGo Corporation", style: TextStyle(color: Colors.black54)),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildListTile(String title) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 16)),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
            ],
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
          backgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text("Đăng Xuất",
            style: TextStyle(fontSize: 16, color: Colors.black)),
      ),
    );
  }
}
