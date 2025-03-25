import 'package:flutter/material.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class AboutFoodyGoPage extends StatelessWidget {
  const AboutFoodyGoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Về FoodyGo", style: TextStyle(color: Colors.white),),
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
                "Giới Thiệu Về FoodyGo",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "FoodyGo là nền tảng đặt đồ ăn trực tuyến, giúp kết nối thực khách với các nhà hàng, quán ăn một cách nhanh chóng và tiện lợi.\n\n"
                "🚀 Sứ mệnh của chúng tôi:\n"
                "   - Cung cấp dịch vụ giao đồ ăn nhanh chóng, tiện lợi.\n"
                "   - Đảm bảo chất lượng món ăn từ các nhà hàng đối tác.\n"
                "   - Mang lại trải nghiệm tốt nhất cho khách hàng.\n\n"
                "🌏 Hoạt động của FoodyGo:\n"
                "   - Hỗ trợ nhiều phương thức thanh toán linh hoạt.\n"
                "   - Hợp tác với hàng trăm nhà hàng lớn nhỏ trên toàn quốc.\n"
                "   - Cung cấp tính năng theo dõi đơn hàng theo thời gian thực.\n\n"
                "📞 Liên hệ với chúng tôi:\n"
                "   - Email: support@foodygo.com\n"
                "   - Hotline: 1900-xxxxxx\n"
                "   - Website: www.foodygo.com\n",
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
