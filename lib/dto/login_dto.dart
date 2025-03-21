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
  final String fullName;
  final String email;
  final String role;
  final int userId;
  final int? customerId;
  final int? restaurantId;
  final int? hubId;
  final int? walletId;

  LoginResponseDTO(
      {required this.code,
      required this.message,
      required this.token,
      required this.refreshToken,
      required this.fullName,
      required this.email,
      required this.role,
      required this.userId,
      required this.customerId,
      required this.restaurantId,
      required this.hubId,
      required this.walletId});
}
