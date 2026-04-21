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

  // Per-row state: selected dropdown value and description controller
  final Map<int, String?> _selectedStatus = {};
  final Map<int, TextEditingController> _descControllers = {};
  final Map<int, RxBool> _isSaving = {};

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  @override
  void dispose() {
    for (final c in _descControllers.values) {
      c.dispose();
    }
    super.dispose();
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

      // Init per-row controllers
      _selectedStatus.clear();
      _descControllers.forEach((_, c) => c.dispose());
      _descControllers.clear();
      _isSaving.clear();
      for (int i = 0; i < withdrawRequests.length; i++) {
        _descControllers[i] = TextEditingController();
        _isSaving[i] = false.obs;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load requests: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveStatus(String docId, int index) async {
    final newStatus = _selectedStatus[index];
    final description = _descControllers[index]?.text.trim() ?? '';

    if (newStatus == null) {
      Get.snackbar('Validation', 'Please select a status.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (description.isEmpty) {
      Get.snackbar('Validation', 'Please enter a comment/description.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      _isSaving[index]?.value = true;

      await _firestore.collection('withdraw_requests').doc(docId).update({
        'status': newStatus,
        'admin_comment': description,
        'updated_at': FieldValue.serverTimestamp(),
      });

      final updated = Map<String, dynamic>.from(withdrawRequests[index]);
      updated['status'] = newStatus;
      updated['admin_comment'] = description;
      withdrawRequests[index] = updated;

      // Clear local row state (it's now locked)
      _selectedStatus.remove(index);
      _descControllers[index]?.clear();

      Get.snackbar(
        newStatus == 'approved' ? '✅ Approved' : '❌ Rejected',
        'Request has been $newStatus.\nComment: $description',
        backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      _isSaving[index]?.value = false;
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
                    MyBreadcrumbItem(name: 'Withdraw Requests', active: true),
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
                            child:
                            MyText.bodySmall("User", fontWeight: 700)),
                        Expanded(
                            flex: 3,
                            child:
                            MyText.bodySmall("Email", fontWeight: 700)),
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
                            flex: 4,
                            child: MyText.bodySmall("Admin Action",
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
                        final isPending =
                            status.toLowerCase() == 'pending';
                        final requestedAt = req['requested_at'] != null
                            ? (req['requested_at'] as Timestamp).toDate()
                            : null;
                        final adminComment =
                            req['admin_comment']?.toString() ?? '';

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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    MyContainer(
                                      padding: MySpacing.xy(10, 5),
                                      borderRadiusAll: 12,
                                      color: statusColor.withOpacity(.15),
                                      child: MyText.bodySmall(
                                        status.toUpperCase(),
                                        color: statusColor,
                                        fontWeight: 600,
                                      ),
                                    ),
                                    if (adminComment.isNotEmpty) ...[
                                      MySpacing.height(4),
                                      MyText.bodySmall(
                                        '💬 $adminComment',
                                        muted: true,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // ── Admin Action Column ──
                              Expanded(
                                flex: 4,
                                child: isPending
                                    ? _buildActionWidget(index, req['id'])
                                    : MyText.bodySmall("—", muted: true),
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

  Widget _buildActionWidget(int index, String docId) {
    _descControllers.putIfAbsent(index, () => TextEditingController());
    _isSaving.putIfAbsent(index, () => false.obs);

    return Obx(() {
      final isSaving = _isSaving[index]?.value == true;
      final selectedVal = _selectedStatus[index]; // won't react since it's a plain Map

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dropdown ──
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedVal,
                isExpanded: true,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(10),
                elevation: 3,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20, color: Colors.grey),
                hint: const Text(
                  "Select status",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                selectedItemBuilder: (context) => [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'Approve',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(Icons.cancel_rounded,
                            color: Colors.red, size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'Reject',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
                items: [
                  DropdownMenuItem(
                    value: 'approved',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.green, size: 14),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Approve',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'rejected',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.red, size: 14),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: (val) {
                  setState(() => _selectedStatus[index] = val);
                },
              ),
            ),
          ),
          if (selectedVal != null) ...[
            MySpacing.height(6),
            TextField(
              controller: _descControllers[index],
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add admin comment...',
                hintStyle: const TextStyle(fontSize: 12),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              style: const TextStyle(fontSize: 12),
            ),
            MySpacing.height(6),
          ],

          // ── Save Button ──
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: isSaving ? null : () => _saveStatus(docId, index),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                selectedVal == 'rejected' ? Colors.red : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
              ),
              child: isSaving
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text(
                'Save',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }}