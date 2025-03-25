import 'package:flutter/material.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chính Sách & Quy Định", style: TextStyle(color: Colors.white),),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            GoRouter.of(context).pop(); 
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chính Sách & Quy Định của FoodyGo",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "1. Giới thiệu\n"
                "   FoodyGo cam kết mang đến trải nghiệm đặt món ăn nhanh chóng, tiện lợi và đảm bảo chất lượng cho khách hàng.\n\n"
                "2. Quyền & Trách Nhiệm Người Dùng\n"
                "   - Cung cấp thông tin chính xác khi đăng ký tài khoản.\n"
                "   - Không sử dụng dịch vụ để thực hiện các hành vi gian lận hoặc gây ảnh hưởng tiêu cực.\n\n"
                "3. Chính Sách Đặt Hàng & Hủy Đơn\n"
                "   - Đơn hàng đã xác nhận không thể hủy, trừ trường hợp cửa hàng không thể đáp ứng.\n"
                "   - Người dùng có thể liên hệ FoodyGo để hỗ trợ các vấn đề liên quan đến đơn hàng.\n\n"
                "4. Bảo Mật & Quyền Riêng Tư\n"
                "   - Thông tin cá nhân của người dùng được bảo mật và chỉ sử dụng để cung cấp dịch vụ.\n"
                "   - Không chia sẻ thông tin cá nhân của khách hàng với bên thứ ba nếu không có sự đồng ý.\n\n"
                "5. Liên Hệ & Hỗ Trợ\n"
                "   Nếu có bất kỳ thắc mắc nào, vui lòng liên hệ FoodyGo qua email: support@foodygo.com hoặc hotline: 1900-xxxxxx.\n",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                  child: Text("Quay lại"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
