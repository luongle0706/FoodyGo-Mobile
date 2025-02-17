import 'package:flutter/material.dart';

class RegisterInput extends StatelessWidget {
  const RegisterInput(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.icon, this.obscureText});

  final TextEditingController controller;
  final String hintText;
  final Widget icon;
  final bool? obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField( 
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade300,
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black, // Black text
        ),
        prefixIcon: icon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      obscureText: obscureText ?? false,
    );
  }
}
