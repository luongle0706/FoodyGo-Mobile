import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({super.key});

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
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, color: Colors.black54),
                ),
                SizedBox(width: 16),
                Expanded(child: Text("Đổi hình đại diện")),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
          Divider(),
          _buildRow("Tên đăng nhập", "theanhdeptrai69"),
          _buildRow("Số điện thoại", "**********420", withArrow: true),
          _buildRow("Tên", "Anh Nguyen The", withArrow: true),
          _buildRow("Email", "theanhdeptrai...", withArrow: true),
          _buildRow("Giới tính", "Nam", withArrow: true),
          _buildRow("Ngày sinh", "08/04/2004"),
          _buildRow("Nghề nghiệp", "Người Lao", withArrow: true),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value, {bool withArrow = false}) {
    return Column(
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
    );
  }
}
