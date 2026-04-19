class PaymentAccount {
  final String id;
  final String accountName;
  final String holderName;
  final String accountNumber;
  final String? iban;

  PaymentAccount({
    required this.id,
    required this.accountName,
    required this.holderName,
    required this.accountNumber,
    this.iban,
  });

  factory PaymentAccount.fromJson(Map<String, dynamic> json) {
    return PaymentAccount(
      id: json['id'].toString(),
      accountName: json['account_name'] ?? '',
      holderName: json['holder_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      iban: json['iban'],
    );
  }
}
