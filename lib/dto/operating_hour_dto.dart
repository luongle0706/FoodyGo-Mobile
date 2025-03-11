class OperatingHourDTO {
  final int id;
  final String day;
  final bool open;
  final bool hours;
  final String openingTime;
  final String closingTime;

  OperatingHourDTO({
    required this.id,
    required this.day,
    required this.open,
    required this.hours,
    required this.openingTime,
    required this.closingTime,
  });

  /// Chuyển từ JSON sang Object
  factory OperatingHourDTO.fromJson(Map<String, dynamic> json) {
    return OperatingHourDTO(
      id: json['id'] as int,
      day: json['day'] as String,
      open: json['open'] as bool,
      hours: json['hours'] as bool,
      openingTime: json['openingTime'] as String,
      closingTime: json['closingTime'] as String,
    );
  }

  /// Chuyển từ Object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'open': open,
      'hours': hours,
      'openingTime': openingTime,
      'closingTime': closingTime,
    };
  }
}
