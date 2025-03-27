import 'dart:convert';
import 'dart:io';

import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class CustomerRepository {
  CustomerRepository._();
  static final instance = CustomerRepository._();

  final logger = AppLogger.instance;

  Future<void> getCustomerById({required SavedUser user}) async {
    Uri uri = Uri.parse('$globalURL/api/v1/customers/${user.customerId}');
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${user.token}'
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      logger.info(jsonResponse.toString());
    }
  }

  Future<bool> updateCustomer(
      {required String accessToken,
      required int userId,
      required int buildingId,
      String? phone,
      DateTime? dob,
      File? image}) async {
    Uri uri = Uri.parse('$globalURL/api/v1/customers/$userId');

    var requestMultipart = http.MultipartRequest("PUT", uri);
    requestMultipart.headers['Content-Type'] = 'multipart/form-data';
    requestMultipart.headers['Authorization'] = 'Bearer $accessToken';

    Map<String, dynamic> customerUpdateRequest = {
      "buildingID": buildingId,
      "phone": phone,
      "dob": dob != null ? DateFormat('yyyy-MM-dd').format(dob) : null
    };
    String jsonData = json.encode(customerUpdateRequest);
    requestMultipart.files.add(
      http.MultipartFile.fromString(
        'customerUpdateRequest',
        jsonData,
        contentType: MediaType('application', 'json'),
      ),
    );

    // Kiểm tra nếu có ảnh thì thêm vào request
    if (image != null) {
      requestMultipart.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        filename: basename(image.path),
      ));
    }

    var streamedResponse = await requestMultipart.send();
    var response = await http.Response.fromStream(streamedResponse);
    AppLogger.instance.info(response.body.toString());
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
