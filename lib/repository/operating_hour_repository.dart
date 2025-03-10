import 'package:foodygo/dto/operating_hour_dto.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OperatingHourRepository {
  OperatingHourRepository._();
  static final OperatingHourRepository instance = OperatingHourRepository._();
  final AppLogger _logger = AppLogger.instance;

  Future<List<OperatingHourDTO>?> loadOperatingHoursByRestaurantId(
      String accessToken, int id) async {
    final response = await http.get(
      Uri.parse('$globalURL/api/v1/operating-hours/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> list = jsonResponse['data'];
      return list.map((item) => OperatingHourDTO.fromJson(item)).toList();
    } else {
      _logger.error('Failed to load data!');
      return null;
    }
  }
}
