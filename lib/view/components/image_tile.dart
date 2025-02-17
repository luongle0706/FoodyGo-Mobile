import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  const ImageTile({super.key, required this.imagePath, required this.text});

  final String imagePath;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200]),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            height: 40,
          ),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16
            ),
          )
        ],
      ),
    );
  }
}
