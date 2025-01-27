class SavedUser {
  String email;
  String token;

  SavedUser({
    required this.email,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'email': email.trim(),
      'token': token.trim(),
    };

    return map;
  }

  factory SavedUser.fromJson(Map<String, dynamic> json) {
    return SavedUser(
      email: json["email"] ?? "",
      token: json["token"] ?? "",
    );
  }
}
