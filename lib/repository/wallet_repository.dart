import 'dart:convert';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/dto/wallet_dto.dart';
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
}
