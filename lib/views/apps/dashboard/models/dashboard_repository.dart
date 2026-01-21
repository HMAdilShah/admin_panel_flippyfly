import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users_plan_model.dart';
import '../models/user_model.dart';
import '../models/support_ticket_model.dart';
import '../models/dashboard_summary.dart';

class DashboardRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DashboardSummary> fetchDashboardSummary() async {
    final usersPlanSnap = await _db.collection('users_plan').get();
    final usersSnap = await _db.collection('users').get();
    final ticketsSnap = await _db.collection('support_tickets').get();

    // USERS PLAN
    final plans = usersPlanSnap.docs
        .map((d) => UsersPlanModel.fromFirestore(d))
        .toList();

    final totalRevenue =
    plans.fold(0, (sum, p) => sum + p.paidAmount);

    final now = DateTime.now();
    final monthlyRevenue = plans.fold(0, (sum, p) {
      return sum +
          p.payments
              .where((pay) =>
          pay.status == 'paid' &&
              pay.paidAt != null &&
              pay.paidAt!.month == now.month &&
              pay.paidAt!.year == now.year)
              .fold(0, (s, pay) => s + pay.amount);
    });

    final paidUsers =
        plans.where((p) => p.paidAmount > 0).length;

    // USERS
    final users = usersSnap.docs
        .map((d) => UserModel.fromFirestore(d))
        .toList();

    final activeUsers =
        users.where((u) => u.status == 'active').length;

    // TICKETS
    final tickets = ticketsSnap.docs
        .map((d) => SupportTicketModel.fromFirestore(d))
        .toList();

    final openTickets =
        tickets.where((t) => t.status != 'closed').length;

    return DashboardSummary(
      totalRevenue: totalRevenue,
      monthlyRevenue: monthlyRevenue,
      activeUsers: activeUsers,
      paidUsers: paidUsers,
      openTickets: openTickets,
    );
  }
}
