import 'package:foodygo/dto/login_dto.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRepository {
  Future<LoginResponseDTO> login(LoginRequestDTO request) async {
    final response = await http.post(
      Uri.parse('$globalURL/api/v1/authentications/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    print("HELLO");

    if (response.statusCode == 200 || response.statusCode == 400) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final Map<String, dynamic> data = jsonResponse['data'];
      return LoginResponseDTO(
          code: data['code'],
          message: data['message'],
          token: data['token'],
          refreshToken: data['refreshToken'],
          fullName: data['fullName'],
          email: data['email']);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<LoginResponseDTO> loginByGoogle(String googleIdToken) async {
    final url =
        '$globalURL/api/v1/authentications/firebase?googleIdToken=$googleIdToken';
    print('Sending request to: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print(response.toString());

      if (response.statusCode == 200 || response.statusCode == 400) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final Map<String, dynamic> data = jsonResponse['data'];

        return LoginResponseDTO(
            code: data['code'],
            message: data['message'],
            token: data['token'],
            refreshToken: data['refreshToken'],
            fullName: data['fullName'],
            email: data['email']);
      } else {
        throw Exception(
            'Failed to load data! Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      rethrow;
    }
  }

  // void test(String idToken) async {
  //   final response = await http.get(Uri.parse(
  //       '$globalURL/api/v1/authentications/firebase-decode-token?authorizationHeader=$idToken'));

  //   if (response.statusCode == 200) {
  //     print('Success');
  //   } else {
  //     throw Exception('Failed to load data!');
  //   }
  // }
}
