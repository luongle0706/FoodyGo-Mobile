class SavedUser {
  String email;
  String token;
  String fullName;
  String role;

  SavedUser(
      {required this.email,
      required this.token,
      required this.fullName,
      required this.role});

  toJson() {
    return {'email': email, 'token': token, 'fullName': fullName, 'role': role};
  }

  factory SavedUser.fromJson(Map<String, dynamic> json) {
    return SavedUser(
      token: json['token'],
      email: json['email'],
      fullName: json['fullName'],
      role: json['role'],
    );
  }
}
