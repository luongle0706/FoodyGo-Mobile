class RestaurantDto {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String image;
  final bool available;

  RestaurantDto(
      {required this.id,
      required this.name,
      required this.phone,
      required this.email,
      required this.address,
      required this.image,
      required this.available});
}
