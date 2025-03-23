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
import 'package:foodygo/view/theme.dart';

class FoodyXuHistoryPage extends StatefulWidget {
  const FoodyXuHistoryPage({super.key});

  @override
  State<FoodyXuHistoryPage> createState() => _FoodyXuHistoryPageState();
}

class _FoodyXuHistoryPageState extends State<FoodyXuHistoryPage> {
  List<TransactionItem> transactionItems = [];
  List<TransactionDto> rawTransactions = []; // Store the raw transaction data
  bool isLoading = true;
  final walletRepository = WalletRepository.instance;
  final AppLogger logger = AppLogger.instance;
  final storage = SecureStorage.instance;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      String? data = await storage.get(key: 'user');
      SavedUser? savedUser =
          data != null ? SavedUser.fromJson(json.decode(data)) : null;

      if (savedUser != null) {
        List<TransactionDto>? transactions =
            await walletRepository.getTransactionHistory(savedUser);

        if (transactions != null) {
          // Store raw transactions
          rawTransactions = transactions;

          // Convert TransactionDto to TransactionItem
          final items = transactions.map((transaction) {
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

            // Get transaction title based on type and description
            String title = _getTransactionTitle(transaction.type,
                description: transaction.description);

            return TransactionItem(
              title: title,
              amount: transaction.getFormattedAmount(),
              date: formattedDate,
              icon: transaction.getTransactionIcon(),
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
      logger.error("Error loading transactions: $e");
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
            icon: Icons.payment),
        TransactionItem(
            title: "Mua điểm",
            amount: "+ 50 FoodyXu",
            date: "04/12/2023 11:32",
            icon: Icons.attach_money),
        TransactionItem(
            title: "Chuyển điểm",
            amount: "- 50 FoodyXu",
            date: "04/12/2023 11:32",
            icon: Icons.swap_horiz),
        TransactionItem(
            title: "Rút tiền",
            amount: "- 5000 FoodyXu",
            date: "04/12/2023 11:32",
            icon: Icons.money_off),
        TransactionItem(
            title: "Nhận điểm",
            amount: "+ 50 FoodyXu",
            date: "04/12/2023 11:32",
            icon: Icons.swap_horiz),
      ];
      isLoading = false;
    });
  }

  String _getTransactionTitle(String type, {String? description}) {
    switch (type) {
      case 'TOP_UP':
        return 'Mua điểm';
      case 'WITHDRAWAL':
        return 'Rút tiền';
      case 'PAYMENT':
        return 'Thanh toán đơn hàng';
      case 'REFUND':
        return 'Hoàn tiền';
      case 'TRANSFER':
        // Check description to determine if it's received or sent
        if (description != null &&
            (description.toLowerCase().contains('received') ||
                description.toLowerCase().contains('nhận') ||
                description.toLowerCase().contains('from'))) {
          return 'Nhận điểm';
        }
        return 'Chuyển điểm';
      default:
        return 'Giao dịch';
    }
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
          'transactionTitle': _getTransactionTitle(transaction.type,
              description: transaction.description),
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
          'transactionId': 'TRX${DateTime.now().millisecondsSinceEpoch}',
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
        title: const Text(
          "Lịch sử điểm FoodyXu",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: Container(
        color: AppColors.background,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : transactionItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: AppColors.secondary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Không có giao dịch nào',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Các giao dịch của bạn sẽ xuất hiện ở đây',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactionItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _navigateToTransactionDetail(index),
                          child: TransactionCard(
                            transaction: transactionItems[index],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
