import 'package:flutter/material.dart';
import 'package:foodygo/service/auth_service.dart';
import 'package:foodygo/utils/injection.dart';
import 'package:foodygo/view/components/button.dart';
import 'package:foodygo/view/components/image_tile.dart';
import 'package:foodygo/view/components/login/login_input_field.dart';
import 'package:foodygo/view/theme.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),

              // Logo
              Image.asset(
                "assets/icons/foodygo-logo.png",
                width: 150,
                height: 150,
              ),

              SizedBox(height: 50),

              // Username textfield
              LoginTextField(
                controller: usernameController,
                hintText: 'Địa chỉ Email',
                obscureText: false,
                iconPath: 'assets/icons/email-icon.png',
              ),

              SizedBox(height: 10),

              // Password textfield
              LoginTextField(
                controller: passwordController,
                hintText: 'Mật khẩu',
                obscureText: true,
                iconPath: 'assets/icons/password-icon.png',
              ),

              SizedBox(height: 10),

              // Forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              // Sign in button
              MyButton(
                onTap: () => locator.get<AuthService>().signIn(
                    usernameController.text, passwordController.text, context),
                text: 'Đăng nhập',
              ),

              SizedBox(height: 50),

              // Or continue with
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Hoặc',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              // Google + Facebook Sign in buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageTile(imagePath: 'assets/images/facebook.png', text: 'Facebook'),
                  SizedBox(width: 10),
                  ImageTile(imagePath: 'assets/images/google.png', text: 'Google'),
                ],
              ),

              SizedBox(height: 25),

              // Not a member? Register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chưa có tài khoản?',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text('Đăng ký',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ));
  }
}
