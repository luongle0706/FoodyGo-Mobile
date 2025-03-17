import 'package:intl/intl.dart';

class RegisterRequestDTO {
  String email;
  String password;
  String fullname;
  String phoneNumber;
  int buildingID;
  DateTime dob;

  RegisterRequestDTO(
      {required this.email,
      required this.password,
      required this.fullname,
      required this.phoneNumber,
      required this.buildingID,
      required this.dob});

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim(),
      'password': password.trim(),
      'fullName': fullname.trim(),
      'phone': phoneNumber.trim(),
      'buildingID': buildingID,
      'dob': DateFormat('yyyy-MM-dd').format(dob)
    };
  }
}

class RegisterResponseDTO {
  final String message;
  final String email;
  final String roleName;
  final String fullname;
  final String phoneNumber;
  final int buildingId;
  final String buildingName;
  final int? userId;
  final DateTime dob;

  RegisterResponseDTO({
    required this.message,
    required this.email,
    required this.roleName,
    required this.fullname,
    required this.phoneNumber,
    required this.buildingId,
    required this.buildingName,
    this.userId,
    required this.dob,
  });
}
