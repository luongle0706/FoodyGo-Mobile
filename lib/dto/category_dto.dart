class CategoryDto {
  final int id;
  final String name;
  final String description;

  CategoryDto({
    required this.id,
    required this.name,
    required this.description,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}