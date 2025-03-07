class RegisterRequestDTO {
  String email;
  String password;

  RegisterRequestDTO({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'email': email.trim(),
      'password': password.trim(),
    };
    return map;
  }
}

class RegisterResponseDTO {
  final String message;
  final String email;
  final String roleName;
  final int? userId;

  RegisterResponseDTO(
      {required this.message,
      required this.email,
      required this.roleName,
      this.userId});
}
