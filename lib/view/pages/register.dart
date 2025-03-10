import 'package:flutter/material.dart';
import 'package:foodygo/dto/OTP_dto.dart';
import 'package:foodygo/dto/register_dto.dart';
import 'package:foodygo/repository/auth_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/view/components/register/checkbox.dart';
import 'package:foodygo/view/components/register/input_text.dart';
import 'package:foodygo/view/components/register/register_button.dart';
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

  void sendOTP() async {
    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Bạn cần đồng ý với Điều khoản & Dịch vụ.")),
      );
      return;
    }
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      OTPResponseDTO otpResponseDTO =
          await AuthRepository.instance.sendOTP(email: emailController.text);
      if (otpResponseDTO.existedEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Email của bạn đã được đăng ký. Vui lòng nhập email mới")),
        );
        return;
      }
      if (mounted) {
        GoRouter.of(context).push('/otp',
            extra: {'otp': otpResponseDTO.otp, 'email': emailController.text});
      }
    } catch (e) {
      logger.info("Registration error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thất bại. Vui lòng thử lại!")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void registerUser() async {
    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Bạn cần đồng ý với Điều khoản & Dịch vụ.")),
      );
      return;
    }
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      RegisterRequestDTO requestDTO = RegisterRequestDTO(
          email: emailController.text, password: passwordController.text);

      RegisterResponseDTO responseDTO =
          await AuthRepository.instance.register(requestDTO);

      logger.info("API register from page register: ${responseDTO.toString()}");

      if (mounted) {
        GoRouter.of(context).push('/register-info');
      }
    } catch (e) {
      logger.info("Registration error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thất bại. Vui lòng thử lại!")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Hãy bắt đầu nào!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            Text(
              'Nhập thông tin của bạn để tạo tài khoản',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 20),
            ),
            const SizedBox(height: 20),
            RegisterInput(
              controller: emailController,
              hintText: "Địa chỉ email",
              icon: SizedBox(
                width: 50,
                height: 50,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Image.asset('assets/icons/emailIcon.png'),
                ),
              ),
            ),
            const SizedBox(height: 30),
            RegisterInput(
              controller: passwordController,
              hintText: "Mật khẩu",
              icon: SizedBox(
                width: 50,
                height: 50,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Image.asset('assets/icons/passwordIcon.png'),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CheckboxIcon(
                  value: acceptedTerms,
                  checkbox: Checkbox(
                    value: acceptedTerms,
                    activeColor: Colors.black,
                    onChanged: (value) {
                      setState(() {
                        acceptedTerms = value ?? false;
                      });
                    },
                  ),
                ),
                const Text("Tôi đồng ý với Điều khoản & Dịch vụ",
                    style: TextStyle(fontSize: 16)),
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
                const Text("Bạn đã có tài khoản?"),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
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
