import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddonSectionRepository {
  AddonSectionRepository._();
  static final AddonSectionRepository instance = AddonSectionRepository._();
  final AppLogger _logger = AppLogger.instance;

  Future<List<AddonSectionDto>?> getAddonSectionByRestaurantId(
      {required accessToken, required restaurantId}) async {
    _logger.info("ProductId: $restaurantId, accessToken: $accessToken");
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/addon-sections?restaurantId=$restaurantId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    if (response.statusCode == 200 || response.statusCode == 400) {
      final jsonResponse = json.decode(response.body);
      dynamic list = jsonResponse['data'];
      _logger.info(list.toString());
      return list.map((item) {
        return AddonSectionDto.fromJson(item);
      });
    } else {
      throw Exception('Failed to load data!');
    }
  }
}
