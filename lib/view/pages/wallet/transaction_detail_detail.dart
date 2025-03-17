import 'package:flutter/material.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String transactionTitle;
  final String transactionAmount;
  final String transactionStatus;
  final String transactionId;
  final String transactionDateTime;
  final String currentBalance;

  const TransactionDetailScreen({
    super.key,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Chi tiết giao dịch",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.secondary.withOpacity(0.5), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    transactionTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    transactionAmount,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: transactionAmount.startsWith("+")
                          ? Colors.green[700]
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      transactionStatus,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.secondary.withOpacity(0.5), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow("Mã giao dịch", transactionId),
                  const Divider(height: 16, color: Color(0xFFEEEEEE)),
                  _buildDetailRow("Thời gian giao dịch", transactionDateTime),
                  const Divider(height: 16, color: Color(0xFFEEEEEE)),
                  _buildDetailRow("Số dư còn lại", currentBalance,
                      isHighlighted: true),
                ],
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => GoRouter.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.primary, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Quay lại",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? AppColors.text : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
