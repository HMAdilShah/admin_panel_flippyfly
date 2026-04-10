import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController(), permanent: true);
  }
}

class DashboardController extends GetxController {

  static const double myFatoorahFeePercent = 2.5;

  // ================= REPORTS =================
  RxDouble membershipTotal = 0.0.obs;
  RxDouble membershipFatoorahFee = 0.0.obs;
  RxDouble membershipProfit = 0.0.obs;
  RxDouble customTotal = 0.0.obs;
  RxDouble customFatoorahFee = 0.0.obs;
  RxDouble customProfit = 0.0.obs;
  RxDouble readymadeTotal = 0.0.obs;
  RxDouble readymadeFatoorahFee = 0.0.obs;
  RxDouble readymadeProfit = 0.0.obs;
  RxList<Map<String, dynamic>> reportTransactions = <Map<String, dynamic>>[].obs;
  final Rx<DateTime?> filterFrom = Rx<DateTime?>(null);
  final Rx<DateTime?> filterTo = Rx<DateTime?>(null);
  final RxString filterPeriod = 'all'.obs;
  final RxString filterUserId = ''.obs;

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

  // ================= WITHDRAW REQUESTS =================
  final withdrawRequests = <Map<String, dynamic>>[].obs;

  // ================= PLANS =================
  RxInt readymadeSold = 0.obs;
  RxInt customSold = 0.obs;
  RxInt specialSold = 0.obs;
  RxList<Map<String, dynamic>> popularPlans = <Map<String, dynamic>>[].obs;

  // ================= TICKETS =================
  RxInt ticketsResolved = 0.obs;
  RxInt ticketsInProgress = 0.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  static List<Map<String, dynamic>> _castList(dynamic raw) {
    if (raw == null) return [];
    return (raw as List<dynamic>)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static const Map<String, String> _countryCodeToName = {
    'AF': 'Afghanistan', 'AL': 'Albania', 'DZ': 'Algeria',
    'AR': 'Argentina', 'AU': 'Australia', 'AT': 'Austria',
    'AZ': 'Azerbaijan', 'BH': 'Bahrain', 'BD': 'Bangladesh',
    'BE': 'Belgium', 'BR': 'Brazil', 'CA': 'Canada',
    'CN': 'China', 'CO': 'Colombia', 'HR': 'Croatia',
    'CY': 'Cyprus', 'CZ': 'Czech Republic', 'DK': 'Denmark',
    'EG': 'Egypt', 'ET': 'Ethiopia', 'FI': 'Finland',
    'FR': 'France', 'GE': 'Georgia', 'DE': 'Germany',
    'GH': 'Ghana', 'GR': 'Greece', 'HK': 'Hong Kong',
    'HU': 'Hungary', 'IN': 'India', 'ID': 'Indonesia',
    'IR': 'Iran', 'IQ': 'Iraq', 'IE': 'Ireland',
    'IL': 'Israel', 'IT': 'Italy', 'JP': 'Japan',
    'JO': 'Jordan', 'KZ': 'Kazakhstan', 'KE': 'Kenya',
    'KW': 'Kuwait', 'LB': 'Lebanon', 'LY': 'Libya',
    'MY': 'Malaysia', 'MV': 'Maldives', 'MX': 'Mexico',
    'MA': 'Morocco', 'MM': 'Myanmar', 'NP': 'Nepal',
    'NL': 'Netherlands', 'NZ': 'New Zealand', 'NG': 'Nigeria',
    'NO': 'Norway', 'OM': 'Oman', 'PK': 'Pakistan',
    'PS': 'Palestine', 'PE': 'Peru', 'PH': 'Philippines',
    'PL': 'Poland', 'PT': 'Portugal', 'QA': 'Qatar',
    'RO': 'Romania', 'RU': 'Russia', 'SA': 'Saudi Arabia',
    'SN': 'Senegal', 'RS': 'Serbia', 'SG': 'Singapore',
    'ZA': 'South Africa', 'KR': 'South Korea', 'ES': 'Spain',
    'LK': 'Sri Lanka', 'SD': 'Sudan', 'SE': 'Sweden',
    'CH': 'Switzerland', 'SY': 'Syria', 'TW': 'Taiwan',
    'TZ': 'Tanzania', 'TH': 'Thailand', 'TN': 'Tunisia',
    'TR': 'Turkey', 'UG': 'Uganda', 'UA': 'Ukraine',
    'AE': 'United Arab Emirates', 'GB': 'United Kingdom',
    'US': 'United States', 'UZ': 'Uzbekistan', 'VE': 'Venezuela',
    'VN': 'Vietnam', 'YE': 'Yemen', 'ZM': 'Zambia', 'ZW': 'Zimbabwe',
  };

  String _normalizeCountry(dynamic raw) {
    if (raw == null || raw.toString().trim().isEmpty) return 'Unknown';
    final str = raw.toString().trim();
    final upper = str.toUpperCase();
    if (upper.length == 2 && _countryCodeToName.containsKey(upper)) {
      return _countryCodeToName[upper]!;
    }
    return str;
  }

  // ================= INIT =================
  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  // ================= DASHBOARD LOADER (single definition) =================
  Future<void> loadDashboard() async {
    isLoading.value = true;
    await Future.wait([
      fetchUsers(),
      fetchTickets(),
      loadOrCalculatePlanStats(),
      fetchTransactions(),
      fetchWithdrawRequests(),
      fetchRevenueReport(),
    ]);
    await calculateUserLedgers();
    await generateBusinessReports();
    await loadFinancialReports();
    isLoading.value = false;
  }

  // ================= WITHDRAW REQUESTS =================
  Future<void> fetchWithdrawRequests() async {
    try {
      final snap = await firestore
          .collection('withdraw_requests')
          .orderBy('requested_at', descending: true)
          .get();
      withdrawRequests.value =
          snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      print('Error fetching withdraw requests: $e');
    }
  }

  // ================= REVENUE REPORT =================
  Future<void> fetchRevenueReport() async {
    try {
      List<Map<String, dynamic>> all = [];

      // 1. Membership
      final usersSnap = await firestore.collection('users').get();
      for (var doc in usersSnap.docs) {
        final d = Map<String, dynamic>.from(doc.data());
        if (d['plan_name'] == 'Premium') {
          all.add({
            'userId': doc.id,
            'userName': d['name'] ?? 'Unknown',
            'type': 'membership',
            'amount': 5.0,
            'status': 'completed',
            'date': d['plan_start_date'],
          });
        }
      }

      // 2. Readymade Plans
      final readymadeSnap =
      await firestore.collection('users_readymate_plan').get();
      for (var doc in readymadeSnap.docs) {
        final d = Map<String, dynamic>.from(doc.data());
        final amount = (d['total_flipis'] ?? 0).toDouble();
        if (amount > 0) {
          all.add({
            'userId': d['user_id'] ?? '',
            'userName': d['user_name'] ?? 'Unknown',
            'type': 'readymade',
            'amount': amount,
            'status': 'completed',
            'date': d['created_at'],
          });
        }
      }

      // 3. Custom Plans
      final customSnap = await firestore.collection('users_plan').get();
      for (var doc in customSnap.docs) {
        final d = Map<String, dynamic>.from(doc.data());
        final payments = (d['payments'] as List? ?? []);
        for (var p in payments) {
          final pMap = Map<String, dynamic>.from(p as Map);
          final status = (pMap['status'] ?? '').toString().toLowerCase();
          final amount = (pMap['amount'] ?? 0).toDouble();
          if (amount > 0) {
            all.add({
              'userId': d['user_id'] ?? '',
              'userName': d['user_name'] ?? 'Unknown',
              'type': 'custom',
              'amount': amount,
              'status': status == 'paid' ? 'completed' : 'pending',
              'date': pMap['date'] ?? d['created_at'],
            });
          }
        }
      }

      reportTransactions.value = all;
      _calculateReportTotals(all);
    } catch (e) {
      print('Error fetching revenue report: $e');
    }
  }

  void _calculateReportTotals(List<Map<String, dynamic>> txList) {
    final filtered = _applyReportFilters(txList);
    double mTotal = 0, cTotal = 0, rTotal = 0;

    for (var tx in filtered) {
      if (tx['status'] != 'completed') continue;
      final amount = (tx['amount'] as num).toDouble();
      switch (tx['type']) {
        case 'membership':
          mTotal += amount;
          break;
        case 'custom':
          cTotal += amount;
          break;
        case 'readymade':
          rTotal += amount;
          break;
      }
    }

    double fee(double total) => (total * myFatoorahFeePercent) / 100;

    membershipTotal.value = mTotal;
    membershipFatoorahFee.value = fee(mTotal);
    membershipProfit.value = mTotal - fee(mTotal);

    customTotal.value = cTotal;
    customFatoorahFee.value = fee(cTotal);
    customProfit.value = cTotal - fee(cTotal);

    readymadeTotal.value = rTotal;
    readymadeFatoorahFee.value = fee(rTotal);
    readymadeProfit.value = rTotal - fee(rTotal);
  }

  List<Map<String, dynamic>> _applyReportFilters(
      List<Map<String, dynamic>> txList) {
    DateTime? from;
    DateTime? to;
    final now = DateTime.now();

    switch (filterPeriod.value) {
      case 'today':
        from = DateTime(now.year, now.month, now.day);
        to = now;
        break;
      case 'week':
        from = now.subtract(const Duration(days: 7));
        to = now;
        break;
      case 'month':
        from = DateTime(now.year, now.month, 1);
        to = now;
        break;
      case 'custom':
        from = filterFrom.value;
        to = filterTo.value;
        break;
      default:
        from = null;
        to = null;
    }

    return txList.where((tx) {
      if (from != null || to != null) {
        DateTime? txDate;
        if (tx['date'] is Timestamp) {
          txDate = (tx['date'] as Timestamp).toDate();
        }
        if (txDate == null) return false;
        if (from != null && txDate.isBefore(from)) return false;
        if (to != null && txDate.isAfter(to)) return false;
      }
      if (filterUserId.value.isNotEmpty &&
          tx['userId'] != filterUserId.value) {
        return false;
      }
      return true;
    }).toList();
  }

  void applyReportFilter(String period,
      {DateTime? from, DateTime? to, String userId = ''}) {
    filterPeriod.value = period;
    filterFrom.value = from;
    filterTo.value = to;
    filterUserId.value = userId;
    _calculateReportTotals(reportTransactions);
  }

  // ================= FINANCIAL REPORTS =================
  Future<void> loadFinancialReports() async {
    final metaDoc = firestore
        .collection('dashboard_financial_meta')
        .doc('financial_cache');
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

    cachedTransactions.value = txSnap.docs
        .map((d) => Map<String, dynamic>.from(d.data()))
        .toList();

    cachedUserLedgers.value = ledgerSnap.docs.map((d) {
      final map = Map<String, dynamic>.from(d.data());
      map['transactions'] = _castList(map['transactions']);
      return map;
    }).toList();
  }

  Future<void> recalculateFinancialReports(
      DocumentReference metaDoc) async {
    List<Map<String, dynamic>> allTransactions = [];
    Map<String, Map<String, dynamic>> ledgerMap = {};

    final usersSnap = await firestore.collection('users').get();
    Map<String, Map<String, dynamic>> userMap = {
      for (var u in usersSnap.docs)
        u.id: Map<String, dynamic>.from(u.data())
    };

    for (var doc in usersSnap.docs) {
      final u = Map<String, dynamic>.from(doc.data());
      if (u['plan_name'] == 'Premium') {
        allTransactions.add({
          'userId': doc.id,
          'userName': u['name'],
          'email': u['email'],
          'planType': 'membership',
          'planName': 'Premium',
          'amount': 5.0,
          'status': 'completed',
          'date': u['plan_start_date'],
          'expiryDate': u['plan_renewal_date'],
        });
      }
    }

    final readymadeSnap =
    await firestore.collection('users_readymate_plan').get();
    for (var doc in readymadeSnap.docs) {
      final d = Map<String, dynamic>.from(doc.data());
      allTransactions.add({
        'userId': d['user_id'],
        'userName': userMap[d['user_id']]?['name'] ?? 'Unknown',
        'email': d['user_email'],
        'planType': 'readymade',
        'planName': d['title'],
        'amount': (d['total_flipis'] ?? 0).toDouble(),
        'status': 'completed',
        'date': d['created_at'],
        'expiryDate': d['expiryDate'],
      });
    }

    final customSnap = await firestore.collection('users_plan').get();
    for (var doc in customSnap.docs) {
      final d = Map<String, dynamic>.from(doc.data());
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

    for (var tx in allTransactions) {
      final uid = (tx['userId'] ?? '').toString();
      if (uid.isEmpty) continue;

      ledgerMap.putIfAbsent(uid, () => {
        'userId': uid,
        'userName': tx['userName'] ?? 'Unknown',
        'email': tx['email'] ?? '',
        'totalPaid': 0.0,
        'pending': 0.0,
        'transactions': <Map<String, dynamic>>[],
      });

      if (tx['status'] == 'completed') {
        ledgerMap[uid]!['totalPaid'] += tx['amount'];
      } else {
        ledgerMap[uid]!['pending'] += tx['amount'];
      }
      (ledgerMap[uid]!['transactions'] as List<Map<String, dynamic>>)
          .add(tx);
    }

    final batch = firestore.batch();
    final oldTx =
    await firestore.collection('dashboard_transactions').get();
    for (var d in oldTx.docs) batch.delete(d.reference);
    final oldLedger =
    await firestore.collection('dashboard_user_ledgers').get();
    for (var d in oldLedger.docs) batch.delete(d.reference);
    for (var tx in allTransactions) {
      batch.set(
          firestore.collection('dashboard_transactions').doc(), tx);
    }
    for (var l in ledgerMap.values) {
      batch.set(
        firestore
            .collection('dashboard_user_ledgers')
            .doc(l['userId'] as String),
        l,
      );
    }
    batch.set(metaDoc, {'lastCalculatedAt': Timestamp.now()});
    await batch.commit();

    cachedTransactions.value = allTransactions;
    cachedUserLedgers.value = ledgerMap.values.toList();
  }

  // ================= FETCH TRANSACTIONS =================
  Future<void> fetchTransactions() async {
    final snap = await firestore
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    double total = 0;
    double pending = 0;
    List<Map<String, dynamic>> list = [];

    for (var doc in snap.docs) {
      final d = Map<String, dynamic>.from(doc.data());
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

  // ================= USER LEDGERS =================
  Future<void> calculateUserLedgers() async {
    Map<String, Map<String, dynamic>> ledgerMap = {};

    for (var tx in transactions) {
      String uid = (tx['userId'] ?? '').toString();
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

      if (tx['expiryDate'] != null && tx['expiryDate'] is Timestamp) {
        DateTime expiry = (tx['expiryDate'] as Timestamp).toDate();
        if (expiry.isAfter(DateTime.now())) {
          (ledgerMap[uid]!['activePlans'] as List<Map<String, dynamic>>)
              .add(tx);
        } else {
          (ledgerMap[uid]!['expiredPlans'] as List<Map<String, dynamic>>)
              .add(tx);
        }
      }
      (ledgerMap[uid]!['transactions'] as List<Map<String, dynamic>>)
          .add(tx);
    }

    userLedgers.value = ledgerMap.values.map((e) {
      return {
        ...e,
        'transactions': e['transactions'] as List<Map<String, dynamic>>,
        'activePlans': e['activePlans'] as List<Map<String, dynamic>>,
        'expiredPlans': e['expiredPlans'] as List<Map<String, dynamic>>,
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
      final d = Map<String, dynamic>.from(doc.data());
      final plan = d['plan_name'] ?? 'Free';
      plan == 'Premium' ? paid++ : free++;
      final country = _normalizeCountry(d['country']);
      countryMap[country] = (countryMap[country] ?? 0) + 1;
      final List<Map<String, dynamic>> purchases = _castList(d['purchases']);
      list.add({
        'id': doc.id,
        'name': d['name'] ?? 'Unknown',
        'email': d['email'] ?? '',
        'plan_name': plan,
        'country': country,
        'avatar_url': d['avatar_url'],
        'purchases': purchases,
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
    int readymade = 0, custom = 0;

    final usersSnap = await firestore.collection('users').get();
    for (var u in usersSnap.docs) {
      if (u['plan_name'] == 'Standard' || u['plan_name'] == 'Premium') {
        readymade++;
      }
    }

    final customSnap = await firestore.collection('users_plan').get();
    custom = customSnap.size;

    Map<String, int> planCount = {};
    for (var u in usersSnap.docs) {
      final plan = u['plan_name'];
      if (plan != null) planCount[plan] = (planCount[plan] ?? 0) + 1;
    }

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
    popularPlans.value = _castList(data['popularPlans']);
  }

  // ================= BUSINESS REPORTS =================
  Future<void> generateBusinessReports() async {
    Map<String, double> monthMap = {};
    List<Map<String, dynamic>> active = [];
    List<Map<String, dynamic>> pending = [];

    for (var tx in transactions) {
      if (tx['date'] != null) {
        DateTime d = (tx['date'] as Timestamp).toDate();
        String key = "${d.year}-${d.month}";
        monthMap[key] = (monthMap[key] ?? 0) + tx['amount'];
      }
      if (tx['status'] != 'completed') pending.add(tx);
      if (tx['expiryDate'] != null && tx['expiryDate'] is Timestamp) {
        DateTime exp = (tx['expiryDate'] as Timestamp).toDate();
        if (exp.isAfter(DateTime.now())) active.add(tx);
      }
    }

    monthlyRevenue.value = monthMap;
    pendingPayments.value = pending;
    activeMemberships.value = active;
  }
}