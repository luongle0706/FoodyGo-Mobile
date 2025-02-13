import 'package:foodygo/dto/login_dto.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRepository {
  Future<LoginResponseDTO> login(LoginRequestDTO request) async {
    final response = await http.post(
      Uri.parse('$globalURL/api/v1/public/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 400) {
      return LoginResponseDTO.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load data!');
    }
  }
}
