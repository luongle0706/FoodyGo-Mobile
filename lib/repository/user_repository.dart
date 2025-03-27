import 'dart:convert';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  final AppLogger logger = AppLogger.instance;

  Future<Map<String, dynamic>?> getUserInfo(
      int userId, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse("$globalURL/api/v1/users/$userId"),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data["data"] != null) {
          final user = data["data"]["user"];
          final building = data["data"]["building"];
          return {
            "phoneNumber": user["phone"],
            "fullName": user["fullName"],
            "buildingName": building != null ? building["name"] : null,
          };
        }
        logger.error('An error occurred: ${response.body}');
      }
    } catch (e) {
      logger.error(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(
      int userId, String accessToken) async {
    try {
      AppLogger.instance.info("Fetching user info for userId: $userId");

      final response = await http.get(
        Uri.parse("$globalURL/api/v1/users/get/$userId"),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        AppLogger.instance.info("User API Response: ${response.body}");
        AppLogger.instance.info(responseData["data"].toString());
        if (responseData.containsKey("data")) {
          return responseData["data"];
        } else {
          AppLogger.instance
              .error("API response missing 'data' field: ${response.body}");
        }
      } else {
        AppLogger.instance
            .error("API error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      AppLogger.instance.error("Error fetching user info: $e");
    }
    return null;
  }
}
