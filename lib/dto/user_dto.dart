class SavedUser {
  String email;
  String token;
  String fullName;
  String role;
  int userId;
  int? customerId;
  int? restaurantId;

  SavedUser(
      {required this.email,
      required this.token,
      required this.fullName,
      required this.role,
      required this.userId,
      required this.customerId,
      required this.restaurantId});

  toJson() {
    return {
      'email': email,
      'token': token,
      'fullName': fullName,
      'role': role,
      'userId': userId,
      'customerId': customerId,
      'restaurantId': restaurantId
    };
  }

  factory SavedUser.fromJson(Map<String, dynamic> json) {
    return SavedUser(
        token: json['token'],
        email: json['email'],
        fullName: json['fullName'],
        role: json['role'],
        userId: json['userId'],
        customerId: json['customerId'],
        restaurantId: json['restaurantId']);
  }
}
