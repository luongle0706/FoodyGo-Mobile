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

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int,
      code: json['code'] ?? '',
      name: json['name'] ?? 'Unknown Product',
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'] ?? 'No description available',
      prepareTime: (json['prepareTime'] ?? 0.0).toDouble(),
      available: json['available'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'price': price,
      'description': description,
      'prepareTime': prepareTime,
      'available': available,
    };
  }

}