import 'dart:convert';
import 'dart:io';

import 'package:foodygo/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class CustomerRepository {
  CustomerRepository._();
  static final instance = CustomerRepository._();

  Future<bool> updateCustomer(
      {required String accessToken,
      required int userId,
      required int buildingId,
      required String phone,
      required DateTime dob,
      File? image}) async {
    Uri uri = Uri.parse('$globalURL/api/v1/customers/$userId');

    var requestMultipart = http.MultipartRequest("PUT", uri);
    requestMultipart.headers['Content-Type'] = 'multipart/form-data';
    requestMultipart.headers['Authorization'] = 'Bearer $accessToken';

    Map<String, dynamic> customerUpdateRequest = {
      "buildingID": buildingId,
      "phone": phone,
      "dob": DateFormat('yyyy-MM-dd').format(dob)
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

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
