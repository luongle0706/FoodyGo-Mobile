import 'package:foodygo/dto/restaurant_dto.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestaurantRepository {
  RestaurantRepository._();
  static final RestaurantRepository instance = RestaurantRepository._();
  final AppLogger logger = AppLogger.instance;

  Future<List<RestaurantDto>> loadRestaurants(String accessToken) async {
    logger.info("Access token hehe $accessToken");
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/restaurants'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> list = jsonResponse['data'];
      logger.info('${list}');
      return list
          .map((item) => RestaurantDto(
              id: item['id'],
              name: item['name'],
              phone: item['phone'],
              email: item['email'],
              address: item['address'],
              image: item['image'],
              available: item['available']))
          .toList();
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<RestaurantDto> loadRestaurantById(String accessToken, int id) async {
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/restaurants/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final jsonResponse = json.decode(response.body);
      dynamic data = jsonResponse['data'];
      logger.info('${data}');
      return RestaurantDto(
              id: data['id'],
              name: data['name'],
              phone: data['phone'],
              email: data['email'],
              address: data['address'],
              image: data['image'],
              available: data['available']);
    } else {
      throw Exception('Failed to load data!');
    }
  }
}
