import 'package:foodygo/dto/restaurant_dto.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestaurantRepository {
  Future<List<RestaurantDto>> loadRestaurants(String accessToken) async {
    final response = await http.post(
      Uri.parse(
          '$globalURL/api/v1/restaurants?pageNo=0&sortBy=id&ascending=true'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final Map<String, dynamic> data = jsonResponse['data'];
      return data['content']
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
}
