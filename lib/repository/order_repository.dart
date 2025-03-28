import 'dart:convert';

import 'package:foodygo/dto/order_dto.dart';
import 'package:foodygo/dto/order_dto_v2.dart';
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
    // Create order details with properly serialized addon items
    List<Map<String, dynamic>> orderDetails = cartLists.map((e) {
      // Just convert the addon items to JSON string - no price calculation here
      List<dynamic> addons = e['cartAddOnItems'] ?? [];
      String addonItemsJson = jsonEncode(addons);

      return {
        "quantity": e['quantity'],
        "price": e['price'],
        "addonItems": addonItemsJson,
        "productId": e['productId']
      };
    }).toList();

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
      "orderDetails": orderDetails
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

  Future<List<OrderDto>?> getOrdersByCustomerId(
      String accessToken, int customerId) async {
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
        throw Exception('Failed to load data');
      }
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
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
      _logger.info(data.toString());
      return OrderDto.fromJson(data);
    } else {
      _logger.error('Failed to load data!');
      return null;
    }
  }

  Future<OrderDtoV2?> loadOrderByIdV2(String accessToken, int id) async {
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/orders/$id/v2'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final jsonResponse = json.decode(response.body);
      dynamic data = jsonResponse['data'];
      return OrderDtoV2.fromJson(data);
    } else {
      _logger.error('Failed to load data!');
      return null;
    }
  }

  Future<List<dynamic>?> getOrdersByStatus(
      {required accessToken, status}) async {
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/orders?status=$status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      List<dynamic> data = jsonResponse['data'] ?? [];

      return data;
    }
    return null;
  }

  Future<List<OrderDto>?> getOrdersByStatusAndRestaurant(
      {required accessToken, required status, required restaurantId}) async {
    final response = await http.get(
        Uri.parse(
            '$globalURL/api/v1/orders?status=$status&restaurantId=$restaurantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        });
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      List<dynamic> data = jsonResponse['data'] ?? [];

      return data.map((item) {
        return OrderDto.fromJson(item);
      }).toList();
    }
    return null;
  }

  Future<Map<String, dynamic>?> getOrders(
      {required accessToken, required String params}) async {
    final response = await http
        .get(Uri.parse('$globalURL/api/v1/orders$params'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    });
    _logger.info('$globalURL/api/v1/orders$params');
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse;
    }
    return null;
  }

  Future<bool> updateStatusOrder(
      {required accessToken,
      required orderId,
      required String status,
      required int userId}) async {
    Map<String, dynamic> body = {"status": status, "userId": userId};
    _logger.info("repo da vao");
    final response = await http.put(
      Uri.parse("$globalURL/api/v1/orders/$orderId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      _logger.error('Error updating order: ${response.body}');
      return false;
    }
  }
}
