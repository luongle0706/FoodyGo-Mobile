import 'dart:convert';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:foodygo/utils/secure_storage.dart';

class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  final SecureStorage _storage = SecureStorage.instance;
  final String _baseUrl = "https://your-api.com/api/customer";

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
      } else {
        throw Exception("Failed to load user data");
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
