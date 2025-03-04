import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductRepository {
  ProductRepository._();
  static final ProductRepository instance = ProductRepository._();
  final AppLogger logger = AppLogger.instance;

  Future<List<ProductDto>?> getProductsByRestaurantId(
      int restaurantId, String accessToken) async {
        logger.info("RestaurantId: $restaurantId, accessToken: $accessToken");
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/restaurants/$restaurantId/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> list = jsonResponse['data']['content'];
      logger.info(list.toString());
      return list
          .map((item) => ProductDto(
              id: item['id'],
              code: item['code'],
              name: item['name'],
              price: item['price'],
              description: item['description'],
              prepareTime: item['prepareTime'],
              available: item['available']))
          .toList();
    } else {
      throw Exception('Failed to load data!');
    }
  }
}
