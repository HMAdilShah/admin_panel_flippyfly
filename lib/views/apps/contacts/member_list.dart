// views/apps/contacts/member_list.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webkit/controller/apps/contact/member_list_controller.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:webkit/models/app_user.dart';
import 'package:webkit/views/layouts/layout.dart';
import 'package:webkit/helpers/widgets/my_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MemberList
// ─────────────────────────────────────────────────────────────────────────────

class MemberList extends StatefulWidget {
  const MemberList({super.key});

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  final Color primary    = const Color(0xFF835FFF);
  final Color background = const Color(0xFFEFF1FE);
  final Color accentPink = const Color(0xFFF71E64);
  final Color darkText   = const Color(0xFF222222);

  final MemberListController controller = Get.put(MemberListController());

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<AppUserModel> _filter(List<AppUserModel> list) {
    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list
        .where((u) =>
    u.name.toLowerCase().contains(q) ||
        u.phone.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Container(
        color: background,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: MyText.titleLarge("User Management",
                        fontWeight: 700, color: darkText),
                  ),
                  MyButton(
                    onPressed: () => controller.goToDashboard(),
                    backgroundColor: primary,
                    borderRadiusAll: 10,
                    padding: MySpacing.xy(18, 12),
                    child: Row(children: [
                      const Icon(Icons.dashboard, color: Colors.white, size: 16),
                      MySpacing.width(8),
                      MyText.bodySmall("Dashboard", color: Colors.white),
                    ]),
                  ),
                ],
              ),
            ),
            MySpacing.height(18),

            // ── Search / actions row ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search by name or phone',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  MySpacing.width(12),
                  ElevatedButton.icon(
                    onPressed: () => _showAddUserDialog(context),  // ← change this line

                    icon: const Icon(Icons.person_add),
                    label: const Text("Add User"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            MySpacing.height(18),

            // ── Users list ───────────────────────────────────────────────────
            Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filtered = _filter(controller.users);
              if (filtered.isEmpty) {
                return Center(
                    child: MyText.bodyMedium("No users match your search."));
              }

              return ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final user   = filtered[idx];
                  final serial = idx + 1;
                  return GestureDetector(
                    onTap: () => Get.to(
                          () => ProfileViewPage(userId: user.id),
                      preventDuplicates: true,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 6))
                        ],
                        border: Border.all(color: const Color(0xFFF0EEFF)),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 6))
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Serial
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: MyText.bodyMedium("#$serial",
                                    color: primary, fontWeight: 700),
                              ),
                            ),
                            MySpacing.width(16),
                            // Avatar
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: user.avatarUrl.isNotEmpty
                                  ? NetworkImage(user.avatarUrl)
                                  : null,
                              child: user.avatarUrl.isEmpty
                                  ? const Icon(Icons.person,
                                  size: 28, color: Colors.white)
                                  : null,
                            ),
                            MySpacing.width(16),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      MyText.bodyMedium(user.name,
                                          fontWeight: 700, color: darkText),
                                      MySpacing.width(6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (user.userStatus
                                              .toLowerCase() ==
                                              'blocked'
                                              ? Colors.red
                                              : Colors.green)
                                              .withOpacity(0.15),
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: MyText.bodySmall(
                                          user.userStatus.isEmpty
                                              ? 'Active'
                                              : user.userStatus,
                                          color: user.userStatus.toLowerCase() ==
                                              'blocked'
                                              ? Colors.red
                                              : Colors.green[800],
                                          fontWeight: 600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(user.email,
                                      style: const TextStyle(
                                          color: Colors.black54),
                                      overflow: TextOverflow.ellipsis),
                                  MySpacing.height(6),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone,
                                          size: 16, color: Colors.green),
                                      MySpacing.width(6),
                                      Text(user.phone,
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Action buttons
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyButton(
                                  onPressed: () => Get.to(
                                        () => ProfileViewPage(userId: user.id),
                                    preventDuplicates: true,
                                  ),
                                  backgroundColor: primary.withOpacity(0.15),
                                  borderRadiusAll: 12,
                                  padding: MySpacing.xy(14, 10),
                                  child: MyText.bodySmall("View",
                                      color: primary, fontWeight: 700),
                                ),
                                MySpacing.height(6),
                                MyButton(
                                  onPressed: () async {
                                    final isBlocked = user.userStatus
                                        .toLowerCase() ==
                                        'blocked';
                                    final action =
                                    isBlocked ? 'Unblock' : 'Block';
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12)),
                                        title: MyText.titleMedium("Confirm",
                                            fontWeight: 700),
                                        content: MyText.bodyMedium(
                                            "$action ${user.name}?"),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(c, false),
                                              child: const Text("Cancel")),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(c, true),
                                              child: Text(action)),
                                        ],
                                      ),
                                    );
                                    if (!mounted) return;
                                    if (confirm == true)
                                      controller.toggleUserStatus(user);
                                  },
                                  backgroundColor:
                                  user.userStatus.toLowerCase() ==
                                      'blocked'
                                      ? Colors.green.withOpacity(0.15)
                                      : accentPink.withOpacity(0.15),
                                  borderRadiusAll: 12,
                                  padding: MySpacing.xy(14, 10),
                                  child: MyText.bodySmall(
                                    user.userStatus.toLowerCase() == 'blocked'
                                        ? "Unblock"
                                        : "Block",
                                    color:
                                    user.userStatus.toLowerCase() ==
                                        'blocked'
                                        ? Colors.green[700]
                                        : accentPink,
                                    fontWeight: 700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _createDummyPlans() async {
    final usersSnapshot =
    await FirebaseFirestore.instance.collection('users').get();
    for (var userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;
      for (int i = 1; i <= 3; i++) {
        final now  = DateTime.now();
        final plan = UserPlan(
          id: '',
          name: "Plan $i",
          amount: (i * 1000).toDouble(),
          paymentStatus: i % 2 == 0 ? 'paid' : 'pending',
          purchaseDate: now.subtract(Duration(days: i * 10)),
          expiryDate: now.add(Duration(days: i * 30)),
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('purchases')
            .add(plan.toMap());
        if (!mounted) return;
      }
    }
    Get.snackbar(
      "Success",
      "Dummy plans created for all users",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProfileViewPage
// ─────────────────────────────────────────────────────────────────────────────

class ProfileViewPage extends StatefulWidget {
  final String userId;
  const ProfileViewPage({super.key, required this.userId});

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Color primary    = const Color(0xFF835FFF);
  final Color background = const Color(0xFFEFF1FE);
  final Color darkText   = const Color(0xFF222222);

  Map<String, dynamic>? userData;
  List<UserPaymentPlan> plans = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => loading = true);

    final userDoc =
    await _db.collection('users').doc(widget.userId).get();
    if (!mounted) return;
    if (!userDoc.exists) {
      setState(() => loading = false);
      return;
    }

    userData = userDoc.data();

    final snap = await _db
        .collection('users_plan')
        .where('user_id', isEqualTo: widget.userId)
        .orderBy('created_at', descending: true)
        .get();
    if (!mounted) return;

    plans = snap.docs.map(UserPaymentPlan.fromDoc).toList();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text("${userData?['name'] ?? 'User'} Profile"),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _userHeader(),
            const SizedBox(height: 24),
            MyText.titleMedium("User Plans", fontWeight: 700),
            const SizedBox(height: 12),
            plans.isEmpty ? _emptyPlans() : _plansGrid(),
          ],
        ),
      ),
    );
  }

  Widget _userHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 12)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.titleLarge(userData?['name'] ?? '-',
                    fontWeight: 700),
                MyText.bodySmall(userData?['email'] ?? '-',
                    color: Colors.black54),
                MyText.bodySmall("Phone: ${userData?['phone'] ?? '-'}",
                    color: Colors.black54),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyPlans() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: MyText.bodyMedium("No plans created by this user.",
          color: Colors.black54),
    );
  }

  // ── FIX: GestureDetector correctly wraps each card inside the Wrap ─────────
  Widget _plansGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: plans.map((p) {
        return GestureDetector(
          onTap: () => Get.to(
                () => PlanDetailPage(plan: p),
            preventDuplicates: true,
          ),
          child: SizedBox(
            width: (MediaQuery.of(context).size.width - 56) / 2,
            child: _planCard(p),
          ),
        );
      }).toList(),
    );
  }

  Widget _planCard(UserPaymentPlan p) {
    final statusColor = p.availableAmount > 0 ? Colors.green : Colors.orange;
    final statusText  = p.availableAmount > 0 ? "Active" : "Expired";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          MyText.bodyMedium(p.planId, fontWeight: 700, color: darkText),
          const SizedBox(height: 6),
          MyText.bodySmall("Total Flipis: ${p.totalFlipis}",
              fontWeight: 600),
          MyText.bodySmall("Available: ${p.availableAmount}"),
          MyText.bodySmall("Duration: ${p.totalMonths} months"),
          const SizedBox(height: 6),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: MyText.bodySmall(statusText,
                color: statusColor, fontWeight: 600),
          ),
          const SizedBox(height: 6),
          // "Tap to view payments" hint
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: MyText.bodySmall(p.formattedDateTime,
                    color: Colors.black45),
              ),
              Row(
                children: [
                  Icon(Icons.receipt_long,
                      size: 13, color: primary.withOpacity(0.6)),
                  const SizedBox(width: 3),
                  MyText.bodySmall("Payments",
                      color: primary.withOpacity(0.7), fontWeight: 600),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PlanDetailPage
// ─────────────────────────────────────────────────────────────────────────────

class PlanDetailPage extends StatefulWidget {
  final UserPaymentPlan plan;
  const PlanDetailPage({super.key, required this.plan});

  @override
  State<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends State<PlanDetailPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Color primary    = const Color(0xFF835FFF);
  final Color background = const Color(0xFFEFF1FE);
  final Color darkText   = const Color(0xFF222222);
  final Color accentPink = const Color(0xFFF71E64);

  List<PaymentRecord> _records = [];
  bool   _loading   = true;
  double _totalPaid = 0;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    if (!mounted) return;
    setState(() => _loading = true);

    // Subcollection under the users_plan doc.
    // Switch to Option B if you use a top-level collection instead.
    final snap = await _db
        .collection('users_plan')
        .doc(widget.plan.docId)
        .collection('payments')
        .orderBy('payment_date', descending: true)
        .get();

    // Option B — top-level collection:
    // final snap = await _db
    //     .collection('plan_payments')
    //     .where('plan_doc_id', isEqualTo: widget.plan.docId)
    //     .orderBy('payment_date', descending: true)
    //     .get();

    if (!mounted) return;

    _records   = snap.docs.map(PaymentRecord.fromDoc).toList();
    _totalPaid = _records
        .where((r) => r.status.toLowerCase() == 'paid')
        .fold(0.0, (sum, r) => sum + r.amount);

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text("${widget.plan.planId} — Payments"),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _planSummaryCard(),
            const SizedBox(height: 20),
            _sectionTitle("Payment Records"),
            const SizedBox(height: 12),
            _records.isEmpty ? _emptyState() : _recordsList(),
          ],
        ),
      ),
    );
  }

  // ── Plan summary card ──────────────────────────────────────────────────────

  Widget _planSummaryCard() {
    final total    = widget.plan.totalFlipis.toDouble();
    final progress =
    total > 0 ? (_totalPaid / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + status badge
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.plan.planId,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkText),
                ),
              ),
              _statusBadge(
                widget.plan.availableAmount > 0 ? 'Active' : 'Expired',
                widget.plan.availableAmount > 0
                    ? Colors.green
                    : Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Stat chips
          Row(
            children: [
              _statChip("Total Flipis", "${widget.plan.totalFlipis}",
                  primary.withOpacity(0.12), primary),
              const SizedBox(width: 10),
              _statChip(
                  "Available",
                  "${widget.plan.availableAmount}",
                  Colors.green.withOpacity(0.12),
                  Colors.green[700]!),
              const SizedBox(width: 10),
              _statChip("Months", "${widget.plan.totalMonths}",
                  Colors.orange.withOpacity(0.12), Colors.orange[800]!),
            ],
          ),
          const SizedBox(height: 16),

          // Total paid row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Paid",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              Text(
                "PKR ${_totalPaid.toStringAsFixed(0)}",
                style: TextStyle(
                    color: primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${(progress * 100).toStringAsFixed(0)}% of total Flipis paid",
            style: const TextStyle(color: Colors.black45, fontSize: 12),
          ),

          if (widget.plan.formattedDateTime.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "Created: ${widget.plan.formattedDateTime}",
              style:
              const TextStyle(color: Colors.black38, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  // ── Records list ───────────────────────────────────────────────────────────

  Widget _recordsList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _recordCard(_records[i], i + 1),
    );
  }

  Widget _recordCard(PaymentRecord r, int serial) {
    final isPaid   = r.status.toLowerCase() == 'paid';
    final isFailed = r.status.toLowerCase() == 'failed';
    final statusColor =
    isPaid ? Colors.green : isFailed ? Colors.red : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Serial bubble
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              "#$serial",
              style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount + status
                Row(
                  children: [
                    Text(
                      "QAR ${r.amount.toStringAsFixed(2)}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: darkText),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(
                        r.status.isEmpty ? 'pending' : r.status,
                        statusColor),
                  ],
                ),
                const SizedBox(height: 4),

                // Date
                if (r.formattedDate.isNotEmpty || r.paymentDate != null)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 13, color: Colors.black38),
                      const SizedBox(width: 4),
                      Text(
                        r.formattedDate.isNotEmpty
                            ? r.formattedDate
                            : _fmt(r.paymentDate!),
                        style: const TextStyle(
                            color: Colors.black45, fontSize: 12),
                      ),
                    ],
                  ),

                // Method
                if (r.method.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          size: 13, color: Colors.black38),
                      const SizedBox(width: 4),
                      Text(r.method,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ],

                // Note
                if (r.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(r.note,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) => Text(
    title,
    style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: darkText),
  );

  Widget _emptyState() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12)),
    child: const Center(
      child: Text("No payment records found for this plan.",
          style: TextStyle(color: Colors.black45)),
    ),
  );

  Widget _statusBadge(String label, Color color) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600),
    ),
  );

  Widget _statChip(
      String label, String value, Color bg, Color fg) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      color: Colors.black45, fontSize: 11)),
            ],
          ),
        ),
      );

  String _fmt(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/"
          "${d.month.toString().padLeft(2, '0')}/"
          "${d.year}";
}
void _showAddUserDialog(BuildContext context) {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _formKey     = GlobalKey<FormState>();
  bool  _saving      = false;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setStateDialog) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.person_add, color: Colors.black, size: 22),
            const SizedBox(width: 8),
            Text("Add New User",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black)),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Full Name *",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                  ),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? "Name is required" : null,
                ),
                const SizedBox(height: 14),
                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email *",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Email is required";
                    if (!v.contains('@')) return "Enter a valid email";
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                // Phone
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone",
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _saving
                ? null
                : () async {
              if (!_formKey.currentState!.validate()) return;
              setStateDialog(() => _saving = true);

              await FirebaseFirestore.instance.collection('users').add({
                'name':        _nameCtrl.text.trim(),
                'email':       _emailCtrl.text.trim(),
                'phone':       _phoneCtrl.text.trim(),
                'avatar_url':  '',
                'country':     'PK',
                'user_status': 'active',
                'plan_name':   '',
                'createdAt':   FieldValue.serverTimestamp(),
              });

              // if (!mounted) return;
              Navigator.pop(ctx);
              Get.snackbar(
                "Success",
                "User added successfully",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.withOpacity(0.85),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: _saving
                ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : const Text("Add User",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

class UserPlan {
  final String id;
  final String name;
  final double amount;
  final String paymentStatus;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;

  UserPlan({
    required this.id,
    required this.name,
    required this.amount,
    required this.paymentStatus,
    this.purchaseDate,
    this.expiryDate,
  });

  factory UserPlan.fromMap(String id, Map<String, dynamic> map) {
    return UserPlan(
      id: id,
      name: map['plan_name'] ?? 'Unnamed Plan',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentStatus: map['payment_status'] ?? 'pending',
      purchaseDate: map['purchase_date'] != null
          ? (map['purchase_date'] as Timestamp).toDate()
          : null,
      expiryDate: map['expiry_date'] != null
          ? (map['expiry_date'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'plan_name': name,
    'amount': amount,
    'payment_status': paymentStatus,
    'purchase_date': purchaseDate != null
        ? Timestamp.fromDate(purchaseDate!)
        : null,
    'expiry_date':
    expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
  };
}

class UserPaymentPlan {
  final String docId;
  final String planId;
  final int totalFlipis;
  final double availableAmount;
  final int totalMonths;
  final String monthlyPayment;
  final List<String> schedule;
  final DateTime? createdAt;
  final String formattedDateTime;

  UserPaymentPlan({
    required this.docId,
    required this.planId,
    required this.totalFlipis,
    required this.availableAmount,
    required this.totalMonths,
    required this.monthlyPayment,
    required this.schedule,
    this.createdAt,
    required this.formattedDateTime,
  });

  factory UserPaymentPlan.fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return UserPaymentPlan(
      docId: doc.id,
      planId: map['plan_id'] ?? '----',
      totalFlipis: map['total_flipis'] ?? 0,
      availableAmount: (map['available_amount'] ?? 0).toDouble(),
      totalMonths: map['total_months'] ?? 0,
      monthlyPayment: map['monthly_payment'] ?? '0',
      schedule: (map['schedule'] as List?)?.cast<String>() ?? [],
      createdAt: map['created_at'] != null
          ? (map['created_at'] as Timestamp).toDate()
          : null,
      formattedDateTime: map['formatted_date_time'] ?? '',
    );
  }
}

class PaymentRecord {
  final String docId;
  final double amount;
  final String status;   // 'paid' | 'pending' | 'failed'
  final String method;   // 'cash' | 'bank_transfer' | 'easypaisa' …
  final String note;
  final DateTime? paymentDate;
  final String formattedDate;

  PaymentRecord({
    required this.docId,
    required this.amount,
    required this.status,
    required this.method,
    required this.note,
    this.paymentDate,
    required this.formattedDate,
  });

  factory PaymentRecord.fromDoc(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return PaymentRecord(
      docId: doc.id,
      amount: (m['amount'] ?? 0).toDouble(),
      status: m['status'] ?? 'pending',
      method: m['payment_method'] ?? '',
      note: m['note'] ?? '',
      paymentDate: m['payment_date'] != null
          ? (m['payment_date'] as Timestamp).toDate()
          : null,
      formattedDate: m['formatted_date'] ?? '',
    );
  }
}