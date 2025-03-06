import 'dart:convert';

import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;

class CartRepository {
  CartRepository._();
  static final CartRepository instance = CartRepository._();

  Future<List<dynamic>?> getCartByRestaurant(
      {required accessToken, required userId, required restaurantId}) async {
    final response = await http.get(
        Uri.parse(
            '$globalURL/api/v1/carts/users/$userId/restaurants/$restaurantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        });
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      List<dynamic> data = responseBody['data'];
      return data;
    }
    return null;
  }

  Future<bool> addToCart(
      {required accessToken,
      required userId,
      required restaurantId,
      required productId,
      required productName,
      required price,
      required quantity,
      cartAddonItems}) async {
    Map<String, dynamic> body = {
      'restaurantId': restaurantId,
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'cartAddOnItems': cartAddonItems ?? []
    };

    final response = await http.post(
      Uri.parse('$globalURL/api/v1/carts/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }
}
