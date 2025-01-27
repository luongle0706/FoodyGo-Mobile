class SavedUser {
  String email;
  String token;
  List<String> roles;

  SavedUser({
    required this.email,
    required this.token,
    required this.roles,
  });
}
