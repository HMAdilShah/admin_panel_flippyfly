import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_model.dart';

class UsersPlanModel {
  final String userId;
  final String planId;
  final int totalMonths;
  final List<PaymentModel> payments;

  UsersPlanModel({
    required this.userId,
    required this.planId,
    required this.totalMonths,
    required this.payments,
  });

  factory UsersPlanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UsersPlanModel(
      userId: data['user_id'],
      planId: data['plan_id'],
      totalMonths: data['total_months'] ?? 0,
      payments: (data['payments'] as List? ?? [])
          .map((e) => PaymentModel.fromMap(e))
          .toList(),
    );
  }

  /// ✅ OPTION C — revenue actually paid
  int get paidAmount {
    return payments
        .where((p) => p.status == 'paid')
        .fold(0, (sum, p) => sum + p.amount);
  }
}
