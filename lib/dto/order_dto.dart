class OrderDto {
  final int id;
  final double shippingFee;
  final double serviceFee;
  final double totalPrice;
  final int totalItems;
  final String status;
  final DateTime expectedDeliveryTime;
  final DateTime time;
  final String customerPhone;
  final String? shipperPhone;
  final String? notes;
  final String employeeName;
  final String customerName;
  final String restaurantName;
  final int restaurantId;
  final String image;
  final String hubName;
  final List<OrderDetail> orderDetails;

  OrderDto({
    required this.id,
    required this.shippingFee,
    required this.serviceFee,
    required this.totalPrice,
    required this.totalItems,
    required this.status,
    required this.expectedDeliveryTime,
    required this.time,
    required this.customerPhone,
    this.shipperPhone,
    this.notes,
    required this.employeeName,
    required this.customerName,
    required this.restaurantName,
    required this.restaurantId,
    required this.image,
    required this.hubName,
    required this.orderDetails,
  });

  /// Factory method to create an OrderDTO from JSON
  factory OrderDto.fromJson(Map<String, dynamic> json) {
    return OrderDto(
      id: json['id'] as int,
      shippingFee: (json['shippingFee'] ?? 0.0).toDouble(),
      serviceFee: (json['serviceFee'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      totalItems: int.parse((json['totalItems'] ?? '0').toString()),
      status: json['status'] ?? 'UNKNOWN',
      expectedDeliveryTime: json['expectedDeliveryTime'] != null
          ? DateTime.parse(json['expectedDeliveryTime'])
          : DateTime.now(), // Fallback về thời gian hiện tại nếu null
      time:
          json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
      customerPhone: json['customerPhone'] ?? '',
      shipperPhone: json['shipperPhone'],
      notes: json['notes'],
      employeeName: json['employeeName'] ?? 'Unknown Employee',
      customerName: json['customerName'] ?? 'Unknown Customer',
      restaurantName: json['restaurantName'] ?? 'Unknown Restaurant',
      restaurantId: (json['restaurantId'] ?? 0) as int,
      image: json['image'] ??
          'https://via.placeholder.com/150', // Ảnh mặc định nếu null
      hubName: json['hubName'] ?? 'Unknown Hub',
      orderDetails: (json['orderDetails'] as List<dynamic>?)
              ?.map((item) => OrderDetail.fromJson(item))
              .toList() ??
          [], // Nếu `orderDetails` null, gán thành danh sách rỗng
    );
  }
}

class OrderDetail {
  final int id;
  final int orderId;
  final int quantity;
  final double price;
  final String productName;
  final String image;
  final dynamic addonItems;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.quantity,
    required this.price,
    required this.productName,
    required this.image,
    this.addonItems,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      quantity: json['quantity'] as int,
      price: (json['price'] ?? 0.0).toDouble(),
      productName: json['productName'] ?? 'Unknown Product',
      image: json['image'] ?? 'https://via.placeholder.com/150', // Ảnh mặc định
      addonItems: json['addonItems'],
    );
  }
}
