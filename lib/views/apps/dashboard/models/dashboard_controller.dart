import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController(), permanent: true);
  }
}

class DashboardController extends GetxController {
  // ================= TRANSACTIONS & REVENUE =================
  RxList<Map<String, dynamic>> cachedTransactions = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> cachedUserLedgers = <Map<String, dynamic>>[].obs;

  RxDouble totalRevenue = 0.0.obs;
  RxDouble pendingRevenue = 0.0.obs;
  RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> userLedgers = <Map<String, dynamic>>[].obs;


  RxMap<String, double> monthlyRevenue = <String, double>{}.obs;
  RxList<Map<String, dynamic>> activeMemberships = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> pendingPayments = <Map<String, dynamic>>[].obs;


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

    // Run independent tasks in parallel
    await Future.wait([
      fetchUsers(),
      fetchTickets(),
      loadOrCalculatePlanStats(),
      fetchTransactions(),
    ]);

    // These depend on transactions, so run sequentially
    await calculateUserLedgers();
    await generateBusinessReports();

    await loadFinancialReports();

    isLoading.value = false;
  }

  Future<void> loadFinancialReports() async {
    final metaDoc =
    firestore.collection('dashboard_financial_meta').doc('financial_cache');

    final snap = await metaDoc.get();

    bool shouldRecalculate = true;

    if (snap.exists) {
      final last = (snap['lastCalculatedAt'] as Timestamp).toDate();
      if (DateTime.now().difference(last).inHours < 12) {
        shouldRecalculate = false;
      }
    }

    if (shouldRecalculate) {
      await recalculateFinancialReports(metaDoc);
    } else {
      await loadCachedReports();
    }
  }

  Future<void> loadCachedReports() async {
    final txSnap =
    await firestore.collection('dashboard_transactions').get();

    final ledgerSnap =
    await firestore.collection('dashboard_user_ledgers').get();

    cachedTransactions.value =
        txSnap.docs.map((d) => d.data()).toList();

    cachedUserLedgers.value =
        ledgerSnap.docs.map((d) => d.data()).toList();
  }
  Future<void> recalculateFinancialReports(DocumentReference metaDoc) async {
    List<Map<String, dynamic>> allTransactions = [];
    Map<String, Map<String, dynamic>> ledgerMap = {};

    // ================= MEMBERSHIP =================
    final usersSnap = await firestore.collection('users').get();
    Map<String, Map<String, dynamic>> userMap = {
      for (var u in usersSnap.docs) u.id: u.data()
    };
    for (var doc in usersSnap.docs) {
      final u = doc.data();

      if (u['plan_name'] == 'Premium') {
        final tx = {
          'userId': doc.id,
          'userName': u['name'],
          'email': u['email'],
          'planType': 'membership',
          'planName': 'Premium',
          'amount': 5.0,
          'status': 'completed',
          'date': u['plan_start_date'],
          'expiryDate': u['plan_renewal_date'],
        };

        allTransactions.add(tx);
      }
    }

    // ================= READYMADE =================
    final readymadeSnap =
    await firestore.collection('users_readymate_plan').get();

    for (var doc in readymadeSnap.docs) {
      final d = doc.data();

      final tx = {
        'userId': d['user_id'],
        'userName': userMap[d['user_id']]?['name'] ?? 'Unknown',
        'email': d['user_email'],
        'planType': 'readymade',
        'planName': d['title'],
        'amount': (d['total_flipis'] ?? 0).toDouble(),
        'status': 'completed',
        'date': d['created_at'],
        'expiryDate': d['expiryDate'],
      };

      allTransactions.add(tx);
    }

    // ================= CUSTOM PLANS =================
    final customSnap =
    await firestore.collection('users_plan').get();

    for (var doc in customSnap.docs) {
      final d = doc.data();

      double paid =
          double.tryParse(d['paid_flipis_amount'].toString()) ?? 0;

      double remaining =
      (d['remaining_flipis_amount'] ?? 0).toDouble();

      if (paid > 0) {
        allTransactions.add({
          'userId': d['user_id'],
          'userName': userMap[d['user_id']]?['name'] ?? 'Unknown',
          'email': d['user_email'],
          'planType': 'custom',
          'planName': d['plan_id'],
          'amount': paid,
          'status': 'completed',
          'date': d['created_at'],
          'expiryDate': null,
        });
      }

      if (remaining > 0) {
        allTransactions.add({
          'userId': d['user_id'],
          'userName': userMap[d['user_id']]?['name'] ?? 'Unknown',
          'email': d['user_email'],
          'planType': 'custom',
          'planName': d['plan_id'],
          'amount': remaining,
          'status': 'pending',
          'date': d['created_at'],
          'expiryDate': null,
        });
      }
    }

    // ================= BUILD LEDGER =================
    for (var tx in allTransactions) {
      final uid = tx['userId'];

      ledgerMap.putIfAbsent(uid, () => {
        'userId': uid,
        'userName': tx['userName'] ?? 'Unknown',
        'email': tx['email'],
        'totalPaid': 0.0,
        'pending': 0.0,
        'transactions': [],
      });

      if (tx['status'] == 'completed') {
        ledgerMap[uid]!['totalPaid'] += tx['amount'];
      } else {
        ledgerMap[uid]!['pending'] += tx['amount'];
      }

      ledgerMap[uid]!['transactions'].add(tx);
    }

    // ================= SAVE TO CACHE =================
    final batch = firestore.batch();

    // Clear old
    final oldTx = await firestore.collection('dashboard_transactions').get();
    for (var d in oldTx.docs) {
      batch.delete(d.reference);
    }

    final oldLedger =
    await firestore.collection('dashboard_user_ledgers').get();
    for (var d in oldLedger.docs) {
      batch.delete(d.reference);
    }

    for (var tx in allTransactions) {
      batch.set(
          firestore.collection('dashboard_transactions').doc(), tx);
    }

    for (var l in ledgerMap.values) {
      batch.set(
          firestore.collection('dashboard_user_ledgers').doc(l['userId']),
          l);
    }

    batch.set(metaDoc, {
      'lastCalculatedAt': Timestamp.now(),
    });

    await batch.commit();

    cachedTransactions.value = allTransactions;
    cachedUserLedgers.value = ledgerMap.values.toList();
  }

  Future<void> fetchTransactions() async {
    final snap = await firestore
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    double total = 0;
    double pending = 0;

    List<Map<String, dynamic>> list = [];

    for (var doc in snap.docs) {
      final d = doc.data();

      double amount = (d['amount'] ?? 0).toDouble();
      String status = d['status'] ?? 'pending';

      if (status == 'completed') {
        total += amount;
      } else {
        pending += amount;
      }

      list.add({
        'id': doc.id,
        'userId': d['userId'],
        // 'userName': d['userName'] ?? '',
        'userName': d['userName'] ?? d['name'] ?? 'Unknown',

        'email': d['email'] ?? '',
        'planName': d['plan_name'],
        'planType': d['type'] ?? 'membership',
        'amount': amount,
        'status': status,
        'paymentMethod': d['payment_method'] ?? 'unknown',
        'transactionId': d['transaction_id'] ?? '',
        'date': d['date'],
        'expiryDate': d['expiry_date'],
      });
    }

    transactions.value = list;
    totalRevenue.value = total;
    pendingRevenue.value = pending;
  }

  Future<void> calculateUserLedgers() async {
    Map<String, Map<String, dynamic>> ledgerMap = {};

    for (var tx in transactions) {
      String uid = tx['userId'] ?? '';

      if (uid.isEmpty) continue;

      ledgerMap.putIfAbsent(uid, () => {
        'userId': uid,
        'userName': tx['userName'] ?? 'Unknown',

        'email': tx['email'] ?? '',
        'totalPaid': 0.0,
        'pending': 0.0,
        'activePlans': <Map<String, dynamic>>[],
        'expiredPlans': <Map<String, dynamic>>[],
        'transactions': <Map<String, dynamic>>[],
      });

      double amount = (tx['amount'] ?? 0).toDouble();
      String status = tx['status'] ?? 'pending';

      if (status == 'completed') {
        ledgerMap[uid]!['totalPaid'] += amount;
      } else {
        ledgerMap[uid]!['pending'] += amount;
      }

      // Expiry Handling
      if (tx['expiryDate'] != null && tx['expiryDate'] is Timestamp) {
        DateTime expiry = (tx['expiryDate'] as Timestamp).toDate();

        if (expiry.isAfter(DateTime.now())) {
          ledgerMap[uid]!['activePlans'].add(tx);
        } else {
          ledgerMap[uid]!['expiredPlans'].add(tx);
        }
      }

      ledgerMap[uid]!['transactions'].add(tx);
    }

    userLedgers.value = ledgerMap.values.map((e) {
      return {
        ...e,
        'transactions': e['transactions'] ?? [],
        'activePlans': e['activePlans'] ?? [],
        'expiredPlans': e['expiredPlans'] ?? [],
      };
    }).toList();
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


  Future<void> generateBusinessReports() async {
    Map<String, double> monthMap = {};
    List<Map<String, dynamic>> active = [];
    List<Map<String, dynamic>> pending = [];

    for (var tx in transactions) {
      // Monthly revenue
      if (tx['date'] != null) {
        DateTime d = (tx['date'] as Timestamp).toDate();
        String key = "${d.year}-${d.month}";

        monthMap[key] = (monthMap[key] ?? 0) + tx['amount'];
      }

      // Pending payments
      if (tx['status'] != 'completed') {
        pending.add(tx);
      }

      // Active memberships
      if (tx['expiryDate'] != null) {
        DateTime exp = (tx['expiryDate'] as Timestamp).toDate();
        if (exp.isAfter(DateTime.now())) {
          active.add(tx);
        }
      }
    }

    monthlyRevenue.value = monthMap;
    pendingPayments.value = pending;
    activeMemberships.value = active;
  }

}
