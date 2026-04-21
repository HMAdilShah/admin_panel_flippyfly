import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';

import 'package:webkit/helpers/theme/admin_theme.dart';
import 'package:webkit/helpers/utils/my_shadow.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb_item.dart';
import 'package:webkit/helpers/widgets/my_card.dart';
import 'package:webkit/helpers/widgets/my_container.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:webkit/views/apps/dashboard/models/dashboard_controller.dart';
import 'package:webkit/views/layouts/layout.dart';

const String kCurrency = 'QAR';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DashboardController controller = Get.find<DashboardController>();

  String selectedPeriod = 'all';
  DateTime? customFrom;
  DateTime? customTo;
  String selectedUserId = '';
  String selectedUserName = 'All Users';

  final List<Map<String, String>> periodOptions = [
    {'key': 'all', 'label': 'All Time'},
    {'key': 'today', 'label': 'Today'},
    {'key': 'week', 'label': 'This Week'},
    {'key': 'month', 'label': 'This Month'},
    {'key': 'custom', 'label': 'Custom Range'},
  ];

  void _applyFilter(String period) {
    setState(() => selectedPeriod = period);
    if (period != 'custom') {
      controller.applyReportFilter(period, userId: selectedUserId);
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: customFrom ?? now.subtract(const Duration(days: 30)),
        end: customTo ?? now,
      ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AdminTheme.theme.contentTheme.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        customFrom = picked.start;
        customTo = picked.end;
        selectedPeriod = 'custom';
      });
      controller.applyReportFilter(
        'custom',
        from: picked.start,
        to: picked.end,
        userId: selectedUserId,
      );
    }
  }

  void _showUserPicker() {
    final users = [
      {'id': '', 'name': 'All Users'},
      ...controller.users
          .map((u) => {'id': u['id'] as String, 'name': u['name'] as String}),
    ];

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: MyText.titleMedium("Filter by User", fontWeight: 600),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (_, i) {
                  final u = users[i];
                  final isSelected = u['id'] == selectedUserId;
                  return ListTile(
                    title: Text(u['name']!),
                    trailing: isSelected
                        ? Icon(
                      LucideIcons.check,
                      color: AdminTheme.theme.contentTheme.primary,
                    )
                        : null,
                    onTap: () {
                      setState(() {
                        selectedUserId = u['id']!;
                        selectedUserName = u['name']!;
                      });
                      controller.applyReportFilter(
                        selectedPeriod,
                        from: customFrom,
                        to: customTo,
                        userId: u['id']!,
                      );
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;

    return Layout(
      child: SingleChildScrollView(
        padding: MySpacing.xy(12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium("Revenue Reports",
                    fontSize: 22, fontWeight: 700),
                // MyBreadcrumb(children: [
                //   MyBreadcrumbItem(name: 'Dashboard', route: '/dashboard'),
                //   MyBreadcrumbItem(name: 'Reports', active: true),
                // ]),
              ],
            ),
            MySpacing.height(16),

            // ── Filters ──────────────────────────────────────────────────
            MyCard(
              padding: MySpacing.all(16),
              shadow: MyShadow(elevation: .4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.list_filter_plus, size: 16),
                      MySpacing.width(8),
                      MyText.labelMedium("Filters", fontWeight: 700),
                    ],
                  ),
                  MySpacing.height(12),
                  // Period chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...periodOptions.map((opt) {
                        final isSelected = selectedPeriod == opt['key'];
                        return GestureDetector(
                          onTap: () => opt['key'] == 'custom'
                              ? _pickCustomRange()
                              : _applyFilter(opt['key']!),
                          child: MyContainer(
                            padding: MySpacing.xy(14, 8),
                            borderRadiusAll: 20,
                            color: isSelected
                                ? contentTheme.primary
                                : contentTheme.primary.withOpacity(.08),
                            child: MyText.bodySmall(
                              opt['label']!,
                              color: isSelected
                                  ? Colors.white
                                  : contentTheme.primary,
                              fontWeight: 600,
                            ),
                          ),
                        );
                      }),

                      // Custom range display
                      if (selectedPeriod == 'custom' &&
                          customFrom != null &&
                          customTo != null)
                        MyContainer(
                          padding: MySpacing.xy(12, 8),
                          borderRadiusAll: 20,
                          color: contentTheme.success.withOpacity(.1),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.calendar,
                                  size: 13, color: contentTheme.success),
                              MySpacing.width(6),
                              MyText.bodySmall(
                                "${customFrom!.day}/${customFrom!.month}/${customFrom!.year}  →  ${customTo!.day}/${customTo!.month}/${customTo!.year}",
                                color: contentTheme.success,
                                fontWeight: 600,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  MySpacing.height(12),
                  // User filter button
                  GestureDetector(
                    onTap: _showUserPicker,
                    child: MyContainer(
                      padding: MySpacing.xy(14, 10),
                      borderRadiusAll: 10,
                      color: contentTheme.primary.withOpacity(.06),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.user,
                              size: 15, color: contentTheme.primary),
                          MySpacing.width(8),
                          MyText.bodySmall(
                            selectedUserName,
                            color: contentTheme.primary,
                            fontWeight: 600,
                          ),
                          MySpacing.width(8),
                          Icon(LucideIcons.chevron_down,
                              size: 14, color: contentTheme.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            MySpacing.height(16),

            // ── Revenue Cards ─────────────────────────────────────────────
            Obx(() => Column(
              children: [
                // ── 1. Membership Revenue ──
                _revenueSection(
                  context: context,
                  title: "Membership Revenue",
                  icon: LucideIcons.id_card,
                  color: contentTheme.primary,
                  total: controller.membershipTotal.value,
                  fatoorahFee: controller.membershipFatoorahFee.value,
                  profit: controller.membershipProfit.value,
                  description:
                  "Revenue from Premium membership subscriptions",
                ),
                MySpacing.height(12),

                // ── 2. Custom Plans Revenue ──
                _revenueSection(
                  context: context,
                  title: "Custom Plans Revenue",
                  icon: LucideIcons.settings_2,
                  color: contentTheme.info,
                  total: controller.customTotal.value,
                  fatoorahFee: controller.customFatoorahFee.value,
                  profit: controller.customProfit.value,
                  description:
                  "Revenue from user-specific custom plan payments",
                ),
                MySpacing.height(12),

                // ── 3. Readymade Plans Revenue ──
                _revenueSection(
                  context: context,
                  title: "Readymade Plans Revenue",
                  icon: LucideIcons.package,
                  color: contentTheme.success,
                  total: controller.readymadeTotal.value,
                  fatoorahFee: controller.readymadeFatoorahFee.value,
                  profit: controller.readymadeProfit.value,
                  description:
                  "Revenue from standard readymade plan purchases",
                ),
                MySpacing.height(12),

                // ── 4. Combined Summary ──
                _combinedSummary(contentTheme),
              ],
            )),
          ],
        ),
      ),
    );
  }

  // ── Revenue Section Card ────────────────────────────────────────────────
  Widget _revenueSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required double total,
    required double fatoorahFee,
    required double profit,
    required String description,
  }) {
    return MyCard(
      padding: MySpacing.all(16),
      shadow: MyShadow(elevation: .6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              MyContainer(
                height: 36,
                width: 36,
                borderRadiusAll: 8,
                color: color.withOpacity(.12),
                child: Icon(icon, size: 18, color: color),
              ),
              MySpacing.width(10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.titleMedium(title, fontWeight: 700),
                  MyText.bodySmall(description, muted: true),
                ],
              ),
            ],
          ),
          MySpacing.height(16),
          const Divider(height: 1),
          MySpacing.height(16),

          // 3 metric boxes
          Row(
            children: [
              // Total Collected
              Expanded(
                child: _metricBox(
                  label: "Total Collected",
                  value: "QAR ${total.toStringAsFixed(2)}",
                  icon: LucideIcons.circle_dollar_sign,
                  color: color,
                  bgColor: color.withOpacity(.08),
                ),
              ),
              MySpacing.width(10),
              // MyFatoorah Fee
              Expanded(
                child: _metricBox(
                  label:
                  "MyFatoorah Fee (${DashboardController.myFatoorahFeePercent}%)",
                  value: "- QAR ${fatoorahFee.toStringAsFixed(2)}",
                  icon: LucideIcons.circle_minus,
                  color: Colors.red,
                  bgColor: Colors.red.withOpacity(.06),
                ),
              ),
              MySpacing.width(10),
              // Net Profit
              Expanded(
                child: _metricBox(
                  label: "Our Profit",
                  value: "QAR ${profit.toStringAsFixed(2)}",
                  icon: LucideIcons.trending_up,
                  color: Colors.green,
                  bgColor: Colors.green.withOpacity(.08),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Single Metric Box ───────────────────────────────────────────────────
  Widget _metricBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              MySpacing.width(6),
              Expanded(
                child: MyText.bodySmall(
                  label,
                  color: color,
                  fontWeight: 600,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          MySpacing.height(8),
          MyText.titleMedium(
            value,
            fontWeight: 700,
            fontSize: 18,
            color: color,
          ),
        ],
      ),
    );
  }

  // ── Combined Summary ────────────────────────────────────────────────────
  Widget _combinedSummary(ContentTheme contentTheme) {
    final grandTotal = controller.membershipTotal.value +
        controller.customTotal.value +
        controller.readymadeTotal.value;
    final grandFee = controller.membershipFatoorahFee.value +
        controller.customFatoorahFee.value +
        controller.readymadeFatoorahFee.value;
    final grandProfit = controller.membershipProfit.value +
        controller.customProfit.value +
        controller.readymadeProfit.value;

    return MyCard(
      padding: MySpacing.all(16),
      shadow: MyShadow(elevation: .6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.chart_bar,
                  size: 18, color: contentTheme.primary),
              MySpacing.width(8),
              MyText.titleMedium("Combined Summary", fontWeight: 700),
            ],
          ),
          MySpacing.height(16),
          // Progress bar visualization
          _summaryRow("Membership", controller.membershipProfit.value,
              grandProfit, contentTheme.primary),
          MySpacing.height(10),
          _summaryRow("Custom Plans", controller.customProfit.value,
              grandProfit, contentTheme.info),
          MySpacing.height(10),
          _summaryRow("Readymade Plans", controller.readymadeProfit.value,
              grandProfit, contentTheme.success),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.bodyMedium("Grand Total Collected", fontWeight: 600),
              MyText.bodyMedium(
                "QAR ${grandTotal.toStringAsFixed(2)}",
                fontWeight: 700,
              ),
            ],
          ),
          MySpacing.height(6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.bodyMedium("Total MyFatoorah Fees", fontWeight: 600),
              MyText.bodyMedium(
                "- QAR ${grandFee.toStringAsFixed(2)}",
                fontWeight: 700,
                color: Colors.red,
              ),
            ],
          ),
          MySpacing.height(6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.bodyMedium("Net Profit", fontWeight: 700),
              MyText.bodyMedium(
                "QAR ${grandProfit.toStringAsFixed(2)}",
                fontWeight: 700,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String label, double value, double total, Color color) {
    final percent = total == 0 ? 0.0 : (value / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyText.bodySmall(label, fontWeight: 600),
            MyText.bodySmall(
              "QAR ${value.toStringAsFixed(2)}  (${(percent * 100).toStringAsFixed(1)}%)",
              fontWeight: 600,
              color: color,
            ),
          ],
        ),
        MySpacing.height(4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: percent,
            backgroundColor: Colors.grey.withOpacity(.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}