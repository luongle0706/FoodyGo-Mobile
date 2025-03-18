import 'dart:io';
import 'package:intl/intl.dart';

class RegisterRequestDTO {
  String email;
  String password;
  String fullname;
  String phoneNumber;
  int? buildingID;
  DateTime dob;
  File? image;

  RegisterRequestDTO({
    required this.email,
    required this.password,
    required this.fullname,
    required this.phoneNumber,
    this.buildingID,
    required this.dob,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
      "fullName": fullname,
      "phone": phoneNumber,
      "buildingID": buildingID,
      "dob": DateFormat('yyyy-MM-dd').format(dob),
    };
  }
}

class RegisterResponseDTO {
  final String message;
  final String email;
  final String roleName;
  final String fullname;
  final String phoneNumber;
  final int? buildingId;
  final String? buildingName;
  final int? userId;
  final DateTime dob;
  final String? image;

  RegisterResponseDTO(
      {required this.message,
      required this.email,
      required this.roleName,
      required this.fullname,
      required this.phoneNumber,
      this.buildingId,
      this.buildingName,
      this.userId,
      required this.dob,
      this.image});

  factory RegisterResponseDTO.fromJson(Map<String, dynamic> json) {
    return RegisterResponseDTO(
      message: json['message'],
      email: json['data']['email'],
      roleName: json['data']['roleName'],
      fullname: json['data']['fullName'],
      phoneNumber: json['data']['phone'],
      buildingId: json['data']['buildingID'] as int? ?? 0,
      buildingName: json['data']['buildingName'] ?? "No Name",
      userId: json['data']['userID'] as int?,
      dob: DateTime.parse(json['data']['dob']),
      image: json['data']['image'],
    );
  }
}
