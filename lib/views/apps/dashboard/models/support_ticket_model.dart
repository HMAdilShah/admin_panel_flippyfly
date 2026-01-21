import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicketModel {
  final String status;
  final DateTime createdAt;

  SupportTicketModel({
    required this.status,
    required this.createdAt,
  });

  factory SupportTicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SupportTicketModel(
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
