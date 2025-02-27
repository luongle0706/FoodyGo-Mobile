import 'package:flutter/material.dart';
import 'package:foodygo/service/auth_service.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({super.key});

  final authService = AuthService.instance;
  final logger = AppLogger.instance;

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
          _buildListTile("Foody Xu"),
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
