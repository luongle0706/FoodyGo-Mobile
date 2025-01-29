import 'package:flutter/material.dart';
import 'package:foodygo/view/components/shadow_input_field.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: Color(0xFF40A44E)),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.keyboard_backspace,
                        size: 30,
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Sign up',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Welcome please create your account using email address',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  Text('Full name',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  ShadowInputField(
                      inputController: fullNameController,
                      hintText: 'Full name'),
                  SizedBox(height: 20),
                  Text('Email address',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  ShadowInputField(
                      inputController: emailController,
                      hintText: 'Email address'),
                  SizedBox(height: 20),
                  Text('Mobile number',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  ShadowInputField(
                      inputController: mobileController,
                      hintText: 'Mobile number'),
                  SizedBox(height: 20),
                  Text('Password',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  ShadowInputField(
                      inputController: passwordController,
                      hintText: 'Password'),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
