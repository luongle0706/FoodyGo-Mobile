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
      id: json['id'],
      fullName: json['fullName'],
      balance: json['balance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'fullName': fullName, 'balance': balance};
  }
}
