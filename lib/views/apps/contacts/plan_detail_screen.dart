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
          final expImages = (plan['experiencesImages'] as List<dynamic>?)?.cast<String>() ?? [];
          final amenities = (plan['amenities'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
          final isSpecial = (plan['isSpecialOffer'] ?? false) as bool;

          String formatDate(dynamic d) {
            if (d == null) return '-';
            try {
              if (d is Timestamp) return "${d.toDate().day}/${d.toDate().month}/${d.toDate().year}";
              if (d is String) return DateTime.parse(d).day.toString() + "/" + DateTime.parse(d).month.toString() + "/" + DateTime.parse(d).year.toString();
              if (d is DateTime) return "${d.day}/${d.month}/${d.year}";
            } catch (_) {}
            return '-';
          }

          IconData getAmenityIcon(String key) {
            const fallbackIcons = {
              'star': LucideIcons.star,
              'heart': LucideIcons.heart,
              'wifi': LucideIcons.wifi,
              'coffee': LucideIcons.coffee,
              'music': LucideIcons.music,
              'car': LucideIcons.car,
              'dumbbell': LucideIcons.dumbbell,
              'sun': LucideIcons.sun,
            };
            return fallbackIcons[key] ?? LucideIcons.star;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Top images carousel
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

                // 🔹 Title + badges
                Row(
                  children: [
                    Expanded(
                      child: MyText.titleLarge(plan['title'] ?? 'Untitled Plan', fontWeight: 800),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: MyText.bodySmall(plan['isFor'] == 'free' ? 'FREE' : 'PREMIUM', color: Colors.blue, fontWeight: 700),
                    ),
                    if (isSpecial) ...[
                      MySpacing.width(8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: MyText.bodySmall("SPECIAL", color: Colors.pink, fontWeight: 700),
                      )
                    ]
                  ],
                ),
                MySpacing.height(8),
                MyText.bodySmall(
                    "From: ${formatDate(plan['fromDate'])} → To: ${formatDate(plan['toDate'])}", muted: true),
                MySpacing.height(16),

                // 🔹 Description
                MyText.bodyMedium(plan['description'] ?? "No description provided."),
                MySpacing.height(16),

                // 🔹 Coins & expiry
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

                // 🔹 Amenities
                if (amenities.isNotEmpty) ...[
                  MyText.titleSmall("Amenities", fontWeight: 700),
                  MySpacing.height(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: amenities.map((a) {
                      final iconKey = a['icon'] ?? 'star';
                      final title = a['title'] ?? '';
                      return Chip(
                        avatar: Icon(getAmenityIcon(iconKey), size: 16, color: Colors.amber),
                        label: Text(title),
                        backgroundColor: Colors.grey[100],
                      );
                    }).toList(),
                  ),
                  MySpacing.height(16),
                ],

                // 🔹 Experience images
                if (expImages.isNotEmpty) ...[
                  MyText.titleSmall("Experiences", fontWeight: 700),
                  MySpacing.height(8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: expImages.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(expImages[i], width: 120, height: 120, fit: BoxFit.cover),
                        ),
                      ),
                    ),
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

