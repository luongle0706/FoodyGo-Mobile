import 'dart:convert';

import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;

class CartRepository {
  CartRepository._();
  static final CartRepository instance = CartRepository._();
  final AppLogger _logger = AppLogger.instance;

  // Add to CartRepository class
  String generateItemFingerprint(dynamic cartItem) {
    final List<dynamic> addons = cartItem['cartAddOnItems'] ?? [];
    // Sort addons by ID to ensure consistent fingerprinting
    addons.sort((a, b) => a['addOnItemId'].compareTo(b['addOnItemId']));

    // Create a string with productId and all addon IDs
    String fingerprint = cartItem['productId'].toString();
    for (var addon in addons) {
      fingerprint += "_${addon['addOnItemId']}";
    }
    return fingerprint;
  }

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

  // Add a new method to CartRepository
  Future<bool> removeSpecificCartItem(
      {required accessToken, required userId, required cartItemId}) async {
    final response = await http.delete(
      Uri.parse('$globalURL/api/v1/carts/users/$userId/items/$cartItemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    if (response.statusCode == 200) {
      return true;
    }
    _logger.error(json.decode(response.body).toString());
    return false;
  }

  // In CartRepository.dart, update the removeFromCart method
  Future<bool> removeFromCart(
      {required accessToken,
      required userId,
      required productId,
      // Add a cartItemIndex parameter to identify specific items with same productId
      int? cartItemIndex}) async {
    // If cartItemIndex is provided, use it in the API call
    String url = cartItemIndex != null
        ? '$globalURL/api/v1/carts/users/$userId/products/$productId/items/$cartItemIndex'
        : '$globalURL/api/v1/carts/users/$userId/products/$productId';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    if (response.statusCode == 200) {
      return true;
    }
    _logger.error(json.decode(response.body).toString());
    return false;
  }

  Future<bool> addToCart(
      {required accessToken,
      required userId,
      required restaurantId,
      required productId,
      required productName,
      required price,
      required quantity,
      required image,
      cartAddonItems}) async {
    Map<String, dynamic> body = {
      'restaurantId': restaurantId,
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'image': image,
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

  Future<bool> clearCart({required accessToken, required userId}) async {
    final response = await http
        .delete(Uri.parse('$globalURL/api/v1/carts/users/$userId'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    });
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
