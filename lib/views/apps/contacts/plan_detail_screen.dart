import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';

class PlanDetailScreen extends StatelessWidget {
  const PlanDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final planId = Get.arguments?['planId'];
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    if (planId == null) {
      return Scaffold(
        body: Center(child: MyText.titleMedium("No plan selected")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _db.collection('plans').doc(planId).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || !snap.data!.exists) {
            return Center(child: MyText.bodyMedium("Plan not found."));
          }

          final plan = snap.data!.data() as Map<String, dynamic>;

          final images = (plan['images'] as List<dynamic>?)?.cast<String>() ?? [];
          final amenities = (plan['amenities'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

          String formatDate(dynamic d) {
            if (d == null) return '-';
            try {
              if (d is Timestamp) {
                final dt = d.toDate();
                return "${dt.day}/${dt.month}/${dt.year}";
              } else if (d is String) {
                // Try parsing with DateTime.parse first
                try {
                  final dt = DateTime.parse(d);
                  return "${dt.day}/${dt.month}/${dt.year}";
                } catch (_) {
                  // If parse fails, try manual split for "yyyy-M-d"
                  final parts = d.split('-');
                  if (parts.length >= 3) {
                    final y = int.tryParse(parts[0]) ?? 0;
                    final m = int.tryParse(parts[1]) ?? 0;
                    final day = int.tryParse(parts[2]) ?? 0;
                    return "$day/$m/$y";
                  }
                }
              } else if (d is DateTime) {
                return "${d.day}/${d.month}/${d.year}";
              }
            } catch (_) {}
            return '-';
          }


          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top image carousel
                if (images.isNotEmpty)
                  SizedBox(
                    height: 220,
                    child: PageView(
                      children: images
                          .map((img) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(img, fit: BoxFit.cover),
                      ))
                          .toList(),
                    ),
                  ),
                MySpacing.height(16),

                // Title & type
                Row(
                  children: [
                    MyText.titleLarge(plan['title'] ?? 'Untitled Plan', fontWeight: 800),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: MyText.bodySmall(plan['isFor'] == 'free' ? 'FREE' : 'PREMIUM', color: Colors.blue, fontWeight: 700),
                    ),
                  ],
                ),
                MySpacing.height(8),
                MyText.bodySmall(
                    "From: ${formatDate(plan['fromDate'])}  →  To: ${formatDate(plan['toDate'])}", muted: true),
                MySpacing.height(12),

                // Description
                MyText.bodyMedium(plan['description'] ?? "No description provided."),
                MySpacing.height(16),

                // Coins & expiry
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.coins, color: Colors.orange, size: 18),
                        MySpacing.width(6),
                        MyText.bodyMedium("${plan['coins'] ?? 0} coins", fontWeight: 700),
                      ],
                    ),
                    const Spacer(),
                    MyText.bodySmall("Expiry: ${formatDate(plan['expiryDate'])}", muted: true),
                  ],
                ),
                MySpacing.height(16),

                // Amenities
                if (amenities.isNotEmpty) ...[
                  MyText.titleSmall("Amenities", fontWeight: 700),
                  MySpacing.height(8),
                  Row(
                    children: amenities.map((a) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.star, size: 14, color: Colors.amber),
                            MySpacing.width(4),
                            MyText.bodySmall(a['title'] ?? ''),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  MySpacing.height(16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
