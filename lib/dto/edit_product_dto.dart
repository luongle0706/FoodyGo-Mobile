class EditProductDto {
  final String? code;
  final String? name;
  final double? price;
  final String? description;
  final double? prepareTime;
  final bool? available;
  final int? categoryId;

  EditProductDto({
    this.code,
    this.name,
    this.price,
    this.description,
    this.prepareTime,
    this.available,
    this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'price': price,
      'description': description,
      'prepareTime': prepareTime,
      'available': available,
      'categoryId': categoryId,
    };
  }
}
