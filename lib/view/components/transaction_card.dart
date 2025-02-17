import 'package:flutter/material.dart';
import 'package:foodygo/dto/transaction_item.dart';

class TransactionCard extends StatelessWidget {
  final TransactionItem transaction;

  const TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(transaction.icon, size: 32, color: Colors.black54),
        title: Text(transaction.title,
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.amount,
                style: TextStyle(
                    color: transaction.amount.startsWith("-")
                        ? Colors.red
                        : Colors.green)),
            Text(transaction.dateTime,
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
