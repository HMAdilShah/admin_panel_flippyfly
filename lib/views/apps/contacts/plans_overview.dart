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
import 'package:webkit/views/apps/contacts/plan_detail_screen.dart';
import 'package:webkit/views/apps/contacts/plan_edit_screen.dart';
import 'package:webkit/views/layouts/layout.dart';

/// Plans Overview Screen (slider)
/// Collection in Firestore: "plans"
/// Each plan doc should contain at least:
/// - title, fromDate (timestamp or iso string), toDate, coins (int), images (List<String>),
/// - description (string), amenities (List<Map{icon, title}>) , isFor ('free'|'premium'),
/// - expiryDate, isSpecialOffer (bool), experiencesImages (List<String>)
class PlansOverview extends StatefulWidget {
  const PlansOverview({super.key});

  @override
  State<PlansOverview> createState() => _PlansOverviewState();
}

class _PlansOverviewState extends State<PlansOverview> with UIMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Color primary = const Color(0xFF835FFF);
  final Color background = const Color(0xFFEFF1FE);
  final Color accentPink = const Color(0xFFF71E64);
  final Color darkText = const Color(0xFF222222);

  final PageController _pageController = PageController(viewportFraction: 0.86);
  int _pageIndex = 0;

  String _formatDate(dynamic d) {
    if (d == null) return '-';
    try {
      if (d is Timestamp) {
        final dt = d.toDate();
        return "${dt.day}/${dt.month}/${dt.year}";
      } else if (d is String) {
        final dt = DateTime.parse(d);
        return "${dt.day}/${dt.month}/${dt.year}";
      } else if (d is DateTime) {
        return "${d.day}/${d.month}/${d.year}";
      }
    } catch (_) {}
    return '-';
  }

  Widget _buildBadge(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: (color ?? primary).withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: MyText.bodySmall(text, color: color ?? primary, fontWeight: 700),
    );
  }

  Widget _planCard(Map<String, dynamic> plan, int index) {
    final title = plan['title'] ?? 'Untitled Plan';
    final from = _formatDate(plan['fromDate']);
    final to = _formatDate(plan['toDate']);
    final coins = (plan['coins'] ?? 0).toString();
    final images = (plan['images'] as List<dynamic>?)?.cast<String>() ?? [];
    final thumbnail = images.isNotEmpty ? images[0] : null;
    final isFor = (plan['isFor'] ?? 'premium') as String;
    final isSpecial = (plan['isSpecialOffer'] ?? false) as bool;
    final expiry = _formatDate(plan['expiryDate']);
    final description = (plan['description'] ?? '').toString();

    final bool isActivePage = index == _pageIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      margin: EdgeInsets.only(
        top: isActivePage ? 6 : 18,
        bottom: isActivePage ? 6 : 18,
        left: 6,
        right: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isActivePage ? 0.08 : 0.04),
            blurRadius: isActivePage ? 18 : 8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 Top image
          if (thumbnail != null)
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(thumbnail, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.22),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.titleSmall(title,
                            color: Colors.white, fontWeight: 800),
                        MySpacing.height(6),
                        MyText.bodySmall("$from  →  $to",
                            color: Colors.white70),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Row(
                      children: [
                        _buildBadge(isFor == 'free' ? 'FREE' : 'PREMIUM',
                            color: isFor == 'free' ? Colors.green : primary),
                        if (isSpecial) ...[
                          MySpacing.width(8),
                          _buildBadge("SPECIAL", color: accentPink)
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              height: 180,
              color: background,
              alignment: Alignment.center,
              child: MyText.titleMedium(title, fontWeight: 700),
            ),

          // 🔹 Details Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row: coins + expiry
                Row(
                  children: [
                    Row(children: [
                      const Icon(LucideIcons.coins,
                          size: 18, color: Colors.orange),
                      MySpacing.width(8),
                      MyText.bodySmall("$coins coins", fontWeight: 700),
                    ]),
                    const Spacer(),
                    MyText.bodySmall("Expiry: $expiry", muted: true),
                  ],
                ),
                MySpacing.height(12),

                // 🔹 Description (multi-line allowed)
                MyText.bodyMedium(
                  description.isEmpty
                      ? "No description provided."
                      : description,
                  color: Colors.grey[700],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                MySpacing.height(16),

                // 🔹 Amenities in ONE horizontal row
                if ((plan['amenities'] as List<dynamic>?)?.isNotEmpty ?? false)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: (plan['amenities'] as List<dynamic>?)
                              ?.cast<Map<String, dynamic>>()
                              .map((a) {
                            final atitle = a['title'] ?? '';
                            return Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.star,
                                      size: 14, color: Colors.amber),
                                  MySpacing.width(6),
                                  MyText.bodySmall(atitle,
                                      color: Colors.grey[800]),
                                ],
                              ),
                            );
                          }).toList() ??
                          [],
                    ),
                  ),
                MySpacing.height(18),

                // 🔹 Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyButton(
                      onPressed: () {
                        Get.to(() => const PlanDetailScreen(),
                            arguments: {'planId': plan['docId']});
                      },
                      backgroundColor: Colors.grey[100],
                      borderRadiusAll: 10,
                      padding: MySpacing.xy(18, 10),
                      child: Row(children: [
                        const Icon(LucideIcons.eye, size: 16),
                        MySpacing.width(8),
                        MyText.bodySmall("View"),
                      ]),
                    ),
                    MySpacing.width(12),
                    MyButton(
                      onPressed: () {
                        Get.to(() => PlanEditScreen(planId: plan['docId']),
                            arguments: {'planId': plan['docId']});
                      },
                      backgroundColor: primary,
                      borderRadiusAll: 10,
                      padding: MySpacing.xy(18, 10),
                      child: Row(children: [
                        const Icon(Icons.edit, size: 16, color: Colors.white),
                        MySpacing.width(8),
                        MyText.bodySmall("Edit", color: Colors.white),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenBg = background;
    return Layout(
      child: Container(
        color: screenBg,
        padding: MySpacing.xy(flexSpacing, flexSpacing),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header with create button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.titleLarge("Plans",
                            fontWeight: 800, color: darkText),
                        MySpacing.height(6),
                        MyText.bodySmall(
                            "All created plans (swipe to preview).",
                            color: Colors.grey[700]),
                      ],
                    ),
                  ),
                  MyButton(
                    onPressed: () async {
                      final result = await Get.toNamed('/contacts/create_plan');
                      if (result == true) {
                        setState(() {}); // refresh if plan was created
                      }
                    },
                    backgroundColor: primary,
                    borderRadiusAll: 12,
                    padding: MySpacing.xy(16, 12),
                    child: Row(children: [
                      const Icon(LucideIcons.plus,
                          size: 16, color: Colors.white),
                      MySpacing.width(8),
                      MyText.bodyMedium("Create Plan", color: Colors.white),
                    ]),
                  ),
                ],
              ),
              MySpacing.height(12),

              // StreamBuilder for plans collection
              StreamBuilder<QuerySnapshot>(
                stream: _db
                    .collection('plans')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 320,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    /*return MyContainer(
                      color: Colors.white,
                      borderRadiusAll: 12,
                      paddingAll: 22,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MyText.titleMedium("No plans yet", fontWeight: 700),
                          MySpacing.height(8),
                          MyText.bodySmall(
                              "Create a new plan using the button on the top right."),
                          MySpacing.height(12),
                          MyButton(
                            onPressed: () async {
                              final result =
                                  await Get.toNamed('/contacts/create_plan');
                              if (result == true) {
                                setState(() {});
                              }
                            },
                            backgroundColor: primary,
                            borderRadiusAll: 10,
                            padding: MySpacing.xy(16, 10),
                            child: MyText.bodyMedium("Create Plan",
                                color: Colors.white),
                          )
                        ],
                      ),
                    );*/

                    return MyContainer(
                      color: Colors.white,
                      borderRadiusAll: 12,
                      paddingAll: 22,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MyText.titleMedium("No plans yet", fontWeight: 700),
                          MySpacing.height(8),
                          MyText.bodySmall(
                              "Create a new plan using the button on the top right."),
                          MySpacing.height(12),
                          MyButton(
                            onPressed: () async {
                              final result = await Get.toNamed('/contacts/create_plan');
                              if (result == true) setState(() {});
                            },
                            backgroundColor: primary,
                            borderRadiusAll: 10,
                            padding: MySpacing.xy(16, 10),
                            child: MyText.bodyMedium("Create Plan", color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }

                  final docs = snap.data!.docs;
                  final plans = docs.map((d) {
                    final m = (d.data() as Map<String, dynamic>?) ?? {};
                    m['docId'] = d.id;
                    return m;
                  }).toList();

                  return Column(
                    children: [
                      /*SizedBox(
                        height: 400, // slightly increased for safe space
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: plans.length,
                          onPageChanged: (i) => setState(() => _pageIndex = i),
                          itemBuilder: (context, index) {
                            return _planCard(plans[index], index);
                          },
                        ),
                      ),*/
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Scroll handled by outer SingleChildScrollView
                        itemCount: plans.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: _planCard(plans[index], index),
                          );
                        },
                      ),
                      MySpacing.height(12),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: List.generate(plans.length, (i) {
                      //     final bool selected = i == _pageIndex;
                      //     return AnimatedContainer(
                      //       duration: const Duration(milliseconds: 220),
                      //       margin: const EdgeInsets.symmetric(horizontal: 6),
                      //       height: selected ? 10 : 8,
                      //       width: selected ? 28 : 8,
                      //       decoration: BoxDecoration(
                      //         color: selected ? primary : Colors.grey[300],
                      //         borderRadius: BorderRadius.circular(6),
                      //       ),
                      //     );
                      //   }),
                      // ),
                    ],
                  );
                },
              ),
              MySpacing.height(12),
            ],
          ),
        ),
      ),
    );
  }
}
