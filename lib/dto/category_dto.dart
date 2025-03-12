class CategoryDto {
  final int id;
  final String name;
  final String description;
  final int restaurantId;
  final String restaurantName;

  CategoryDto({
    required this.id,
    required this.name,
    required this.description,
    required this.restaurantId,
    required this.restaurantName,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      restaurantId: json['restaurantId'],
      restaurantName: json['restaurantName'],
    );
  }
}