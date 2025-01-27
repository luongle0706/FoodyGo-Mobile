class LoginRequestDTO {
  String email;
  String password;

  LoginRequestDTO({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'email': email.trim(),
      'password': password.trim(),
    };

    return map;
  }
}

class LoginResponseDTO {
  final String code;
  final String message;
  final String token;
  final String refreshToken;

  LoginResponseDTO(
      {required this.code,
      required this.message,
      required this.token,
      required this.refreshToken});

  factory LoginResponseDTO.fromJson(Map<String, dynamic> json) {
    return LoginResponseDTO(
      code: json["code"] ?? "",
      message: json["message"] ?? "",
      token: json["token"] ?? "",
      refreshToken: json["refreshToken"] ?? "",
    );
  }
}
