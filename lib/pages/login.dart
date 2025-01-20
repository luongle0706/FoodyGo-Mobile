import 'package:flutter/material.dart';
import 'package:foodygo/api/api_service.dart';
import 'package:foodygo/components/button.dart';
import 'package:foodygo/components/image_tile.dart';
import 'package:foodygo/components/text_field.dart';
import 'package:foodygo/model/login_model.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() {
    LoginRequestModel request = LoginRequestModel(
      email: usernameController.text,
      password: passwordController.text,
    );

    ApiService apiService = ApiService();
    apiService.login(request).then((value) {
      print("HELLO");
      print(value.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),

              // Logo
              Icon(
                Icons.lock,
                size: 100,
              ),

              SizedBox(height: 50),

              // Welcome back, you've been missed!
              Text(
                'Welcome back, you\'ve been missed!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              SizedBox(height: 25),

              // Username textfield
              MyTextField(
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
              ),

              SizedBox(height: 10),

              // Password textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              SizedBox(height: 10),

              // Forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              // Sign in button
              MyButton(
                onTap: signIn,
                text: 'Sign in',
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
                        'Or continue with',
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

              // Google + Apple + Facebook Sign in buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageTile(imagePath: 'lib/images/google.png'),
                  SizedBox(width: 10),
                  ImageTile(imagePath: 'lib/images/apple.png'),
                  SizedBox(width: 10),
                  ImageTile(imagePath: 'lib/images/facebook.png'),
                ],
              ),

              SizedBox(height: 25),

              // Not a member? Register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member?',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text('Register now',
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
