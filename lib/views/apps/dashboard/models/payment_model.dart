import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final int amount;
  final String status; // paid | pending
  final DateTime? paidAt;

  PaymentModel({
    required this.amount,
    required this.status,
    this.paidAt,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      amount: map['amount'] ?? 0,
      status: map['status'] ?? 'pending',
      paidAt: map['paidAt'] != null
          ? (map['paidAt'] as Timestamp).toDate()
          : null,
    );
  }
}
