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

class MemberList extends StatefulWidget {
  const MemberList({super.key});

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  final Color primary = const Color(0xFF835FFF);
  final Color background = const Color(0xFFEFF1FE);
  final Color accentPink = const Color(0xFFF71E64);
  final Color darkText = const Color(0xFF222222);

  final MemberListController controller = Get.put(MemberListController());

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<AppUserModel> _filter(List<AppUserModel> list) {
    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((u) {
      return (u.name.toLowerCase().contains(q) || u.phone.toLowerCase().contains(q));
    }).toList();
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: MyText.titleLarge("User Management", fontWeight: 700, color: darkText),
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

            // Search / actions row
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
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                    onPressed: () {
                      FirebaseFirestore.instance.collection('users').add({
                        'name': 'Demo User ${DateTime.now().millisecondsSinceEpoch % 1000}',
                        'email': 'demo${DateTime.now().millisecondsSinceEpoch % 1000}@example.com',
                        'phone': '+92 300 000 0000',
                        'avatar_url': '',
                        'country': 'PK',
                        'user_status': 'active',
                        'plan_name': '',
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add User"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                /*  ElevatedButton.icon(
                    onPressed: () async {
                      // Call function to create dummy plans for all users
                      await _createDummyPlans();
                    },
                    icon: const Icon(Icons.add_chart),
                    label: const Text("Create Dummy Plans"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),*/

                ],
              ),
            ),

            MySpacing.height(18),

            // Users list
            // Users list
            Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filtered = _filter(controller.users);
              if (filtered.isEmpty) {
                return Center(child: MyText.bodyMedium("No users match your search."));
              }

              return ListView.separated(
                physics: const NeverScrollableScrollPhysics(), // disable inner scrolling
                shrinkWrap: true, // allow it to take only as much height as needed
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final user = filtered[idx];
                  final serial = idx + 1;
                  return GestureDetector(
                    onTap: () => Get.to(() => ProfileViewPage(userId: user.id),
                      preventDuplicates: true,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
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
                              offset: const Offset(0, 6),
                            ),
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
                                child: MyText.bodyMedium("#$serial", color: primary, fontWeight: 700),
                              ),
                            ),
                            MySpacing.width(16),

                            // Avatar
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                              child: user.avatarUrl.isEmpty
                                  ? const Icon(Icons.person, size: 28, color: Colors.white)
                                  : null,
                            ),
                            MySpacing.width(16),

                            // Info Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name
                                  Row(
                                    children: [
                                      MyText.bodyMedium(user.name, fontWeight: 700, color: darkText),
                                      MySpacing.width(6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (user.userStatus.toLowerCase() == 'blocked' ? Colors.red : Colors.green).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: MyText.bodySmall(
                                          user.userStatus.isEmpty ? 'Active' : user.userStatus,
                                          color: user.userStatus.toLowerCase() == 'blocked' ? Colors.red : Colors.green[800],
                                          fontWeight: 600,
                                        ),
                                      ),
                                    ],
                                  ),


                                  // Email
                                  Text(user.email, style: const TextStyle(color: Colors.black54), overflow: TextOverflow.ellipsis),
                                  MySpacing.height(6),

                                  // Phone with icon
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 16, color: Colors.green),
                                      MySpacing.width(6),
                                      Text(user.phone, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Status + Buttons Column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // View Button
                                MyButton(
                                  onPressed: () => Get.to(() => ProfileViewPage(userId: user.id),
                                    preventDuplicates: true,),
                                  backgroundColor: primary.withOpacity(0.15),
                                  borderRadiusAll: 12,
                                  padding: MySpacing.xy(14, 10),
                                  child: MyText.bodySmall("View", color: primary, fontWeight: 700),
                                ),
                                MySpacing.height(6),

                                // Block Button
                                MyButton(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        title: MyText.titleMedium("Confirm", fontWeight: 700),
                                        content: MyText.bodyMedium("Block ${user.name}?"),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
                                          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Block")),
                                        ],
                                      ),
                                    );
                                    if (!mounted) return;   // Add this
                                    if (confirm == true) controller.blockUser(user);
                                  },
                                  backgroundColor: accentPink.withOpacity(0.15),
                                  borderRadiusAll: 12,
                                  padding: MySpacing.xy(14, 10),
                                  child: MyText.bodySmall("Block", color: accentPink, fontWeight: 700),
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
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

    for (var userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;

      // Generate 2-3 dummy plans per user
      for (int i = 1; i <= 3; i++) {
        final now = DateTime.now();
        final plan = UserPlan(
          id: '', // Firestore will generate ID
          name: "Plan $i",
          amount: (i * 1000).toDouble(),
          paymentStatus: i % 2 == 0 ? 'paid' : 'pending',
          purchaseDate: now.subtract(Duration(days: i * 10)),
          expiryDate: now.add(Duration(days: i * 30)),
        );

        // Add to subcollection 'purchases' for each user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('purchases')
            .add(plan.toMap());
        if (!mounted) return; // <-- add after await

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

class ProfileViewPage extends StatefulWidget {
  final String userId;
  const ProfileViewPage({super.key, required this.userId});

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Color primary = const Color(0xFF835FFF);
  final Color background = const Color(0xFFEFF1FE);
  final Color darkText = const Color(0xFF222222);

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

    final userDoc = await _db.collection('users').doc(widget.userId).get();
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

    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text("${userData?['name'] ?? 'User'} Profile"),
        backgroundColor: primary,
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
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
                MyText.titleLarge(userData?['name'] ?? '-', fontWeight: 700),
                MyText.bodySmall(userData?['email'] ?? '-', color: Colors.black54),
                MyText.bodySmall("Phone: ${userData?['phone'] ?? '-'}", color: Colors.black54),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: MyText.bodyMedium("No plans created by this user.", color: Colors.black54),
    );
  }
  Widget _plansGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: plans.map((p) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 56) / 2, // two cards per row with spacing
          child: _planCard(p),
        );
      }).toList(),
    );
  }


  Widget _planCard(UserPaymentPlan p) {
    final statusColor = p.availableAmount > 0 ? Colors.green : Colors.orange;
    final statusText = p.availableAmount > 0 ? "Active" : "Expired";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // important: shrink to fit content
        children: [
          // Plan Name
          MyText.bodyMedium(p.planId, fontWeight: 700, color: darkText),
          const SizedBox(height: 6),

          // Amount & Months
          MyText.bodySmall("Total Flipis: ${p.totalFlipis}", fontWeight: 600),
          MyText.bodySmall("Available: ${p.availableAmount}"),
          MyText.bodySmall("Duration: ${p.totalMonths} months"),
          const SizedBox(height: 6),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: MyText.bodySmall(statusText, color: statusColor, fontWeight: 600),
          ),

          const SizedBox(height: 6),

          // Date
          Align(
            alignment: Alignment.bottomRight,
            child: MyText.bodySmall(
              p.formattedDateTime,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}


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
      purchaseDate: map['purchase_date'] != null ? (map['purchase_date'] as Timestamp).toDate() : null,
      expiryDate: map['expiry_date'] != null ? (map['expiry_date'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plan_name': name,
      'amount': amount,
      'payment_status': paymentStatus,
      'purchase_date': purchaseDate != null ? Timestamp.fromDate(purchaseDate!) : null,
      'expiry_date': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
    };
  }
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

