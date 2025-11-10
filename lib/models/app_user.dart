// models/app_user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPlan {
  final String id; // purchase doc id (if stored in subcollection)
  final String name;
  final String paymentStatus; // paid, pending, due
  final double amount;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;

  UserPlan({
    required this.id,
    required this.name,
    required this.paymentStatus,
    required this.amount,
    this.purchaseDate,
    this.expiryDate,
  });

  factory UserPlan.fromMap(String id, Map<String, dynamic> data) {
    DateTime? _toDate(dynamic d) {
      if (d == null) return null;
      if (d is Timestamp) return d.toDate();
      if (d is DateTime) return d;
      if (d is String) {
        try {
          return DateTime.parse(d);
        } catch (_) {
          final parts = d.split('-');
          if (parts.length == 3) {
            final y = int.tryParse(parts[0]) ?? 0;
            final m = int.tryParse(parts[1]) ?? 0;
            final day = int.tryParse(parts[2]) ?? 0;
            return DateTime(y, m, day);
          }
        }
      }
      return null;
    }

    return UserPlan(
      id: id,
      name: data['name'] ?? data['planName'] ?? 'Plan',
      paymentStatus: (data['payment_status'] ?? data['paymentStatus'] ?? 'pending').toString(),
      amount: (data['amount'] ?? data['price'] ?? 0).toDouble(),
      purchaseDate: _toDate(data['purchase_date'] ?? data['purchasedAt']),
      expiryDate: _toDate(data['expiry_date'] ?? data['expiryAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'payment_status': paymentStatus,
      'amount': amount,
      'purchase_date': purchaseDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }
}

class AppUserModel {
  final String id;
  final String avatarUrl;
  final String country;
  final String email;
  final String name;
  final String phone;
  final String planName;
  final String userStatus;

  AppUserModel({
    required this.id,
    required this.avatarUrl,
    required this.country,
    required this.email,
    required this.name,
    required this.phone,
    required this.planName,
    required this.userStatus,
  });

  factory AppUserModel.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() ?? {}) as Map<String, dynamic>;
    return AppUserModel(
      id: doc.id,
      avatarUrl: data['avatar_url'] ?? data['avatarUrl'] ?? '',
      country: data['country'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      planName: data['plan_name'] ?? data['planName'] ?? '',
      userStatus: data['user_status'] ?? data['userStatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar_url': avatarUrl,
      'country': country,
      'email': email,
      'name': name,
      'phone': phone,
      'plan_name': planName,
      'user_status': userStatus,
    };
  }
}
