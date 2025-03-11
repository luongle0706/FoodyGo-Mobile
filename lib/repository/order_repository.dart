import 'dart:convert';

import 'package:foodygo/dto/order_dto.dart';
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

  Future<List<OrderDto>?> getOrdersByCustomerId(String accessToken, int customerId) async {
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/orders/customers/$customerId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (jsonData['data'] != null && jsonData['data']['content'] is List) {
        return (jsonData['data']['content'] as List)
            .map((item) => OrderDto.fromJson(item))
            .toList();
      } else {
        throw Exception('Không tìm thấy dữ liệu đơn hàng');
      }
    } else {
      throw Exception('Lỗi khi tải đơn hàng: ${response.statusCode}');
    }
  }

  Future<OrderDto?> loadOrderById(String accessToken, int id) async {
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/orders/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final jsonResponse = json.decode(response.body);
      dynamic data = jsonResponse['data'];
      return OrderDto.fromJson(data);
    } else {
      _logger.error('Failed to load data!');
      return null;
    }
  }

  Future<List<dynamic>?> getOrdersByStatus(
      {required accessToken, status}) async {
    final response = await http
        .get(Uri.parse('$globalURL/api/v1/orders?status=$status'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      _logger.info("jsonResponse" + jsonResponse.toString());

      List<dynamic> data = jsonResponse['data'] ?? [];
      _logger.info("data" + jsonResponse.toString());

      return data;
    }
    return null;
  }
}
