import 'dart:convert';
import 'package:foodygo/utils/app_logger.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationRepository {
  LocationRepository._();
  static final instance = LocationRepository._();

  final logger = AppLogger.instance;

  Future<double> getDistance(
      {required LatLng start, required LatLng end}) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final distance = data['routes'][0]['distance'];
          return distance;
        }
      } else {
        logger.error('Failed to fetch route. Status: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      logger.error('Error fetching route: $e');
      return 0;
    }
    return 0;
  }
}
