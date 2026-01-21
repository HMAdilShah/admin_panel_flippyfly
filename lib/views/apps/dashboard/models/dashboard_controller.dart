import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController(), permanent: true);
  }
}

class DashboardController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ================= LOADING =================
  RxBool isLoading = true.obs;

  // ================= USERS =================
  RxInt totalUsers = 0.obs;
  RxInt paidUsers = 0.obs;
  RxInt freeUsers = 0.obs;
  RxMap<String, int> usersByCountry = <String, int>{}.obs;
  RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;

  // ================= PLANS (CACHED) =================
  RxInt readymadeSold = 0.obs;
  RxInt customSold = 0.obs;
  RxInt specialSold = 0.obs;
  RxList<Map<String, dynamic>> popularPlans = <Map<String, dynamic>>[].obs;

  // ================= TICKETS =================
  RxInt ticketsResolved = 0.obs;
  RxInt ticketsInProgress = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  // ================= DASHBOARD LOADER =================
  Future<void> loadDashboard() async {
    isLoading.value = true;

    await Future.wait([
      fetchUsers(),
      fetchTickets(),
      loadOrCalculatePlanStats(),
    ]);

    isLoading.value = false;
  }

  // ================= USERS =================
  Future<void> fetchUsers() async {
    final snap = await firestore.collection('users').get();

    int paid = 0, free = 0;
    Map<String, int> countryMap = {};
    List<Map<String, dynamic>> list = [];

    for (var doc in snap.docs) {
      final d = doc.data();
      final plan = d['plan_name'] ?? 'Free';

      plan == 'Premium' ? paid++ : free++;

      final country = d['country'] ?? 'Unknown';
      countryMap[country] = (countryMap[country] ?? 0) + 1;

      list.add({
        'id': doc.id,
        'name': d['name'],
        'email': d['email'],
        'plan': plan,
        'created_at': d['created_at'],
      });
    }

    totalUsers.value = snap.size;
    paidUsers.value = paid;
    freeUsers.value = free;
    usersByCountry.value = countryMap;
    users.value = list;
  }

  // ================= TICKETS =================
  Future<void> fetchTickets() async {
    final snap = await firestore.collection('support_tickets').get();

    int resolved = 0, progress = 0;

    for (var d in snap.docs) {
      d['status'] == 'Resolved' ? resolved++ : progress++;
    }

    ticketsResolved.value = resolved;
    ticketsInProgress.value = progress;
  }

  // ================= PLANS (SMART CACHE) =================
  Future<void> loadOrCalculatePlanStats() async {
    final doc = firestore.collection('dashboard_stats').doc('plans');
    final snap = await doc.get();

    if (snap.exists) {
      final last = (snap['lastCalculatedAt'] as Timestamp).toDate();
      if (DateTime.now().difference(last).inMinutes < 60) {
        _applyPlanStats(snap.data()!);
        return;
      }
    }

    await _recalculatePlans(doc);
  }

  Future<void> _recalculatePlans(DocumentReference doc) async {
    int readymade = 0;
    int custom = 0;

    // Readymade = users with plan_name
    final usersSnap = await firestore.collection('users').get();
    for (var u in usersSnap.docs) {
      if (u['plan_name'] == 'Standard' || u['plan_name'] == 'Premium') {
        readymade++;
      }
    }

    // Custom = users_plan collection
    final customSnap = await firestore.collection('users_plan').get();
    custom = customSnap.size;

    // Popular plans
    Map<String, int> planCount = {};
    for (var u in usersSnap.docs) {
      final plan = u['plan_name'];
      if (plan != null) {
        planCount[plan] = (planCount[plan] ?? 0) + 1;
      }
    }

    // final popular = planCount.entries
    //     .map((e) => {'title': e.key, 'sold': e.value})
    //     .toList()
    //   ..sort((a, b) => b['sold']?.compareTo(a['sold']));
    final popular = planCount.entries
        .map((e) => {'title': e.key, 'sold': e.value})
        .toList()
      ..sort((a, b) {
        final ai = (a['sold'] as int?) ?? 0;
        final bi = (b['sold'] as int?) ?? 0;
        return bi.compareTo(ai);
      });
    final payload = {
      'readymadeSold': readymade,
      'customSold': custom,
      'specialSold': 0,
      'popularPlans': popular,
      'lastCalculatedAt': Timestamp.now(),
    };

    await doc.set(payload);
    _applyPlanStats(payload);
  }

  void _applyPlanStats(Map<String, dynamic> data) {
    readymadeSold.value = data['readymadeSold'];
    customSold.value = data['customSold'];
    specialSold.value = data['specialSold'];
    popularPlans.value = List<Map<String, dynamic>>.from(data['popularPlans']);
  }
}
