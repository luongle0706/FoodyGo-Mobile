import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String transactionTitle;
  final String transactionAmount;
  final String transactionStatus;
  final String transactionId;
  final String transactionDateTime;
  final String currentBalance;

  TransactionDetailScreen({
    required this.transactionTitle,
    required this.transactionAmount,
    required this.transactionStatus,
    required this.transactionId,
    required this.transactionDateTime,
    required this.currentBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết giao dịch"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(transactionTitle,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(transactionAmount,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: transactionAmount.startsWith("-")
                              ? Colors.red
                              : Colors.green)),
                  SizedBox(height: 8),
                  Text(transactionStatus,
                      style: TextStyle(fontSize: 14, color: Colors.green)),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow("Mã giao dịch", transactionId),
                  _buildDetailRow("Thời gian giao dịch", transactionDateTime),
                  _buildDetailRow("Số dư còn lại", currentBalance),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }
}
