import 'dart:convert';

import 'package:http/http.dart' as http;

class BuildingRepository {
  BuildingRepository._();
  static final instance = BuildingRepository._();

  Future<List<dynamic>?> getAllBuildings({int pageSize = -1}) async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.4:8080/api/v1/public/buildings?pageSize=$pageSize'),
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
