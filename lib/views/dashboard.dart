import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:webkit/helpers/theme/admin_theme.dart';
import 'package:webkit/helpers/utils/my_shadow.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb_item.dart';
import 'package:webkit/helpers/widgets/my_card.dart';
import 'package:webkit/helpers/widgets/my_container.dart';
import 'package:webkit/helpers/widgets/my_flex.dart';
import 'package:webkit/helpers/widgets/my_flex_item.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';

import 'package:webkit/views/layouts/layout.dart';
import 'package:webkit/views/apps/dashboard/models/dashboard_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SECTION WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _StatSection extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final List<Widget> cards;

  const _StatSection({
    required this.label,
    required this.icon,
    required this.color,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(.30), width: 1.5),
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              MySpacing.width(6),
              MyText.labelMedium(
                label,
                color: color,
                fontWeight: 700,
              ),
            ],
          ),
          MySpacing.height(10),
          // Cards in a row
          Row(
            children: cards
                .map((c) => Expanded(child: c))
                .toList()
                .expand((w) => [w, MySpacing.width(8)])
                .toList()
              ..removeLast(), // remove trailing spacer
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD PAGE
// ─────────────────────────────────────────────────────────────────────────────
class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final DashboardController controller =
  Get.put(DashboardController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;
    const double gap = 12;

    return Layout(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: MySpacing.xy(gap, gap / 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText.titleMedium(
                    "Dashboard",
                    fontSize: 22,
                    fontWeight: 700,
                  ),
                  MyBreadcrumb(
                    children: [
                      MyBreadcrumbItem(name: 'Dashboard', active: true),
                    ],
                  ),
                ],
              ),
              MySpacing.height(gap),

              // ── 3 GROUPED STAT SECTIONS ──────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTION 1 — Users
                  Expanded(
                    flex: 3,
                    child: _StatSection(
                      label: "Users",
                      icon: LucideIcons.users,
                      color: contentTheme.primary,
                      cards: [
                        _buildStatCard(
                          "Total Users",
                          controller.totalUsers,
                          LucideIcons.users,
                          contentTheme.primary,
                        ),
                        _buildStatCard(
                          "Paid Users",
                          controller.paidUsers,
                          LucideIcons.user_check,
                          contentTheme.success,
                        ),
                        _buildStatCard(
                          "Free Users",
                          controller.freeUsers,
                          LucideIcons.user_minus,
                          contentTheme.warning,
                        ),
                      ],
                    ),
                  ),

                  MySpacing.width(gap),

                  // SECTION 2 — Support Tickets
                  Expanded(
                    flex: 2,
                    child: _StatSection(
                      label: "Support Tickets",
                      icon: LucideIcons.headphones,
                      color: contentTheme.info,
                      cards: [
                        _buildStatCard(
                          "Resolved",
                          controller.ticketsResolved,
                          LucideIcons.check_check,
                          contentTheme.info,
                        ),
                        _buildStatCard(
                          "In Progress",
                          controller.ticketsInProgress,
                          LucideIcons.clock,
                          contentTheme.danger,
                        ),
                      ],
                    ),
                  ),

                  MySpacing.width(gap),

                  // SECTION 3 — Revenue
                  Expanded(
                    flex: 2,
                    child: _StatSection(
                      label: "Revenue",
                      icon: LucideIcons.dollar_sign,
                      color: contentTheme.success,
                      cards: [
                        _buildStatCard(
                          "Total Revenue",
                          controller.totalRevenue,
                          LucideIcons.dollar_sign,
                          contentTheme.success,
                        ),
                        _buildStatCard(
                          "Pending Revenue",
                          controller.pendingRevenue,
                          LucideIcons.triangle_alert,
                          contentTheme.danger,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              MySpacing.height(gap),

              // ── CHART + COUNTRY ──────────────────────────────────────────
              MyFlex(
                contentPadding: false,
                children: [
                  // Revenue Chart
                  MyFlexItem(
                    sizes: "lg-6 md-12 sm-12",
                    child: MyCard(
                      padding: MySpacing.all(16),
                      shadow: MyShadow(elevation: .6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.titleMedium("Revenue by Plan Type",
                              fontWeight: 600),
                          MySpacing.height(12),
                          SizedBox(
                            height: 260,
                            child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              tooltipBehavior:
                              TooltipBehavior(enable: true),
                              series: <ColumnSeries<int, String>>[
                                ColumnSeries<int, String>(
                                  width: .45,
                                  borderRadius: BorderRadius.circular(6),
                                  color: contentTheme.primary,
                                  dataSource: [
                                    controller.readymadeSold.value,
                                    controller.customSold.value,
                                    controller.specialSold.value,
                                  ],
                                  xValueMapper: (v, i) =>
                                  ["Readymade", "Custom", "Special"][i],
                                  yValueMapper: (v, _) => v,
                                  dataLabelSettings:
                                  const DataLabelSettings(
                                      isVisible: true),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Users by Country
                  MyFlexItem(
                    sizes: "lg-6 md-12 sm-12",
                    child: MyCard(
                      padding: MySpacing.all(16),
                      shadow: MyShadow(elevation: .6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.globe, size: 18),
                              MySpacing.width(8),
                              MyText.titleMedium("Users by Country",
                                  fontWeight: 600),
                            ],
                          ),
                          MySpacing.height(16),
                          SizedBox(
                            height: 260,
                            child: Obx(() {
                              if (controller.usersByCountry.isEmpty) {
                                return Center(
                                  child: MyText.bodySmall(
                                      "No data available",
                                      muted: true),
                                );
                              }
                              final total = controller
                                  .usersByCountry.values
                                  .fold<int>(0, (a, b) => a + b);
                              return ListView.separated(
                                itemCount:
                                controller.usersByCountry.length,
                                separatorBuilder: (_, __) =>
                                    MySpacing.height(12),
                                itemBuilder: (context, index) {
                                  final entry = controller
                                      .usersByCountry.entries
                                      .elementAt(index);
                                  double percent = total == 0
                                      ? 0
                                      : (entry.value / total);
                                  return Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 14,
                                                backgroundColor: AdminTheme
                                                    .theme
                                                    .contentTheme
                                                    .primary
                                                    .withOpacity(.15),
                                                child:
                                                MyText.bodySmall(
                                                  entry.key
                                                      .substring(0, 1)
                                                      .toUpperCase(),
                                                  fontWeight: 600,
                                                ),
                                              ),
                                              MySpacing.width(10),
                                              MyText.bodyMedium(
                                                  entry.key,
                                                  fontWeight: 600),
                                            ],
                                          ),
                                          MyText.bodyMedium(
                                              entry.value.toString(),
                                              fontWeight: 600),
                                        ],
                                      ),
                                      MySpacing.height(6),
                                      ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          minHeight: 6,
                                          value: percent,
                                          backgroundColor:
                                          Colors.grey.withOpacity(.15),
                                          valueColor:
                                          AlwaysStoppedAnimation(
                                            AdminTheme.theme.contentTheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              MySpacing.height(gap),

              // ── USERS TABLE + POPULAR PLANS ──────────────────────────────
              MyFlex(
                contentPadding: false,
                children: [
                  MyFlexItem(
                    sizes: "lg-8 md-12 sm-12",
                    child: usersTable(contentTheme),
                  ),
                  MyFlexItem(
                    sizes: "lg-4 md-12 sm-12",
                    child: popularPlansTable(),
                  ),
                ],
              ),
              MySpacing.height(gap),

              // ── TRANSACTIONS + LEDGER ────────────────────────────────────
              MyFlex(
                contentPadding: false,
                children: [
                  MyFlexItem(
                    sizes: "lg-6 md-12 sm-12",
                    child: transactionReportTable(),
                  ),
                  MyFlexItem(
                    sizes: "lg-6 md-12 sm-12",
                    child: userLedgerReport(),
                  ),
                ],
              ),
              MySpacing.height(gap),

              // ── SUPPORT TICKETS ──────────────────────────────────────────
              supportTicketsTable(contentTheme),
              MySpacing.height(gap),
            ],
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STAT CARD (used inside _StatSection)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStatCard(
      String title, Rx<num> value, IconData icon, Color color) {
    return Obx(() {
      return MyCard(
        height: 80,
        padding: MySpacing.xy(8, 8),
        shadow: MyShadow(elevation: .4),
        child: Row(
          children: [
            MyContainer(
              height: 32,
              width: 32,
              color: color.withOpacity(.15),
              borderRadiusAll: 6,
              child: Icon(icon, size: 16, color: color),
            ),
            MySpacing.width(8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText.titleMedium(
                    value.value.toStringAsFixed(0),
                    fontWeight: 700,
                  ),
                  MyText.bodySmall(
                    title,
                    muted: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TRANSACTIONS TABLE
  // ─────────────────────────────────────────────────────────────────────────
  Widget transactionReportTable() {
    return MyCard(
      padding: MySpacing.all(16),
      shadow: MyShadow(elevation: .6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.credit_card, size: 18),
              MySpacing.width(8),
              MyText.titleMedium("All Transactions (Grouped)",
                  fontWeight: 600),
            ],
          ),
          MySpacing.height(16),
          SizedBox(
            height: 420,
            child: Obx(() {
              if (controller.cachedTransactions.isEmpty) {
                return Center(
                    child: MyText.bodySmall("No transactions found"));
              }

              Map<String, Map<String, dynamic>> grouped = {};
              for (var tx in controller.cachedTransactions) {
                final uid = tx['userId'] ?? '';
                grouped.putIfAbsent(uid, () => {
                  'userName': tx['userName'] ?? 'Unknown',
                  'completed': 0.0,
                  'pending': 0.0,
                  'transactions': <Map<String, dynamic>>[],
                });
                grouped[uid]!['transactions'].add(tx);
                if (tx['status'] == 'completed') {
                  grouped[uid]!['completed'] += tx['amount'];
                } else {
                  grouped[uid]!['pending'] += tx['amount'];
                }
              }

              final list = grouped.values.toList();
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final u = list[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      title: MyText.bodyMedium(u['userName'],
                          fontWeight: 600),
                      subtitle: Row(
                        children: [
                          MyText.bodySmall(
                            "Received: \$${u['completed'].toStringAsFixed(2)}",
                            color: Colors.green,
                            fontWeight: 600,
                          ),
                          MySpacing.width(16),
                          MyText.bodySmall(
                            "Pending: \$${u['pending'].toStringAsFixed(2)}",
                            color: Colors.orange,
                            fontWeight: 600,
                          ),
                        ],
                      ),
                      children: (u['transactions']
                      as List<Map<String, dynamic>>)
                          .map((tx) => ListTile(
                        dense: true,
                        title: MyText.bodySmall(
                            tx['planName'] ?? 'N/A',
                            fontWeight: 600),
                        subtitle: MyText.bodySmall(
                            "Status: ${tx['status']}"),
                        trailing: MyText.bodySmall(
                          "\$${tx['amount'].toStringAsFixed(2)}",
                          color: tx['status'] == 'completed'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: 600,
                        ),
                      ))
                          .toList(),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // USER LEDGER
  // ─────────────────────────────────────────────────────────────────────────
  Widget userLedgerReport() {
    return MyCard(
      padding: MySpacing.all(16),
      shadow: MyShadow(elevation: .6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.book_open, size: 18),
              MySpacing.width(8),
              MyText.titleMedium("User Ledgers", fontWeight: 600),
            ],
          ),
          MySpacing.height(16),
          SizedBox(
            height: 420,
            child: Obx(() {
              if (controller.cachedUserLedgers.isEmpty) {
                return Center(
                    child: MyText.bodySmall("No ledger data"));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.cachedUserLedgers.length,
                itemBuilder: (_, i) {
                  final l = controller.cachedUserLedgers[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16),
                      title: MyText.bodyMedium(
                          l['userName'] ?? 'Unknown',
                          fontWeight: 600),
                      subtitle:
                      MyText.bodySmall(l['email'] ?? '', muted: true),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyText.bodySmall(
                            "Paid: \$${(l['totalPaid'] ?? 0).toStringAsFixed(2)}",
                            color: Colors.green,
                            fontWeight: 600,
                          ),
                          MyText.bodySmall(
                            "Pending: \$${(l['pending'] ?? 0).toStringAsFixed(2)}",
                            color: Colors.orange,
                            fontWeight: 600,
                          ),
                        ],
                      ),
                      children: (l['transactions'] as List<dynamic>)
                          .map((tx) => ListTile(
                        dense: true,
                        title: MyText.bodySmall(
                            tx['planName'] ?? 'N/A',
                            fontWeight: 600),
                        subtitle: MyText.bodySmall(
                            "Status: ${tx['status']}"),
                        trailing: MyText.bodySmall(
                          "\$${(tx['amount'] ?? 0).toStringAsFixed(2)}",
                          color: tx['status'] == 'completed'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: 600,
                        ),
                      ))
                          .toList(),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // USERS TABLE
  // ─────────────────────────────────────────────────────────────────────────
  Widget usersTable(ContentTheme contentTheme) {
    return MyCard(
      padding: MySpacing.all(16),
      shadow: MyShadow(elevation: .6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.users, size: 18),
              MySpacing.width(8),
              MyText.titleMedium("Users & Membership", fontWeight: 600),
            ],
          ),
          MySpacing.height(16),
          Obx(() {
            if (controller.users.isEmpty) {
              return Center(
                child: MyText.bodySmall("No users data available",
                    muted: true),
              );
            }
            return SizedBox(
              height: 320,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.users.length,
                  separatorBuilder: (_, __) => MySpacing.height(12),
                  itemBuilder: (context, index) {
                    final u = controller.users[index];
                    final plan = u['plan_name'] ?? 'Free';
                    final planColor = plan == 'Premium'
                        ? Colors.green
                        : Colors.orange;
                    final purchases =
                        u['purchases'] as List<Map<String, dynamic>>? ??
                            [];

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.withOpacity(0.03),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: u['avatar_url'] != null
                                    ? NetworkImage(u['avatar_url'])
                                    : null,
                                backgroundColor:
                                contentTheme.primary.withOpacity(.2),
                                child: u['avatar_url'] == null
                                    ? Text(
                                  u['name'][0].toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )
                                    : null,
                              ),
                              MySpacing.width(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    MyText.bodyMedium(u['name'] ?? '-',
                                        fontWeight: 600),
                                    Row(
                                      children: [
                                        Icon(Icons.email,
                                            size: 14, color: Colors.grey),
                                        MySpacing.width(4),
                                        MyText.bodySmall(
                                            u['email'] ?? '-',
                                            muted: true),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 14, color: Colors.grey),
                                        MySpacing.width(4),
                                        MyText.bodySmall(
                                            u['country'] ?? '-',
                                            muted: true),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Chip(
                                label: Text(plan),
                                backgroundColor:
                                planColor.withOpacity(.15),
                                labelStyle: TextStyle(
                                    color: planColor,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          MySpacing.height(8),
                          if (purchases.isNotEmpty)
                            SizedBox(
                              height: 80,
                              child: ListView.separated(
                                scrollDirection: Axis.vertical,
                                itemCount: purchases.length,
                                separatorBuilder: (_, __) =>
                                    MySpacing.height(4),
                                itemBuilder: (context, pIndex) {
                                  final p = purchases[pIndex];
                                  final amount = p['amount'] ?? 0;
                                  final planName =
                                      p['plan_name'] ?? '-';
                                  final purchaseDate =
                                  p['purchase_date'] != null
                                      ? (p['purchase_date']
                                  as Timestamp)
                                      .toDate()
                                      : null;
                                  final expiryDate =
                                  p['expiry_date'] != null
                                      ? (p['expiry_date']
                                  as Timestamp)
                                      .toDate()
                                      : null;
                                  final status =
                                      p['payment_status'] ?? '-';
                                  Color statusColor =
                                  status.toLowerCase() == 'pending'
                                      ? Colors.orange
                                      : Colors.green;
                                  return Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: MyText.bodySmall(
                                              planName)),
                                      Expanded(
                                        flex: 2,
                                        child: MyText.bodySmall(
                                          purchaseDate != null
                                              ? "${purchaseDate.day}/${purchaseDate.month}/${purchaseDate.year}"
                                              : "-",
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: MyText.bodySmall(
                                          expiryDate != null
                                              ? "${expiryDate.day}/${expiryDate.month}/${expiryDate.year}"
                                              : "-",
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: MyText.bodySmall(status,
                                            color: statusColor),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: MyText.bodySmall(
                                              "\$$amount")),
                                    ],
                                  );
                                },
                              ),
                            )
                          else
                            MyText.bodySmall("No purchases yet",
                                muted: true),
                          const Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // POPULAR PLANS
  // ─────────────────────────────────────────────────────────────────────────
  Widget popularPlansTable() {
    return MyCard(
      padding: MySpacing.all(16),
      shadow: MyShadow(elevation: .6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.trending_up, size: 18),
              MySpacing.width(8),
              MyText.titleMedium("Most Popular Plans", fontWeight: 600),
            ],
          ),
          MySpacing.height(16),
          Obx(() {
            if (controller.popularPlans.isEmpty) {
              return Center(
                child: MyText.bodySmall("No plans data available",
                    muted: true),
              );
            }
            final maxSold =
                controller.popularPlans.first['sold'] ?? 1;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.popularPlans.length,
              separatorBuilder: (_, __) => MySpacing.height(14),
              itemBuilder: (context, index) {
                final p = controller.popularPlans[index];
                final sold = p['sold'] ?? 0;
                final percent =
                maxSold == 0 ? 0.0 : sold / maxSold;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AdminTheme
                                    .theme.contentTheme.primary
                                    .withOpacity(.15),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: MyText.bodySmall(
                                  "#${index + 1}",
                                  fontWeight: 600),
                            ),
                            MySpacing.width(10),
                            MyText.bodyMedium(p['title'],
                                fontWeight: 600),
                          ],
                        ),
                        MyText.bodyMedium("$sold sold",
                            fontWeight: 600),
                      ],
                    ),
                    MySpacing.height(6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: percent,
                        backgroundColor:
                        Colors.grey.withOpacity(.15),
                        valueColor: AlwaysStoppedAnimation(
                          AdminTheme.theme.contentTheme.primary,
                        ),
                      ),
                    ),
                    MySpacing.height(4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: MyText.bodySmall(
                        "${(percent * 100).toStringAsFixed(1)}% of top plan",
                        muted: true,
                      ),
                    ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SUPPORT TICKETS
  // ─────────────────────────────────────────────────────────────────────────
  Widget supportTicketsTable(ContentTheme contentTheme) {
    return MyCard(
      padding: MySpacing.all(16),
      shadow: MyShadow(elevation: .6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.headphones, size: 18),
              MySpacing.width(8),
              MyText.titleMedium("Support Tickets", fontWeight: 600),
            ],
          ),
          MySpacing.height(16),
          StreamBuilder<QuerySnapshot>(
            stream: controller.firestore
                .collection('support_tickets')
                .limit(15)
                .snapshots(),
            builder: (_, snap) {
              if (!snap.hasData) {
                return const Center(
                    child: CircularProgressIndicator());
              }
              final tickets = snap.data!.docs
                  .map((d) => d.data() as Map<String, dynamic>)
                  .toList();
              if (tickets.isEmpty) {
                return Center(
                  child: MyText.bodySmall("No tickets found",
                      muted: true),
                );
              }
              return SizedBox(
                height: 380,
                child: ListView.separated(
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) =>
                      MySpacing.height(14),
                  itemBuilder: (context, index) {
                    final t = tickets[index];

                    Color statusColor;
                    switch (
                    (t['status'] ?? '').toLowerCase()) {
                      case 'resolved':
                        statusColor = Colors.green;
                        break;
                      case 'in progress':
                        statusColor = Colors.orange;
                        break;
                      case 'pending':
                        statusColor = Colors.red;
                        break;
                      default:
                        statusColor = Colors.grey;
                    }

                    Color priorityColor;
                    switch (
                    (t['priority'] ?? '').toLowerCase()) {
                      case 'high':
                        priorityColor = Colors.redAccent;
                        break;
                      case 'medium':
                        priorityColor = Colors.orangeAccent;
                        break;
                      default:
                        priorityColor = Colors.greenAccent;
                    }

                    return Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: MyText.bodyMedium(
                              t['userName'] ?? '-',
                              fontWeight: 600),
                        ),
                        Expanded(
                          flex: 3,
                          child: MyText.bodySmall(
                              t['topic'] ?? '-'),
                        ),
                        Expanded(
                          flex: 2,
                          child: MyContainer(
                            padding: MySpacing.xy(12, 6),
                            borderRadiusAll: 12,
                            color:
                            statusColor.withOpacity(.2),
                            child: MyText.bodySmall(
                              t['status'] ?? '-',
                              color: statusColor,
                              fontWeight: 600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: MyContainer(
                            padding: MySpacing.xy(12, 6),
                            borderRadiusAll: 12,
                            color: priorityColor
                                .withOpacity(.2),
                            child: MyText.bodySmall(
                              t['priority'] ?? '-',
                              color: priorityColor,
                              fontWeight: 600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}