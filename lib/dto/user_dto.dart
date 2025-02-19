class SavedUser {
  String email;
  String token;
  String fullName;

  SavedUser({
    required this.email,
    required this.token,
    required this.fullName,
  });

  toJson() {
    return {
      'email': email,
      'token': token,
      'fullName': fullName,
    };
  }
}
