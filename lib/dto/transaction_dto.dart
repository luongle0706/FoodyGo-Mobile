// lib/dto/transaction_dto.dart
import 'package:flutter/material.dart';

class TransactionDto {
  final int id;
  final String description;
  final String? time;
  final double amount;
  final double remaining;
  final String
      type; // TransactionType as string: TOP_UP, WITHDRAWAL, PAYMENT, REFUND, TRANSFER

  TransactionDto({
    required this.id,
    required this.description,
    this.time,
    required this.amount,
    required this.remaining,
    required this.type,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: json['id'],
      description: json['description'],
      time: json['time'],
      amount: json['amount'].toDouble(),
      remaining: json['remaining'].toDouble(),
      type: json['type'],
    );
  }

  // Helper method to get appropriate icon based on transaction type
  IconData getTransactionIcon() {
    switch (type) {
      case 'TOP_UP':
        return Icons.attach_money;
      case 'WITHDRAWAL':
        return Icons.money_off;
      case 'PAYMENT':
        return Icons.payment;
      case 'REFUND':
        return Icons.replay;
      case 'TRANSFER':
        return Icons.swap_horiz;
      default:
        return Icons.receipt_long;
    }
  }

  // Helper method to format amount with sign
  String getFormattedAmount() {
    String prefix;
    if (type == 'TOP_UP' || type == 'REFUND') {
      prefix = '+ ';
    } else if (type == 'TRANSFER') {
      // For transfers, check description to determine direction
      if (description.toLowerCase().contains('received') ||
          description.toLowerCase().contains('nhận') ||
          description.toLowerCase().contains('from')) {
        prefix = '+ ';
      } else {
        prefix = '- ';
      }
    } else {
      prefix = '- ';
    }
    return '$prefix${amount.toInt()} FoodyXu';
  }
}
