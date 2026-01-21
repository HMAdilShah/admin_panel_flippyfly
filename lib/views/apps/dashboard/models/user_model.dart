import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String country;
  final String status;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.country,
    required this.status,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      country: data['country'] ?? '',
      status: data['user_status'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }
}
