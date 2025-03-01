import 'package:foodygo/dto/login_dto.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final logger = AppLogger.instance;

  Future<LoginResponseDTO> login(LoginRequestDTO request) async {
    final response = await http.post(
      Uri.parse('$globalURL/api/v1/authentications/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      logger.info(jsonResponse.toString());
      return LoginResponseDTO(
          code: jsonResponse['code'],
          message: jsonResponse['message'],
          token: jsonResponse['token'],
          refreshToken: jsonResponse['refreshToken'],
          fullName: jsonResponse['fullName'],
          email: jsonResponse['email'],
          role: jsonResponse['role']);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<LoginResponseDTO> loginByGoogle(
      String googleIdToken, String fcmToken) async {
    final url =
        '$globalURL/api/v1/authentications/firebase?googleIdToken=$googleIdToken&fcmToken=$fcmToken';
    logger.info('Sending request to: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      logger.info('Response Status Code: ${response.statusCode}');
      logger.info('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final Map<String, dynamic> data = jsonResponse['data'];

        return LoginResponseDTO(
            code: data['code'],
            message: data['message'],
            token: data['token'],
            refreshToken: data['refreshToken'],
            fullName: data['fullName'],
            email: data['email'],
            role: data['role']);
      } else {
        throw Exception(
            'Failed to load data! Status Code: ${response.statusCode}');
      }
    } catch (e) {
      logger.error('Error occurred: $e');
      rethrow;
    }
  }
}
