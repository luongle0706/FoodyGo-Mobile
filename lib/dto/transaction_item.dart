// lib/dto/transaction_item.dart
import 'package:flutter/material.dart';

class TransactionItem {
  final String title;
  final String amount;
  final String date;
  final IconData icon;

  TransactionItem({
    required this.title,
    required this.amount,
    required this.date,
    required this.icon,
  });
}
