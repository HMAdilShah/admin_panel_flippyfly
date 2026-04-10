import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';

import 'package:webkit/helpers/theme/admin_theme.dart';
import 'package:webkit/helpers/utils/my_shadow.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb_item.dart';
import 'package:webkit/helpers/widgets/my_card.dart';
import 'package:webkit/helpers/widgets/my_container.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:webkit/views/layouts/layout.dart';

class WithdrawRequestsScreen extends StatefulWidget {
  const WithdrawRequestsScreen({super.key});

  @override
  State<WithdrawRequestsScreen> createState() =>
      _WithdrawRequestsScreenState();
}

class _WithdrawRequestsScreenState extends State<WithdrawRequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Map<String, dynamic>> withdrawRequests =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      isLoading.value = true;
      final snap = await _firestore
          .collection('withdraw_requests')
          .orderBy('requested_at', descending: true)
          .get();
      withdrawRequests.value =
          snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load requests: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateStatus(String docId, String newStatus, int index) async {
    try {
      await _firestore
          .collection('withdraw_requests')
          .doc(docId)
          .update({'status': newStatus});

      final updated =
      Map<String, dynamic>.from(withdrawRequests[index]);
      updated['status'] = newStatus;
      withdrawRequests[index] = updated;

      Get.snackbar(
        newStatus == 'approved' ? '✅ Approved' : '❌ Rejected',
        'Withdrawal request has been $newStatus.',
        backgroundColor:
        newStatus == 'approved' ? Colors.green : Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;

    return Layout(
      child: SingleChildScrollView(
        padding: MySpacing.xy(12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium(
                  "Withdraw Requests",
                  fontSize: 22,
                  fontWeight: 700,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Dashboard', route: '/dashboard'),
                    MyBreadcrumbItem(
                        name: 'Withdraw Requests', active: true),
                  ],
                ),
              ],
            ),
            MySpacing.height(16),

            // ── Card ────────────────────────────────────────────────────
            MyCard(
              padding: MySpacing.all(16),
              shadow: MyShadow(elevation: .6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title row + refresh ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.banknote, size: 20),
                          MySpacing.width(8),
                          MyText.titleMedium("All Withdrawal Requests",
                              fontWeight: 600),
                        ],
                      ),
                      IconButton(
                        onPressed: _fetchRequests,
                        icon: const Icon(LucideIcons.refresh_cw, size: 18),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                  MySpacing.height(16),

                  // ── Table Header ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: contentTheme.primary.withOpacity(.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: MyText.bodySmall("User",
                                fontWeight: 700)),
                        Expanded(
                            flex: 3,
                            child: MyText.bodySmall("Email",
                                fontWeight: 700)),
                        Expanded(
                            flex: 1,
                            child: MyText.bodySmall("Amount",
                                fontWeight: 700)),
                        Expanded(
                            flex: 1,
                            child: MyText.bodySmall("Wallet",
                                fontWeight: 700)),
                        Expanded(
                            flex: 2,
                            child: MyText.bodySmall("Requested At",
                                fontWeight: 700)),
                        Expanded(
                            flex: 2,
                            child: MyText.bodySmall("Status",
                                fontWeight: 700)),
                        Expanded(
                            flex: 2,
                            child: MyText.bodySmall("Action",
                                fontWeight: 700)),
                      ],
                    ),
                  ),
                  MySpacing.height(8),

                  // ── Table Body ──
                  Obx(() {
                    if (isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (withdrawRequests.isEmpty) {
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: MyText.bodyMedium(
                              "No withdrawal requests found",
                              muted: true),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: withdrawRequests.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final req = withdrawRequests[index];
                        final status =
                        (req['status'] ?? 'pending').toString();
                        final requestedAt = req['requested_at'] != null
                            ? (req['requested_at'] as Timestamp)
                            .toDate()
                            : null;

                        Color statusColor;
                        switch (status.toLowerCase()) {
                          case 'approved':
                            statusColor = Colors.green;
                            break;
                          case 'rejected':
                            statusColor = Colors.red;
                            break;
                          default:
                            statusColor = Colors.orange;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: Row(
                            children: [
                              // User Name
                              Expanded(
                                flex: 2,
                                child: MyText.bodyMedium(
                                  req['user_name'] ?? '-',
                                  fontWeight: 600,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Email
                              Expanded(
                                flex: 3,
                                child: MyText.bodySmall(
                                  req['user_email'] ?? '-',
                                  muted: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Withdraw Amount
                              Expanded(
                                flex: 1,
                                child: MyText.bodyMedium(
                                  '${req['withdraw_amount'] ?? 0}',
                                  fontWeight: 700,
                                  color: contentTheme.primary,
                                ),
                              ),
                              // Wallet Total
                              Expanded(
                                flex: 1,
                                child: MyText.bodySmall(
                                  '${req['wallet_total_amount'] ?? 0}',
                                  muted: true,
                                ),
                              ),
                              // Requested At
                              Expanded(
                                flex: 2,
                                child: MyText.bodySmall(
                                  requestedAt != null
                                      ? "${requestedAt.day}/${requestedAt.month}/${requestedAt.year}"
                                      : '-',
                                  muted: true,
                                ),
                              ),
                              // Status Badge
                              Expanded(
                                flex: 2,
                                child: MyContainer(
                                  padding: MySpacing.xy(10, 5),
                                  borderRadiusAll: 12,
                                  color:
                                  statusColor.withOpacity(.15),
                                  child: MyText.bodySmall(
                                    status.toUpperCase(),
                                    color: statusColor,
                                    fontWeight: 600,
                                  ),
                                ),
                              ),
                              // Action Buttons
                              Expanded(
                                flex: 2,
                                child: status.toLowerCase() ==
                                    'pending'
                                    ? Row(
                                  children: [
                                    // Approve
                                    GestureDetector(
                                      onTap: () => _updateStatus(
                                          req['id'],
                                          'approved',
                                          index),
                                      child: MyContainer(
                                        padding:
                                        MySpacing.xy(10, 6),
                                        borderRadiusAll: 8,
                                        color: Colors.green
                                            .withOpacity(.15),
                                        child: MyText.bodySmall(
                                          "Approve",
                                          color: Colors.green,
                                          fontWeight: 600,
                                        ),
                                      ),
                                    ),
                                    MySpacing.width(6),
                                    // Reject
                                    GestureDetector(
                                      onTap: () => _updateStatus(
                                          req['id'],
                                          'rejected',
                                          index),
                                      child: MyContainer(
                                        padding:
                                        MySpacing.xy(10, 6),
                                        borderRadiusAll: 8,
                                        color: Colors.red
                                            .withOpacity(.15),
                                        child: MyText.bodySmall(
                                          "Reject",
                                          color: Colors.red,
                                          fontWeight: 600,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                    : MyText.bodySmall("—",
                                    muted: true),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}