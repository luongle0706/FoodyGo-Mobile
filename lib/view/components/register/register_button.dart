import 'package:flutter/material.dart';
import 'package:foodygo/view/theme.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key, required this.text, required this.onTap});

  final String text;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.primary, // Background color
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.text, width: 2), // Black border
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Text color
            ),
          ),
        ),
      ),
    );
  }
}
