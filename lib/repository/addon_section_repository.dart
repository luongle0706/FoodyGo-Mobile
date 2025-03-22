import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddonSectionRepository {
  AddonSectionRepository._();
  static final AddonSectionRepository instance = AddonSectionRepository._();
  final AppLogger _logger = AppLogger.instance;

  Future<List<dynamic>?> getAddonSectionByRestaurantId(
      {required accessToken,
      required restaurantId,
      int pageNo = 1,
      int pageSize = -1}) async {
    _logger.info("ProductId: $restaurantId, accessToken: $accessToken");
    final response = await http.get(
      Uri.parse(
          '$globalURL/api/v1/addon-sections?restaurantId=$restaurantId&pageNo=$pageNo&pageSize=$pageSize'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    if (response.statusCode == 200 || response.statusCode == 400) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> list = jsonResponse['data'];
      _logger.info(list.toString());
      return list;
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<bool> createAddonSection(
      String accessToken, Map<String, dynamic> body) async {
    _logger.info(body.toString());
    try {
      final response = await http.post(
        Uri.parse('$globalURL/api/v1/addon-sections'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
