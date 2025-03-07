// lib/dto/wallet_dto.dart
class WalletDto {
  final int id;
  final String fullName;
  final double balance;

  WalletDto({
    required this.id,
    required this.fullName,
    required this.balance,
  });

  factory WalletDto.fromJson(Map<String, dynamic> json) {
    return WalletDto(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      balance: (json['balance'] is int)
          ? (json['balance'] as int).toDouble()
          : json['balance'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'balance': balance,
    };
  }
}

// lib/dto/transaction_dto.dart
class TransactionDto {
  final int id;
  final String description;
  final String time;
  final double amount;
  final double remaining;
  final String type;

  TransactionDto({
    required this.id,
    required this.description,
    required this.time,
    required this.amount,
    required this.remaining,
    required this.type,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: json['id'] as int,
      description: json['description'] as String,
      time: json['time'] as String,
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : json['amount'] as double,
      remaining: (json['remaining'] is int)
          ? (json['remaining'] as int).toDouble()
          : json['remaining'] as double,
      type: json['type'] as String,
    );
  }

  // Helper method to format the time for display
  String get formattedTime {
    // Handle potential datetime format issues
    try {
      final dateTime = DateTime.parse(time);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    } catch (e) {
      // If parsing fails, return the original string
      return time;
    }
  }

  // Helper method to determine if this is a credit (positive) transaction
  bool get isCredit {
    return type == 'TOP_UP' || (type == 'TRANSFER' && amount > 0);
  }
}

// lib/dto/user_dto.dart
class SavedUser {
  final int userId;
  final String token;
  final String role;
  final String fullName;
  final String phone;

  SavedUser({
    required this.userId,
    required this.token,
    required this.role,
    required this.fullName,
    required this.phone,
  });

  factory SavedUser.fromJson(Map<String, dynamic> json) {
    return SavedUser(
      userId: json['userId'] as int,
      token: json['token'] as String,
      role: json['role'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'token': token,
      'role': role,
      'fullName': fullName,
      'phone': phone,
    };
  }
}
