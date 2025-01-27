import 'package:foodygo/model/login_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    String url = "https://reqres.in/api/login";

    final response = await http.post(
      Uri.parse(url),
      body: request.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      return LoginResponseModel(token: '', error: 'Failed to login');
    }
  }
}
