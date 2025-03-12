import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductRepository {
  ProductRepository._();
  static final ProductRepository instance = ProductRepository._();
  final AppLogger logger = AppLogger.instance;

  Future<ProductDto>? getProductById(int productId, String accessToken) async {
    logger.info("ProductId: $productId, accessToken: $accessToken");

    final response = await http.get(
      Uri.parse('$globalURL/api/v1/products/$productId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final jsonResponse = json.decode(response.body);
      dynamic item = jsonResponse['data'];
      logger.info(item.toString());

      return mapToProductDto(item); // Map JSON sang DTO
    } else {
      throw Exception('Failed to load data!');
    }
  }

  ProductDto mapToProductDto(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      prepareTime: (json['prepareTime'] as num).toDouble(),
      available: json['available'],
      addonSections: json['addonSections'] != null
          ? (json['addonSections'] as List)
              .map((section) => mapToAddonSection(section))
              .toList()
          : null,
    );
  }

  AddonSection mapToAddonSection(Map<String, dynamic> json) {
    return AddonSection(
      id: json['id'],
      name: json['name'],
      maxChoice: json['maxChoice'],
      required: json['required'],
      items: json['items'] != null
          ? (json['items'] as List).map((item) => mapToAddonItem(item)).toList()
          : [],
    );
  }

  AddonItem mapToAddonItem(Map<String, dynamic> json) {
    return AddonItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
    );
  }

  Future<List<ProductDto>?> getProductsByRestaurantId(
      int restaurantId, String accessToken) async {
    logger.info("RestaurantId: $restaurantId, accessToken: $accessToken");
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/restaurants/$restaurantId/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> list = jsonResponse['data']['content'];
      logger.info("products: ${list.toString()}");

      return list
          .map((item) => ProductDto(
                id: item['id'],
                code: item['code'],
                name: item['name'],
                price: (item['price'] as num).toDouble(),
                description: item['description'],
                prepareTime: (item['prepareTime'] as num).toDouble(),
                available: item['available'],
                addonSections: item['addonSections'] != null
                    ? (item['addonSections'] as List<dynamic>)
                        .map((section) => AddonSection(
                              id: section['id'],
                              name: section['name'],
                              maxChoice: section['maxChoice'],
                              required: section['required'],
                              items: section['items'] != null
                                  ? (section['items'] as List<dynamic>)
                                      .map((addon) => AddonItem(
                                            id: addon['id'],
                                            name: addon['name'],
                                            price: (addon['price'] as num)
                                                .toDouble(),
                                            quantity: addon['quantity'],
                                          ))
                                      .toList()
                                  : [],
                            ))
                        .toList()
                    : [],
              ))
          .toList();
    } else {
      throw Exception('Failed to load data!');
    }
  }
}
