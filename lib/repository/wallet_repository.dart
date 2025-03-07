import 'dart:convert';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/dto/wallet_dto.dart';
import 'package:foodygo/dto/transaction_dto.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;

class WalletRepository {
  WalletRepository._();
  static final WalletRepository instance = WalletRepository._();
  final AppLogger logger = AppLogger.instance;

  Future<WalletDto?> loadWalletBalance(SavedUser savedUser) async {
    int userId = savedUser.userId;
    String accessToken = savedUser.token;
    String url = savedUser.role == 'ROLE_SELLER'
        ? '$globalURL/api/v1/wallets/restaurant/$userId'
        : '$globalURL/api/v1/wallets/customer/$userId';

    logger.info("Fetching wallet balance for user ID: $userId");
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      dynamic data = jsonResponse['data'];
      logger.info("Wallet data: $data");
      return WalletDto(
        id: data['id'],
        fullName: data['fullName'],
        balance: data['balance'],
      );
    } else {
      return null;
    }
  }

  // Add this method to your existing WalletRepository class
  Future<List<TransactionDto>?> getTransactionHistory(
      SavedUser savedUser) async {
    int userId = savedUser.userId;
    String accessToken = savedUser.token;
    String url = '$globalURL/api/v1/wallets/$userId/transactions';

    logger.info("Fetching transaction history for wallet ID: $userId");
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> transactionsData = jsonResponse['data'];
      logger.info("Transactions fetched: ${transactionsData.length}");

      return transactionsData
          .map((data) => TransactionDto.fromJson(data))
          .toList();
    } else {
      logger.error("Failed to fetch transactions: ${response.statusCode}");
      return null;
    }
  }

  Future<List<TransactionDto>?> getPaymentHistory(SavedUser savedUser) async {
    int userId = savedUser.userId;
    String accessToken = savedUser.token;
    String url = '$globalURL/api/v1/wallets/$userId/payments';

    logger.info("Fetching payment history for wallet ID: $userId");
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> paymentsData = jsonResponse['data'];
      logger.info("Payments fetched: ${paymentsData.length}");

      // Ensure all transactions are of type PAYMENT
      for (var payment in paymentsData) {
        if (payment['type'] != 'PAYMENT') {
          logger.warning(
              "Non-payment transaction found in payment history: ${payment['type']}");
        }
      }

      return paymentsData.map((data) => TransactionDto.fromJson(data)).toList();
    } else {
      logger.error("Failed to fetch payments: ${response.statusCode}");
      return null;
    }
  }

  // Add this method to your existing WalletRepository class
  Future<bool> withdrawFromWallet(SavedUser savedUser, double amount) async {
    int walletId = savedUser.userId;
    String accessToken = savedUser.token;
    String url = '$globalURL/api/v1/wallets/$walletId/withdraw';

    logger.info(
        "Processing withdrawal for wallet ID: $walletId, amount: $amount FoodyXu");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: json.encode({'amount': amount}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        logger.info("Withdrawal successful: ${jsonResponse['message']}");
        return true;
      } else {
        final errorResponse = json.decode(response.body);
        logger.error(
            "Withdrawal failed: ${errorResponse['message'] ?? 'Unknown error'}");
        return false;
      }
    } catch (e) {
      logger.error("Error processing withdrawal: $e");
      return false;
    }
  }

  // Add this method to your existing WalletRepository class
  Future<bool> transferPoints(SavedUser savedUser, String receiverPhone,
      double amount, String note) async {
    int walletId = savedUser.userId;
    String accessToken = savedUser.token;
    String url = '$globalURL/api/v1/wallets/$walletId/transfer';

    logger.info(
        "Processing transfer from wallet ID: $walletId to receiver: $receiverPhone, amount: $amount FoodyXu");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: json.encode(
            {'receiver': receiverPhone, 'amount': amount, 'note': note}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        logger.info("Transfer successful: ${jsonResponse['message']}");
        return true;
      } else {
        final errorResponse = json.decode(response.body);
        logger.error(
            "Transfer failed: ${errorResponse['message'] ?? 'Unknown error'}");
        return false;
      }
    } catch (e) {
      logger.error("Error processing transfer: $e");
      return false;
    }
  }

  // Add this method to the WalletRepository class

  // Add this method to the WalletRepository class
  Future<Map<String, dynamic>?> topUpWallet(
      SavedUser savedUser, double amount, String method) async {
    int userId = savedUser.userId;
    String accessToken = savedUser.token;
    String url = '$globalURL/api/v1/wallets/$userId/topup';

    // Convert FoodyXu amount to VND (1 FoodyXu = 1000 VND)
    final amountInVND = (amount * 1000).toInt();

    logger.info(
        "Processing top-up for wallet ID: $userId, amount: $amount FoodyXu, method: $method");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: json.encode({
          'amount': amountInVND,
          'method': method.toLowerCase(),
        }),
      );

      logger.info("Top-up API response status: ${response.statusCode}");
      logger.info("Top-up API response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Check if the response contains the data field
        if (jsonResponse.containsKey('data')) {
          logger.info("Top-up request successful");
          return jsonResponse['data'] as Map<String, dynamic>;
        } else {
          logger.error("Invalid response format: missing data field");
          return null;
        }
      } else {
        try {
          final errorResponse = json.decode(response.body);
          logger.error(
              "Top-up request failed: ${errorResponse['message'] ?? 'Unknown error'}");
        } catch (e) {
          logger.error("Failed to parse error response: $e");
        }
        return null;
      }
    } catch (e) {
      logger.error("Error processing top-up request: $e");
      return null;
    }
  }
}
