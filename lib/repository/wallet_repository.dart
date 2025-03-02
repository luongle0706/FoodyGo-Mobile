import 'dart:convert';
import 'package:foodygo/dto/wallet_dto.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;

class WalletRepository {
  WalletRepository._();
  static final WalletRepository instance = WalletRepository._();
  final AppLogger logger = AppLogger.instance;

  Future<WalletDto> loadWalletBalance(String accessToken, int userId) async {
    logger.info("Fetching wallet balance for user ID: $userId");
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/wallets/customer/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final jsonResponse = json.decode(response.body);
      dynamic data = jsonResponse['data'];
      logger.info("Wallet data: $data");
      return WalletDto(
        id: data['id'],
        fullName: data['fullName'],
        balance: data['balance'],
      );
    } else {
      throw Exception('Failed to load wallet balance!');
    }
  }
}
