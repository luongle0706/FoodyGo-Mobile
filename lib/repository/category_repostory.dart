import 'dart:convert';

import 'package:foodygo/dto/category_dto.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;

class CategoryRepostory {
  CategoryRepostory._();
  static final CategoryRepostory instance = CategoryRepostory._();
  final AppLogger _logger = AppLogger.instance;

  Future<Map<String, dynamic>?> loadCategories({
    required String accessToken,
    int pageNo = 1,
    int pageSize = 50,
    String params = 'id,name,description',
  }) async {
    final response = await http.get(
      Uri.parse(
          '$globalURL/api/v1/categories?pageNo=$pageNo&pageSize=$pageSize&params=$params'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse;
    }
    _logger.error('Get all categories returned ${response.statusCode}');
    return null;
  }

  Future<List<CategoryDto>?> getCategoriesByRestaurantId({required accessToken, required restaurantId}) async {
    final response = await http
        .get(Uri.parse('$globalURL/api/v1/categories?restaurantId=$restaurantId&params=id,name,description,restaurantId,restaurantName'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      _logger.info("jsonResponse $jsonResponse");

      List<dynamic> data = jsonResponse['data'] ?? [];
      _logger.info("data $jsonResponse");

      return data.map((item) {
        return CategoryDto.fromJson(item);
      }).toList();
    }
    return null;
  }

  Future<bool> updateCategory(String accessToken, CategoryDto categoryDto) async {
    try {
      var uri = Uri.parse("$globalURL/api/v1/categories");

      var response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(categoryDto.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
