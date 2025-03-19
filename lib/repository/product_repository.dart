import 'dart:io';

import 'package:foodygo/dto/edit_product_dto.dart';
import 'package:foodygo/dto/product_dto.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'dart:convert';

class ProductRepository {
  ProductRepository._();
  static final ProductRepository instance = ProductRepository._();
  final AppLogger logger = AppLogger.instance;

  Future<bool>? linkProduct(
      {required int productId,
      required int addonSectionId,
      required String accessToken}) async {
    final response = await http.put(
      Uri.parse(
          '$globalURL/api/v1/products/$productId/addon-sections/$addonSectionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

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
      return ProductDto.fromJson(item);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<bool> switchAvailabilityProduct(String accessToken, int productId) async {
    try {
      final response = await http.put(
        Uri.parse('$globalURL/api/v1/products/$productId/availability'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to switch availability: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error switching availability: $e');
    }
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

      logger.info("call ${list.toString()}");

      return list
          .map((item) => ProductDto(
                id: item['id'],
                code: item['code'],
                name: item['name'],
                price: item['price'],
                image: item['image'],
                description: item['description'],
                prepareTime: item['prepareTime'],
                available: item['available'],
                addonSections: (item['addonSections'] as List<dynamic>?)
                    ?.map((section) => AddonSectionDto(
                          id: section['id'],
                          name: section['name'],
                          maxChoice: section['maxChoice'],
                          required: section['required'],
                          items: (section['items'] as List<dynamic>?)
                              ?.map((item) => AddonItemDto(
                                    id: item['id'],
                                    name: item['name'],
                                    price: item['price'].toDouble(),
                                    quantity: item['quantity'],
                                  ))
                              .toList(),
                        ))
                    .toList(),
                category: item['category'] != null
                    ? CategoryDTO(
                        id: item['category']['id'],
                        name: item['category']['name'],
                      )
                    : null,
              ))
          .toList();
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<bool> deleteProduct(int productId, String accessToken) async {

    try {
      final response = await http.delete(
        Uri.parse('$globalURL/api/v1/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );

      return response.statusCode == 200;
    } catch (error) {
      return false;
    }
  }

  Future<bool> updateProduct(int productId, File? image, EditProductDto editProduct, String accessToken) async {
    try {
      var uri = Uri.parse('$globalURL/api/v1/products/$productId');
      var request = http.MultipartRequest("PUT", uri);
      
      // Thêm token vào headers
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.headers['Content-Type'] = 'multipart/form-data';

      String jsonData = jsonEncode(editProduct.toJson());

      // Thêm JSON data vào request dưới dạng MultipartFile với Content-Type là application/json
      request.files.add(
        http.MultipartFile.fromString(
          'data', 
          jsonData, 
          contentType: MediaType('application', 'json'),
        ),
      );

      // Nếu có hình ảnh, thêm vào request
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', 
            image.path,
            filename: basename(image.path),
          ),
        );
      }

      // Gửi request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      logger.info(responseData);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    
    } catch (error) {
      return false;
    }
  }
}
