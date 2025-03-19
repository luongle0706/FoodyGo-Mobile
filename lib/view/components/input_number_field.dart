import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool expand;

  const InputNumberField({
    super.key, 
    required this.label, 
    required this.controller,
    required this.hintText,
    required this.expand});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(minHeight: 50),
          child: TextField(
            controller: controller,
            maxLines: expand ? null : 1,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(),
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
      ],
    );
  }
}