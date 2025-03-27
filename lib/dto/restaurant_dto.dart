class RestaurantDto {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String image;
  final bool available;
  final double latitude;
  final double longitude;

  RestaurantDto(
      {required this.id,
      required this.name,
      required this.phone,
      required this.email,
      required this.address,
      required this.image,
      required this.available,
      required this.latitude,
      required this.longitude});

  factory RestaurantDto.fromJson(Map<String, dynamic> json) {
    return RestaurantDto(
        id: json['id'] as int,
        name: json['name'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
        address: json['address'] as String,
        image: json['image'] as String,
        available: json['available'] as bool,
        latitude: json['latitude'],
        longitude: json['longitude']);
  }
}
