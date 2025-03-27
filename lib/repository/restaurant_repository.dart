import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/dto/restaurant_dto.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestaurantRepository {
  RestaurantRepository._();
  static final RestaurantRepository instance = RestaurantRepository._();
  final AppLogger logger = AppLogger.instance;

  Future<Map<String, dynamic>> loadRestaurants(String accessToken) async {
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/restaurants?pageNo=1&pageSize=-1'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<RestaurantDto?> loadRestaurantById(String accessToken, int id) async {
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
      return RestaurantDto(
          id: data['id'],
          name: data['name'],
          phone: data['phone'],
          email: data['email'],
          address: data['address'],
          image: data['image'],
          available: data['available'],
          latitude: data['latitude'],
          longitude: data['longitude']);
    } else {
      logger.error('Failed to load data! ${response.body}');
      return null;
    }
  }

  Future<List<ProductDto>?> getProductsByRestaurantId(
      String accessToken, int restaurantId) async {
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/restaurants/$restaurantId/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (jsonData['data'] != null && jsonData['data']['content'] is List) {
        return (jsonData['data']['content'] as List)
            .map((item) => ProductDto.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<List<dynamic>?> searchRestaurants(
      String accessToken, String query) async {
    final response = await http.get(
      Uri.parse("$globalURL/api/v1/restaurants?name=$query"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception("Failed to search restaurants");
    }
  }
}
