import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:webkit/helpers/theme/app_style.dart';
import 'package:webkit/helpers/utils/ui_mixins.dart';
import 'package:webkit/helpers/widgets/my_button.dart';
import 'package:webkit/helpers/widgets/my_container.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:webkit/helpers/widgets/responsive.dart';
import 'package:webkit/views/layouts/layout.dart';

class MembershipManagement extends StatefulWidget {
  const MembershipManagement({super.key});

  @override
  State<MembershipManagement> createState() => _MembershipManagementState();
}

class _MembershipManagementState extends State<MembershipManagement> with UIMixin {
  final Color primary = const Color(0xFF835FFF);
  final Color background = const Color(0xFFF6F7FF);
  final Color accentPink = const Color(0xFFF71E64);
  final Color darkText = const Color(0xFF222222);

  final _premiumTitle = TextEditingController();
  final _premiumDesc = TextEditingController();
  final _premiumMonthly = TextEditingController();
  final _premiumAnnual = TextEditingController();
  final _premiumMonthlyDiscount = TextEditingController();
  final _premiumAnnualDiscount = TextEditingController();

  bool _isSaving = false;
  final _db = FirebaseFirestore.instance;

  Future<void> _saveMembership(String id, Map<String, dynamic> payload) async {
    try {
      setState(() => _isSaving = true);
      await _db.collection('memberships').doc(id).set(
        {...payload, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
      Get.snackbar(
        "Saved",
        "${payload['title']} updated successfully.",
        backgroundColor: primary.withOpacity(0.1),
        colorText: primary,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: accentPink.withOpacity(0.1),
        colorText: accentPink,
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _openEditPremiumModal(DocumentSnapshot? doc) {
    final data = doc?.data() as Map<String, dynamic>? ?? {};
    _premiumTitle.text = data['title'] ?? 'Premium Membership';
    _premiumDesc.text = data['description'] ?? 'Access to all exclusive features.';
    _premiumMonthly.text = (data['monthlyPrice'] ?? '').toString();
    _premiumAnnual.text = (data['annualPrice'] ?? '').toString();
    _premiumMonthlyDiscount.text = (data['monthlyDiscount'] ?? '').toString();
    _premiumAnnualDiscount.text = (data['annualDiscount'] ?? '').toString();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.titleMedium("Edit Premium Membership", fontWeight: 700, color: darkText),
                MySpacing.height(14),

                // Title & Description
                TextField(
                  controller: _premiumTitle,
                  decoration: InputDecoration(
                    labelText: "Title",
                    filled: true,
                    fillColor: background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                MySpacing.height(12),
                TextField(
                  controller: _premiumDesc,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    filled: true,
                    fillColor: background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                MySpacing.height(12),

                // Prices
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _premiumMonthly,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Monthly Price (QAR)",
                          filled: true,
                          fillColor: background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    MySpacing.width(12),
                    Expanded(
                      child: TextField(
                        controller: _premiumAnnual,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Annual Price (QAR)",
                          filled: true,
                          fillColor: background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                MySpacing.height(12),

                // Discounts
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _premiumMonthlyDiscount,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Monthly Discount (%)",
                          filled: true,
                          fillColor: background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    MySpacing.width(12),
                    Expanded(
                      child: TextField(
                        controller: _premiumAnnualDiscount,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Annual Discount (%)",
                          filled: true,
                          fillColor: background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                MySpacing.height(18),

                // Save Button
                Align(
                  alignment: Alignment.centerRight,
                  child: MyButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                      final monthly = double.tryParse(_premiumMonthly.text.trim()) ?? 0;
                      final annual = double.tryParse(_premiumAnnual.text.trim()) ?? 0;
                      final monthlyDiscount = double.tryParse(_premiumMonthlyDiscount.text.trim()) ?? 0;
                      final annualDiscount = double.tryParse(_premiumAnnualDiscount.text.trim()) ?? 0;

                      await _saveMembership('premium', {
                        'title': _premiumTitle.text.trim(),
                        'description': _premiumDesc.text.trim(),
                        'monthlyPrice': monthly,
                        'annualPrice': annual,
                        'monthlyDiscount': monthlyDiscount,
                        'annualDiscount': annualDiscount,
                        'type': 'premium',
                      });
                      Navigator.pop(context);
                    },
                    backgroundColor: primary,
                    padding: MySpacing.xy(20, 12),
                    borderRadiusAll: 10,
                    child: _isSaving
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : MyText.bodyMedium("Save", color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) Icon(icon, size: 16, color: primary),
        if (icon != null) MySpacing.width(6),
        MyText.bodySmall("$label: ", color: Colors.grey[700]),
        MyText.bodySmall(value, fontWeight: 700),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Layout(
      child: Container(
        color: background,
        padding: MySpacing.xy(flexSpacing, flexSpacing),
        child: StreamBuilder<QuerySnapshot>(
          stream: _db.collection('memberships').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = {for (var d in snapshot.data!.docs) d.id: d};
            final freeDoc = docs['free'];
            final premiumDoc = docs['premium'];

            final freeData = freeDoc?.data() as Map<String, dynamic>? ??
                {'title': 'Free Plan', 'description': 'Basic access to explore and use limited features.'};

            final premiumData = premiumDoc?.data() as Map<String, dynamic>? ??
                {
                  'title': 'Premium Plan',
                  'description': 'Unlock full access and exclusive tools.',
                  'monthlyPrice': 1999,
                  'annualPrice': 19999,
                  'monthlyDiscount': 0,
                  'annualDiscount': 0,
                };

            Widget buildCard({
              required String title,
              required String description,
              bool isPremium = false,
              double? monthly,
              double? annual,
              double? monthlyDiscount,
              double? annualDiscount,
              VoidCallback? onEdit,
            }) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6))
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(isPremium ? LucideIcons.star : LucideIcons.badge,
                            color: isPremium ? primary : Colors.green, size: 22),
                        MySpacing.width(10),
                        MyText.titleSmall(title, fontWeight: 700, color: darkText),
                        const Spacer(),
                        if (isPremium)
                          IconButton(
                            icon: Icon(Icons.edit, size: 20, color: primary),
                            onPressed: onEdit,
                          ),
                      ],
                    ),
                    MySpacing.height(8),
                    MyText.bodyMedium(description, color: Colors.grey[700]),
                    MySpacing.height(18),
                    if (isPremium)
                      Row(
                        children: [
                          _buildInfoRow(
                              "Monthly",
                              "QAR ${monthly?.toStringAsFixed(0) ?? '0'} (-${monthlyDiscount?.toStringAsFixed(0) ?? '0'}%)",
                              icon: LucideIcons.wallet),
                          MySpacing.width(12),
                          _buildInfoRow(
                              "Annual",
                              "QAR ${annual?.toStringAsFixed(0) ?? '0'} (-${annualDiscount?.toStringAsFixed(0) ?? '0'}%)",
                              icon: LucideIcons.calendar),
                        ],
                      )
                    else
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: MyText.bodySmall("Free forever", color: Colors.green[800], fontWeight: 700),
                      ),
                    MySpacing.height(20),
                    Divider(color: Colors.grey[300]),
                    MySpacing.height(12),
                    if (isPremium)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoRow("Active Members", "1,234", icon: LucideIcons.users),
                          _buildInfoRow("Engagement", "92%", icon: LucideIcons.trending_up),
                        ],
                      )
                    else
                      _buildInfoRow("Active Members", "782", icon: LucideIcons.users),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.titleLarge("Membership Plans", fontWeight: 800, color: darkText),
                MySpacing.height(12),
                MyText.bodyMedium("Manage the membership tiers offered to users.", color: Colors.grey[700]),
                MySpacing.height(30),
                isWide
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: buildCard(title: freeData['title'], description: freeData['description'])),
                    MySpacing.width(20),
                    Expanded(
                      child: buildCard(
                        title: premiumData['title'],
                        description: premiumData['description'],
                        isPremium: true,
                        monthly: premiumData['monthlyPrice']?.toDouble(),
                        annual: premiumData['annualPrice']?.toDouble(),
                        monthlyDiscount: premiumData['monthlyDiscount']?.toDouble(),
                        annualDiscount: premiumData['annualDiscount']?.toDouble(),
                        onEdit: () => _openEditPremiumModal(premiumDoc),
                      ),
                    ),
                  ],
                )
                    : Column(
                  children: [
                    buildCard(title: freeData['title'], description: freeData['description']),
                    MySpacing.height(20),
                    buildCard(
                      title: premiumData['title'],
                      description: premiumData['description'],
                      isPremium: true,
                      monthly: premiumData['monthlyPrice']?.toDouble(),
                      annual: premiumData['annualPrice']?.toDouble(),
                      monthlyDiscount: premiumData['monthlyDiscount']?.toDouble(),
                      annualDiscount: premiumData['annualDiscount']?.toDouble(),
                      onEdit: () => _openEditPremiumModal(premiumDoc),
                    ),
                  ],
                ),
                MySpacing.height(32),
                MyContainer(
                  color: Colors.white,
                  borderRadiusAll: 14,
                  paddingAll: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText.bodyMedium("Create membership plans or edit existing ones."),
                      Row(
                        children: [
                          MyButton(
                            onPressed: () async {
                              final doc = await _db.collection('memberships').doc('free').get();
                              if (doc.exists) {
                                Get.snackbar("Free Plan", "Free plan already exists — edit Premium plan if needed.",
                                    backgroundColor: primary.withOpacity(0.08), colorText: primary);
                              } else {
                                await _saveMembership('free', {
                                  'title': 'Free Plan',
                                  'description': 'Basic access to explore and use limited features.',
                                  'type': 'free'
                                });
                              }
                            },
                            backgroundColor: Colors.grey[200],
                            borderRadiusAll: 10,
                            padding: MySpacing.xy(16, 10),
                            child: MyText.bodyMedium("Create Free Plan", color: darkText),
                          ),
                          MySpacing.width(12),
                          MyButton(
                            onPressed: () async {
                              final doc = await _db.collection('memberships').doc('premium').get();
                              if (doc.exists) {
                                Get.snackbar("Premium Plan", "Premium plan already exists — edit if you need changes.",
                                    backgroundColor: primary.withOpacity(0.08), colorText: primary);
                              } else {
                                await _saveMembership('premium', {
                                  'title': 'Premium Plan',
                                  'description': 'Unlock full access and exclusive tools.',
                                  'monthlyPrice': 1999,
                                  'annualPrice': 19999,
                                  'monthlyDiscount': 0,
                                  'annualDiscount': 0,
                                  'type': 'premium'
                                });
                              }
                            },
                            backgroundColor: primary,
                            borderRadiusAll: 10,
                            padding: MySpacing.xy(16, 10),
                            child: MyText.bodyMedium("Create Premium Plan", color: Colors.white),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
