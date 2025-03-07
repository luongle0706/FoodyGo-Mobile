class ProductDto {
  final int id;
  final String code;
  final String name;
  final double price;
  //final String image;
  final String description;
  final double prepareTime;
  final bool available;

  ProductDto({required this.id, required this.code, required this.name, required this.price, required this.description, required this.prepareTime, required this.available});
}