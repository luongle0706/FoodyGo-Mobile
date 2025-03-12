class ProductDto {
  final int id;
  final String code;
  final String name;
  final double price;
  final String description;
  final double prepareTime;
  final bool available;
  final List<AddonSectionDto>? addonSections;
  final CategoryDTO? category;

  ProductDto({
    required this.id,
    required this.code,
    required this.name,
    required this.price,
    required this.description,
    required this.prepareTime,
    required this.available,
    this.addonSections,
    this.category,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int,
      code: json['code'] ?? '',
      name: json['name'] ?? 'Unknown Product',
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'] ?? 'No description available',
      prepareTime: (json['prepareTime'] ?? 0.0).toDouble(),
      available: json['available'] ?? false,
      addonSections: (json['addonSections'] as List<dynamic>?)?.map((e) => AddonSectionDto.fromJson(e)).toList(),
      category: json['category'] != null ? CategoryDTO.fromJson(json['category']) : null,
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
      'addonSections': addonSections?.map((e) => e.toJson()).toList(),
      'category': category?.toJson(),
    };
  }
}

class AddonSectionDto {
  final int id;
  final String name;
  final int maxChoice;
  final bool required;
  final List<AddonItemDto>? items;

  AddonSectionDto({
    required this.id,
    required this.name,
    required this.maxChoice,
    required this.required,
    this.items,
  });

  factory AddonSectionDto.fromJson(Map<String, dynamic> json) {
    return AddonSectionDto(
      id: json['id'] as int,
      name: json['name'] ?? '',
      maxChoice: json['maxChoice'] ?? 0,
      required: json['required'] ?? false,
      items: (json['items'] as List<dynamic>?)?.map((e) => AddonItemDto.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'maxChoice': maxChoice,
      'required': required,
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }
}

class AddonItemDto {
  final int id;
  final String name;
  final double price;
  final int quantity;

  AddonItemDto({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory AddonItemDto.fromJson(Map<String, dynamic> json) {
    return AddonItemDto(
      id: json['id'] as int,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class CategoryDTO {
  final int id;
  final String name;

  CategoryDTO({
    required this.id,
    required this.name,
  });

  factory CategoryDTO.fromJson(Map<String, dynamic> json) {
    return CategoryDTO(
      id: json['id'] as int,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
