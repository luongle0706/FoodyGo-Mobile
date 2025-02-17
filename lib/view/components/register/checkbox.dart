import 'package:flutter/material.dart';

class CheckboxIcon extends StatelessWidget {
  const CheckboxIcon({super.key, required this.value, required this.checkbox});

  final bool value;
  final Checkbox checkbox;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.3, // Make checkbox bigger
      child: Theme(
        data: ThemeData(
          checkboxTheme: CheckboxThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Rounded corners
            ),
            side: WidgetStateBorderSide.resolveWith(
              (states) => BorderSide(width: 2, color: Colors.black),
            ),
          ),
        ),
        child: checkbox
      ),
    );
  }
}
