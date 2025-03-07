import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodygo/dto/transaction_dto.dart';
import 'package:foodygo/dto/transaction_item.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/wallet_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/components/transaction_card.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({Key? key}) : super(key: key);

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  List<TransactionItem> transactionItems = [];
  List<TransactionDto> rawTransactions = []; // Store the raw transaction data
  bool isLoading = true;
  final walletRepository = WalletRepository.instance;
  final AppLogger logger = AppLogger.instance;
  final storage = SecureStorage.instance;

  @override
  void initState() {
    super.initState();
    loadPaymentHistory();
  }

  Future<void> loadPaymentHistory() async {
    try {
      String? data = await storage.get(key: 'user');
      SavedUser? savedUser =
          data != null ? SavedUser.fromJson(json.decode(data)) : null;

      if (savedUser != null) {
        List<TransactionDto>? payments =
            await walletRepository.getPaymentHistory(savedUser);

        if (payments != null) {
          // Store raw transactions
          rawTransactions = payments;

          // Convert TransactionDto to TransactionItem
          final items = payments.map((transaction) {
            // Format the date if available
            String formattedDate;
            if (transaction.time != null) {
              try {
                // Parse the ISO 8601 date format from the API
                DateTime dateTime = DateTime.parse(transaction.time!);
                formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
              } catch (e) {
                // Fallback if parsing fails
                formattedDate = transaction.time!;
              }
            } else {
              formattedDate =
                  DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
            }

            return TransactionItem(
              title: 'Thanh toán đơn hàng',
              amount: transaction.getFormattedAmount(),
              date: formattedDate,
              icon: Icons.payment,
            );
          }).toList();

          setState(() {
            transactionItems = items;
            isLoading = false;
          });
        } else {
          // If API call fails, use sample data for demonstration
          _loadSampleData();
        }
      } else {
        logger.error("User not found in secure storage");
        _loadSampleData();
      }
    } catch (e) {
      logger.error("Error loading payments: $e");
      _loadSampleData();
    }
  }

  // Fallback to sample data if API call fails
  void _loadSampleData() {
    setState(() {
      transactionItems = [
        TransactionItem(
          title: "Thanh toán đơn hàng",
          amount: "- 50 FoodyXu",
          date: "04/12/2023 11:32",
          icon: Icons.payment,
        ),
        TransactionItem(
          title: "Thanh toán đơn hàng",
          amount: "- 75 FoodyXu",
          date: "03/12/2023 09:15",
          icon: Icons.payment,
        ),
        TransactionItem(
          title: "Thanh toán đơn hàng",
          amount: "- 120 FoodyXu",
          date: "01/12/2023 14:45",
          icon: Icons.payment,
        ),
      ];
      isLoading = false;
    });
  }

  void _navigateToTransactionDetail(int index) {
    if (rawTransactions.isNotEmpty && index < rawTransactions.length) {
      // We have real transactions data
      TransactionDto transaction = rawTransactions[index];

      // Format amount with sign for display
      String formattedAmount = transaction.getFormattedAmount();

      // Format date for display
      String formattedDate = transaction.time != null
          ? DateFormat('dd/MM/yyyy HH:mm')
              .format(DateTime.parse(transaction.time!))
          : DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

      // Navigate to transaction detail
      GoRouter.of(context).push(
        '/protected/wallet/transaction-detail',
        extra: {
          'transactionTitle': 'Thanh toán đơn hàng',
          'transactionAmount': formattedAmount,
          'transactionStatus':
              'Thành công', // Assuming all displayed transactions are successful
          'transactionId': transaction.id.toString(),
          'transactionDateTime': formattedDate,
          'currentBalance': '${transaction.remaining.toInt()} FoodyXu',
        },
      );
    } else if (transactionItems.isNotEmpty && index < transactionItems.length) {
      // We're using sample data
      TransactionItem item = transactionItems[index];

      GoRouter.of(context).push(
        '/protected/wallet/transaction-detail',
        extra: {
          'transactionTitle': item.title,
          'transactionAmount': item.amount,
          'transactionStatus': 'Thành công',
          'transactionId': 'PAY${DateTime.now().millisecondsSinceEpoch}',
          'transactionDateTime': item.date,
          'currentBalance': '1000 FoodyXu', // Sample balance
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử thanh toán"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactionItems.isEmpty
              ? const Center(child: Text('Không có giao dịch thanh toán nào'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactionItems.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _navigateToTransactionDetail(index),
                      child:
                          TransactionCard(transaction: transactionItems[index]),
                    );
                  },
                ),
    );
  }
}
