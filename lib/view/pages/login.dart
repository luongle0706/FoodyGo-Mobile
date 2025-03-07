import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/service/auth_service.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/components/image_tile.dart';
import 'package:foodygo/view/components/input_field_w_icon.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService.instance;
  final logger = AppLogger.instance;
  final storage = SecureStorage.instance;

  String? _errorMessage;

  void _handleLoginError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAPI();
  }

  Future<void> fetchAPI() async {
    String? data = await storage.get(key: 'user');
    SavedUser? user =
        data != null ? SavedUser.fromJson(json.decode(data)) : null;
    if (user != null) {
      if (user.role == 'ROLE_SELLER') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          GoRouter.of(context).go('/protected/restaurant-home');
        });
      } else if (user.role == 'ROLE_USER') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          GoRouter.of(context).go('/protected/home');
        });
      } else if (user.role == 'ROLE_STAFF') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          GoRouter.of(context).go('/protected/staff-home');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30),

              // Logo
              Image.asset(
                "assets/icons/foodygo-logo.png",
                width: 150,
                height: 150,
              ),

              Text(
                "FoodyGo",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),

              Text(
                "Ăn gì chưa người đẹp?",
                style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary),
              ),

              SizedBox(height: 50),

              // Username textfield
              IconTextField(
                controller: usernameController,
                hintText: 'Địa chỉ Email',
                obscureText: false,
                iconPath: 'assets/icons/email-icon.png',
              ),

              SizedBox(height: 10),

              // Password textfield
              IconTextField(
                controller: passwordController,
                hintText: 'Mật khẩu',
                obscureText: true,
                iconPath: 'assets/icons/password-icon.png',
              ),

              SizedBox(height: 10),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
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

              GestureDetector(
                onTap: () async {
                  setState(() {
                    _errorMessage = null;
                  });
                  authService.signIn(
                    usernameController.text,
                    passwordController.text,
                    context,
                    _handleLoginError,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Đăng nhập',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
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
                  ImageTile(
                    imagePath: 'assets/images/facebook.png',
                    text: 'Facebook',
                    onTap: () {},
                  ),
                  SizedBox(width: 10),
                  ImageTile(
                    imagePath: 'assets/images/google.png',
                    text: 'Google',
                    onTap: () => authService.signInWithGoogle(context),
                  ),
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
                  TextButton(
                    onPressed: () {
                      GoRouter.of(context).go('/register');
                    },
                    child: Text('Đăng ký',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
