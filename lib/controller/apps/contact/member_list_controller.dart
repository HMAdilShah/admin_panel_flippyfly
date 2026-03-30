// controller/member_list_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webkit/models/app_user.dart';
import 'package:webkit/models/post.dart';

class MemberListController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // cached list
  final RxList<AppUserModel> users = <AppUserModel>[].obs;
  final RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsersAndListen();
  }

  // Fetch users once and listen for realtime changes (keeps list fresh).
  void fetchUsersAndListen() {
    loading.value = true;
    _db.collection('users').snapshots().listen((snapshot) {
      final loaded = snapshot.docs.map((d) => AppUserModel.fromDoc(d)).toList();
      users.assignAll(loaded);
      loading.value = false;
    }, onError: (e) {
      loading.value = false;
      debugPrint("Error loading users: $e");
    });
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

      final snapshot = await query.get();

      final loaded =
      snapshot.docs.map((d) => AppUserModel.fromDoc(d)).toList();

      users.assignAll(loaded);
    } catch (e) {
      debugPrint("Error loading users: $e");
    } finally {
      loading.value = false;
    }
  }
  Future<void> toggleUserStatus(AppUserModel user) async {
    final isBlocked = user.userStatus.toLowerCase() == 'blocked';
    final newStatus = isBlocked ? 'active' : 'blocked';
    final action = isBlocked ? 'Unblocked' : 'Blocked';

    try {
      await _db
          .collection('users')
          .doc(user.id)
          .update({'user_status': newStatus});
      Get.snackbar(action, '${user.name} has been $action');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
  Future<List<AppUserModel>> fetchUsersOnce() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((d) => AppUserModel.fromDoc(d)).toList();
  }

  Future<void> blockUser(AppUserModel user) async {
    try {
      await _db
          .collection('users')
          .doc(user.id)
          .update({'user_status': 'blocked'});
      Get.snackbar('Blocked', '${user.name} has been blocked');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void goToDashboard() {
    Get.toNamed('/dashboard');
  }

  Future<List<Post>> fetchPosts() async {
    final snapshot = await FirebaseFirestore.instance.collection('posts').get();
    return snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList();
  }
}
