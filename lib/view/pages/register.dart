import 'package:flutter/material.dart';
import 'package:foodygo/dto/OTP_dto.dart';
import 'package:foodygo/repository/auth_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/view/components/register/input_text.dart';
import 'package:foodygo/view/components/register/register_button.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final logger = AppLogger.instance;

  bool acceptedTerms = false;
  bool isLoading = false;
  bool isValidEmail(String email) {
    final RegExp regex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(email);
  }

  void sendOTP() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    logger.info("🔍 Gửi OTP cho email: $email");

    setState(() => isLoading = true); // Bật trạng thái xử lý

    try {
      logger.info("📡 Đang gọi API sendOTP...");

      OTPResponseDTO otpResponseDTO =
          await AuthRepository.instance.sendOTP(email: email);

      logger.info("✅ API trả về kết quả: ${otpResponseDTO.otp}");

      if (otpResponseDTO.existedEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Email đã được đăng ký. Vui lòng nhập email khác.")),
        );
        return;
      }

      if (mounted) {
        GoRouter.of(context).push('/otp', extra: {
          'otp': otpResponseDTO.otp,
          'email': email,
          'password': password
        });
      }
    } catch (e) {
      logger.info("❌ Lỗi khi gửi OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false); // Đảm bảo trạng thái được cập nhật
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background, // ShopeeFood cam chủ đạo
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Hãy bắt đầu nào!',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.black),
            ),
            Text(
              'Nhập thông tin của bạn để tạo tài khoản',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            const SizedBox(height: 20),
            RegisterInput(
              controller: emailController,
              hintText: "Địa chỉ email",
              icon: Icon(Icons.email),
              obscureText: false,
            ),
            const SizedBox(height: 30),
            RegisterInput(
              controller: passwordController,
              hintText: "Mật khẩu",
              icon: Icon(Icons.lock),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: acceptedTerms,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() {
                      acceptedTerms = value ?? false;
                    });
                  },
                ),
                const Text("Tôi đồng ý với Điều khoản & Dịch vụ",
                    style: TextStyle(fontSize: 16, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 20),
            RegisterButton(
              text: isLoading ? "Đang xử lý..." : "Tiếp tục",
              onTap: isLoading ? () {} : sendOTP,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Bạn đã có tài khoản?",
                    style: TextStyle(color: Colors.black)),
                TextButton(
                  onPressed: () {
                    GoRouter.of(context).go('/login');
                  },
                  child: const Text(
                    " Đăng nhập",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
