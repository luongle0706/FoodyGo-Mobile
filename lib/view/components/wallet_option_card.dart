import 'package:flutter/material.dart';

class WalletOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Function() onTap;

  const WalletOptionCard(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.black54),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
