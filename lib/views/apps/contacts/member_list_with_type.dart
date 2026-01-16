import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:webkit/controller/apps/contact/member_list_controller.dart';
import 'package:webkit/helpers/widgets/my_button.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:webkit/models/app_user.dart';
import 'package:webkit/views/apps/contacts/member_list.dart';

class MemberListWithType extends StatefulWidget {
  const MemberListWithType({super.key});

  @override
  State<MemberListWithType> createState() => _MemberListWithTypeState();
}

class _MemberListWithTypeState extends State<MemberListWithType> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // cached list
  final RxList<AppUserModel> users = <AppUserModel>[].obs;
  final RxBool loading = false.obs;

  final Color primary = const Color(0xFF835FFF);
  final Color background = const Color(0xFFEFF1FE);
  final Color accentPink = const Color(0xFFF71E64);
  final Color darkText = const Color(0xFF222222);

  final MemberListController controller = Get.put(MemberListController());

  @override
  void initState() {
    // TODO: implement initState
    fetchUsers(Get.arguments);
    super.initState();
  }

  Future<void> fetchUsers(bool? isFree) async {
    loading.value = true;

    try {
      Query query = _db.collection('users');

      // Apply filter only if isFree is NOT null
      if (isFree != null) {
        query = query.where(
          'plan_name',
          isEqualTo: isFree ? 'Standard' : 'Premium',
        );
      }

      final snapshot = await _db.collection('users').get();

      final List<AppUserModel> loaded = [];

      for (final d in snapshot.docs) {
        try {
          loaded.add(AppUserModel.fromDoc(d));
        } catch (e) {
          debugPrint('❌ Failed to parse user: ${d.id}');
          debugPrint(e.toString());
        }
      }

      users.assignAll(loaded);

      //users.assignAll(loaded);
    } catch (e) {
      debugPrint("Error loading users: $e");
    } finally {
      loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Users List"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: loading.value ? Center(child: CircularProgressIndicator(),) :  ListView.separated(
        physics: const NeverScrollableScrollPhysics(), // disable inner scrolling
        shrinkWrap: true, // allow it to take only as much height as needed
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, idx) {
          final user = users[idx];
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
      ),
    );
  }
}