import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  const ImageTile({
    super.key,
    required this.imagePath,
    required this.text,
    required this.onTap,
  });

  final String imagePath;
  final String text;
  final VoidCallback?
      onTap; // Changed Function()? to VoidCallback? (more conventional)

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
            padding: EdgeInsets.all(20),
            backgroundColor: Colors.grey[200], // Same background as before
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white), // Same border
            ),
            foregroundColor: Colors.black,
            alignment: Alignment.centerLeft),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Prevents excessive stretching
          children: [
            Image.asset(
              imagePath,
              height: 40,
            ),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}
