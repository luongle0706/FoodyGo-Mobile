import 'dart:convert';

import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;

class HubRepository {
  HubRepository._();
  static final instance = HubRepository._();

  final logger = AppLogger.instance;

  Future<List<dynamic>?> getHubs({int pageSize = -1}) async {
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/public/hubs?pageSize=$pageSize'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['data'];
    }
    return null;
  }

  Future<dynamic> getHubById(
      {required String accessToken, required int hubId}) async {
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/hubs/$hubId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      logger.info(jsonResponse.toString());
      return jsonResponse['data'];
    }
    return null;
  }
}
