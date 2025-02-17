import 'package:flutter/material.dart';

class TransactionItem {
  final String title;
  final String amount;
  final String dateTime;
  final IconData icon;

  TransactionItem(this.title, this.amount, this.dateTime, this.icon);
}
