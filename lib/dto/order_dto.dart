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
      expectedDeliveryTime: DateTime.parse(json['expectedDeliveryTime']),
      time: DateTime.parse(json['time']),
      customerPhone: json['customerPhone'] ?? '',
      shipperPhone: json['shipperPhone'], // Giữ nguyên null nếu không có
      notes: json['notes'], // Giữ nguyên null nếu không có
      employeeName: json['employeeName'] ?? 'Unknown Employee',
      customerName: json['customerName'] ?? 'Unknown Customer',
      restaurantName: json['restaurantName'] ?? 'Unknown Restaurant',
      hubName: json['hubName'] ?? 'Unknown Hub',
      orderDetails: (json['orderDetails'] as List<dynamic>)
          .map((item) => OrderDetail.fromJson(item))
          .toList(),
    );
  }
}

class OrderDetail {
  final int id;
  final int orderId;
  final int quantity;
  final double price;
  final String productName;
  final List<String>? addonItems;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.quantity,
    required this.price,
    required this.productName,
    this.addonItems,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      quantity: json['quantity'] as int,
      price: (json['price'] ?? 0.0).toDouble(),
      productName: json['productName'] ?? 'Unknown Product',
      addonItems: json['addonItems'] != null
          ? List<String>.from(json['addonItems'])
          : null,
    );
  }
}
