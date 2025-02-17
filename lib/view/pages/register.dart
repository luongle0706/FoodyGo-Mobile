import 'package:flutter/material.dart';
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
  final fullNameController = TextEditingController();

  final emailController = TextEditingController();

  final mobileController = TextEditingController();

  final passwordController = TextEditingController();

  bool? acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Hãy bắt đầu nào!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            Text(
              'Nhập thông tin của bạn để tạo tài khoản',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 20),
            ),
            SizedBox(height: 20),
            RegisterInput(
                controller: emailController,
                hintText: "Địa chỉ email",
                icon: SizedBox(
                  width: 50,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Image.asset(
                      'assets/icons/emailIcon.png',
                    ),
                  ),
                )),
            SizedBox(height: 30),
            RegisterInput(
                controller: passwordController,
                hintText: "Mật khẩu",
                icon: SizedBox(
                  width: 50,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Image.asset(
                      'assets/icons/passwordIcon.png',
                    ),
                  ),
                )),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CheckboxIcon(
                  value: acceptedTerms ?? false,
                  checkbox: Checkbox(
                    value: acceptedTerms,
                    activeColor: Colors.black,
                    onChanged: (value) {
                      setState(() {
                        acceptedTerms = value;
                      });
                    },
                  ),
                ),
                Text("Tôi đồng ý với Điều khoản & Dịch vụ", style: TextStyle(
                  fontSize: 17
                ),)
              ],
            ),
            SizedBox(height: 20),
            RegisterButton(
              text: "Tiếp tục",
              onTap: () {},
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Bạn đã có tài khoản?"),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // Remove default padding
                    minimumSize:
                        Size(0, 0), // Ensure it doesn't reserve extra space
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap, // Reduce tap area
                  ),
                  onPressed: () {
                    GoRouter.of(context).go('/login');
                  },
                  child: Text(
                    " Đăng nhập",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
