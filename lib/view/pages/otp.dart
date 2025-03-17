import 'package:flutter/material.dart';
import 'package:foodygo/dto/OTP_dto.dart';
import 'package:foodygo/repository/auth_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isButtonEnabled = false;
  int _secondRemaining = 10;
  bool _isResendDisabled = true;
  late String otp;
  late String email;
  late String password;
  bool _isInitialized = false;
  final logger = AppLogger.instance;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_secondRemaining > 0) {
            _secondRemaining--;
            _startTimer();
          } else {
            _isResendDisabled = false;
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      otp = extra?['otp'] ?? "Không có otp";
      email = extra?['email'] ?? "Không có email";
      password = extra?['password'] ?? "Không có password";
      _isInitialized = true;
      logger.info("Email otp: $email");
      logger.info("Password otp: $password");
    }
  }

  @override
  Widget build(BuildContext context) {
    final logger = AppLogger.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                GoRouter.of(context).pop();
              },
              child: Icon(Icons.arrow_back),
            ),
            const SizedBox(height: 20),
            const Text(
              "Nhập mã xác nhận",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Chúng tôi đã gửi mã xác nhận đến",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  email,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Đổi email xác nhận?",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Pinput(
                length: 4,
                controller: _otpController,
                onChanged: (value) {
                  setState(() {
                    _isButtonEnabled = value.length == 4;
                  });
                },
                defaultPinTheme: PinTheme(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Gửi lại mã xác nhận sau ${_secondRemaining ~/ 60}:${(_secondRemaining % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isResendDisabled
                        ? null
                        : () async {
                            OTPResponseDTO otpResponseDTO = await AuthRepository
                                .instance
                                .sendOTP(email: email);
                            if (otpResponseDTO.existedEmail) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Email của bạn đã được đăng ký. Vui lòng nhập email mới")),
                              );
                              return;
                            }
                            otp = otpResponseDTO.otp;
                            logger.info("OTP after resend: $otp");
                            setState(() {
                              _secondRemaining = 10;
                              _isResendDisabled = true;
                            });
                            _startTimer();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Gửi lại",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled
                        ? () {
                            logger.info("xacsnhan otp: $otp");
                            if (_otpController.text == otp) {
                              GoRouter.of(context).push('/register-info',
                                  extra: {
                                    'email': email,
                                    'password': password
                                  });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("OTP không hợp lệ!")),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Xác nhận",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
