import 'package:flutter/material.dart';
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
  int _secondRemaining = 90;
  bool _isResendDisabled = true;

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                GoRouter.of(context).go("/register");
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
                const Text(
                  "youremail@gmail.com",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {},
                  child: const Text("Đổi email xác nhận?"),
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
                    border: Border.all(color: Colors.black),
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
                        : () {
                            setState(() {
                              _secondRemaining = 90;
                              _isResendDisabled = true;
                            });
                            _startTimer();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Gửi lại",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Xác nhận",
                      style: TextStyle(color: Colors.white),
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
