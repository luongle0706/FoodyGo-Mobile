import 'package:foodygo/dto/OTP_dto.dart';
import 'package:foodygo/dto/login_dto.dart';
import 'package:foodygo/dto/register_dto.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final logger = AppLogger.instance;

  Future<LoginResponseDTO> login(
      {required LoginRequestDTO request, String? fcmToken}) async {
    logger.info('fcmToken=$fcmToken');
    final response = await http.post(
      fcmToken != null
          ? Uri.parse(
              '$globalURL/api/v1/authentications/login?fcmToken=$fcmToken')
          : Uri.parse('$globalURL/api/v1/authentications/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
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
          role: jsonResponse['role'],
          userId: jsonResponse['userId'],
          customerId: jsonResponse['customerId'],
          restaurantId: jsonResponse['restaurantId'],
          hubId: jsonResponse['hubId'],
          walletId: jsonResponse['walletId']);
    } else {
      throw Exception('Failed to load data!: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> loginByGoogle(
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

        return data;
      } else {
        throw Exception(
            'Failed to load data! Status Code: ${response.statusCode}');
      }
    } catch (e) {
      logger.error('Error occurred: $e');
      rethrow;
    }
  }

  Future<RegisterResponseDTO> register(RegisterRequestDTO request) async {
    try {
      var uri =
          Uri.parse('http://192.168.1.6:8080/api/v1/authentications/register');

      var requestMultipart = http.MultipartRequest("POST", uri);

      requestMultipart.fields['userRegisterRequest'] = jsonEncode({
        "email": request.email,
        "password": request.password,
        "fullName": request.fullname,
        "phone": request.phoneNumber,
        "buildingID": request.buildingID?.toString() ?? "",
        "dob": DateFormat('yyyy-MM-dd').format(request.dob),
      });

      // Kiểm tra nếu có ảnh thì thêm vào request
      if (request.image != null) {
        String? mimeType =
            lookupMimeType(request.image!.path); // Tự động lấy MIME type

        requestMultipart.files.add(await http.MultipartFile.fromPath(
          'image',
          request.image!.path,
        ));
      }

      var streamedResponse = await requestMultipart.send();
      var response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return RegisterResponseDTO.fromJson(responseBody);
      } else {
        logger.error("Error response: $responseBody");
        throw Exception(
            'Failed to register! Status code: ${response.statusCode}, Response: $responseBody');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  Future<OTPResponseDTO> sendOTP({required email}) async {
    Map<String, dynamic> body = {'email': email};
    logger.info("request body$body");

    final response = await http
        .post(Uri.parse('http://192.168.1.6:8080/api/v1/send-otp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body))
        .timeout(const Duration(seconds: 10));
    ;
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      logger.info("jsonResponse$jsonResponse");
      return OTPResponseDTO(
          message: jsonResponse['message'],
          otp: jsonResponse['data']['otp'],
          existedEmail: jsonResponse['data']['existedEmail'] as bool);
    } else {
      throw Exception('Failed to load data in send OTP!');
    }
  }

  Future<void> optOut({required String fcmToken}) async {
    final response = await http.post(
        Uri.parse(
            '$globalURL/api/v1/authentications/opt-out?fcmToken=$fcmToken'),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode != 200) logger.error("Sai r");
  }
}
