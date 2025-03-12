import 'dart:convert';

import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;

class HubRepository {
  HubRepository._();
  static final instance = HubRepository._();

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
}
