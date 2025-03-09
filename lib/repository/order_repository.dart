import 'dart:convert';

import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;

class OrderRepository {
  OrderRepository._();
  static final instance = OrderRepository._();
  final _logger = AppLogger.instance;

  Future<int?> pay(
      {required String accessToken,
      required double shippingFee,
      required double productFee,
      required String time,
      required String expectedDeliveryTime,
      required String customerPhone,
      required String notes,
      required int customerId,
      required int restaurantId,
      required int hubId,
      required List<dynamic> cartLists}) async {
    Map<String, dynamic> body = {
      "shippingFee": shippingFee,
      "productPrice": productFee,
      "expectedDeliveryTime": expectedDeliveryTime,
      "time": time,
      "customerPhone": customerPhone,
      "notes": notes,
      "customerId": customerId,
      "restaurantId": restaurantId,
      "hubId": hubId,
      "orderDetails": cartLists
          .map((e) => {
                "quantity": e['quantity'],
                "price": e['price'],
                "addonItems": e['cartAddonItems'].toString(),
                "productId": e['productId']
              })
          .toList()
    };
    final response = await http.post(Uri.parse('$globalURL/api/v1/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: json.encode(body));
    if (response.statusCode == 201) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['data'];
    }
    _logger.error("Failed to place order");
    _logger.error(response.body);
    return null;
  }
}
