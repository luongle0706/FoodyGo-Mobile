import 'dart:convert';

import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;

class CategoryRepostory {
  CategoryRepostory._();
  static final CategoryRepostory instance = CategoryRepostory._();
  final AppLogger logger = AppLogger.instance;

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
    logger.error('Get all categories returned ${response.statusCode}');
    return null;
  }
}
