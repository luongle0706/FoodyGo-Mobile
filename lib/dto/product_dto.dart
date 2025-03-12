class ProductDto {
  final int id;
  final String code;
  final String name;
  final double price;
  final String description;
  final double prepareTime;
  final bool available;
  final List<AddonSection>? addonSections;

  ProductDto({
    required this.id,
    required this.code,
    required this.name,
    required this.price,
    required this.description,
    required this.prepareTime,
    required this.available,
    this.addonSections,
  });

  @override
  String toString() {
    return 'ProductDto(id: $id, code: $code, name: $name, price: $price, '
        'description: $description, prepareTime: $prepareTime, '
        'available: $available, addonSections: $addonSections)';
  }
}

class AddonItem {
  final int id;
  final String name;
  final double price;
  final int quantity;

  AddonItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  @override
  String toString() {
    return 'AddonItem(id: $id, name: $name, price: $price)';
  }
}

class AddonSection {
  final int id;
  final String name;
  final int maxChoice;
  final bool required;
  final List<AddonItem> items;

  AddonSection({
    required this.id,
    required this.name,
    required this.maxChoice,
    required this.required,
    required this.items,
  });

  @override
  String toString() {
    return 'AddonSection(id: $id, name: $name, maxChoice: $maxChoice, items: $items)';
  }
}
