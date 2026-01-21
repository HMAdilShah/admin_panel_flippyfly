import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ===== USERS =====
  RxInt totalUsers = 0.obs;
  RxInt freeUsers = 0.obs;
  RxInt paidUsers = 0.obs;
  RxMap<String, int> usersByCountry = <String, int>{}.obs;

  // Add users list for table
  RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;

  // ===== PLANS =====
  RxInt readymadeSold = 0.obs;
  RxInt customSold = 0.obs;
  RxInt specialSold = 0.obs;
  RxList<Map<String, dynamic>> popularPlans = <Map<String, dynamic>>[].obs;

  // ===== TICKETS =====
  RxInt ticketsResolved = 0.obs;
  RxInt ticketsInProgress = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    await fetchUsers();
    await fetchPlans();
    await fetchTickets();
  }

  // ================= USERS =================
  Future<void> fetchUsers() async {
    final snap = await firestore.collection('users').get();

    int free = 0;
    int paid = 0;
    Map<String, int> countryMap = {};
    List<Map<String, dynamic>> userList = [];

    for (var doc in snap.docs) {
      final data = doc.data();
      final membership = data['membership'] ?? 'Free';
      final country = data['country'] ?? 'Unknown';

      membership == 'Paid' ? paid++ : free++;

      countryMap[country] = (countryMap[country] ?? 0) + 1;

      // Store data for users table
      userList.add({
        'name': data['name'] ?? '-',
        'email': data['email'] ?? '-',
        'membership': membership,
      });
    }

    totalUsers.value = snap.size;
    freeUsers.value = free;
    paidUsers.value = paid;
    usersByCountry.value = countryMap;
    users.value = userList; // Save for table
  }

  // ================= PLANS =================
  Future<void> fetchPlans() async {
    final snap = await firestore.collection('plans').get();

    List<Map<String, dynamic>> plans = [];
    int r = 0, c = 0, s = 0;

    for (var doc in snap.docs) {
      final data = doc.data();
      int sold = data['sold'] ?? 0;
      final type = data['type'];

      if (type == 'Readymade') r += sold;
      if (type == 'Custom') c += sold;
      if (type == 'Special') s += sold;

      plans.add({
        'title': data['title'] ?? '',
        'sold': sold,
      });
    }

    plans.sort((a, b) => b['sold'].compareTo(a['sold']));

    readymadeSold.value = r;
    customSold.value = c;
    specialSold.value = s;
    popularPlans.value = plans;
  }

  // ================= TICKETS =================
  Future<void> fetchTickets() async {
    final snap = await firestore.collection('support_tickets').get();

    int resolved = 0;
    int progress = 0;

    for (var doc in snap.docs) {
      final status = doc['status'] ?? 'In Progress';
      status == 'Resolved' ? resolved++ : progress++;
    }

    ticketsResolved.value = resolved;
    ticketsInProgress.value = progress;
  }
}
