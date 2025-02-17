import 'package:flutter/material.dart';

class IconTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String iconPath;

  const IconTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: SizedBox(
            height: 2,
            width: 2,
            child: Padding(padding: EdgeInsets.all(10), 
            child: Image.asset(
            iconPath,
            ),
            )
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
        ),
        obscureText: obscureText,
      ),
    );
  }
}
