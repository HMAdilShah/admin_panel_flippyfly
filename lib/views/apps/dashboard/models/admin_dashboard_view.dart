// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'dashboard_controller.dart';
//
// class DashboardPage extends StatelessWidget {
//   DashboardPage({super.key});
//
//   final DashboardController controller = Get.put(DashboardController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Admin Dashboard')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _statsRow(),
//             const SizedBox(height: 30),
//             _revenueChart(),
//             const SizedBox(height: 30),
//             _popularPlans(),
//             const SizedBox(height: 30),
//             _usersByCountry(),
//             const SizedBox(height: 30),
//             _supportTickets(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ================= STATS =================
//   Widget _statsRow() {
//     return Obx(() => Wrap(
//       spacing: 12,
//       runSpacing: 12,
//       children: [
//         statCard('Total Users', controller.totalUsers.value),
//         statCard('Free Users', controller.freeUsers.value),
//         statCard('Paid Users', controller.paidUsers.value),
//         statCard('Resolved Tickets', controller.ticketsResolved.value),
//         statCard('In Progress', controller.ticketsInProgress.value),
//       ],
//     ));
//   }
//
//   Widget statCard(String title, int value) {
//     return Card(
//       child: SizedBox(
//         width: 180,
//         height: 100,
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(value.toString(),
//                   style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text(title),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ================= REVENUE =================
//   Widget _revenueChart() {
//     return Obx(() {
//       return SfCartesianChart(
//         title: ChartTitle(text: 'Revenue by Plan Type'),
//         primaryXAxis: CategoryAxis(),
//         series: <CartesianSeries<int, String>>[
//           ColumnSeries<int, String>(
//             dataSource: [
//               // controller.totalReadymadePlansSold.value,
//               // controller.totalCustomPlansSold.value,
//               // controller.totalSpecialPlansSold.value,
//             ],
//             xValueMapper: (value, index) =>
//             ['Readymade', 'Custom', 'Special'][index],
//             yValueMapper: (value, _) => value,
//             dataLabelSettings: const DataLabelSettings(isVisible: true),
//           )
//         ],
//       );
//     });
//   }
//
//   // ================= POPULAR PLANS =================
//   Widget _popularPlans() {
//     return Obx(() {
//       return DataTable(
//         headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
//         columns: const [
//           DataColumn(label: Text('Plan')),
//           DataColumn(label: Text('Sold')),
//         ],
//         rows: controller.popularPlans
//             .map((plan) => DataRow(cells: [
//           DataCell(Text(plan['title'] ?? '')),
//           DataCell(Text(plan['sold'].toString())),
//         ]))
//             .toList(),
//       );
//     });
//   }
//
//   // ================= USERS BY COUNTRY =================
//   Widget _usersByCountry() {
//     return Obx(() {
//       return DataTable(
//         columns: const [
//           DataColumn(label: Text('Country')),
//           DataColumn(label: Text('Users')),
//         ],
//         rows: controller.usersByCountry.entries
//             .map((e) => DataRow(cells: [
//           DataCell(Text(e.key)),
//           DataCell(Text(e.value.toString())),
//         ]))
//             .toList(),
//       );
//     });
//   }
//
//   // ================= SUPPORT TICKETS =================
//   Widget _supportTickets() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: controller.firestore.collection('support_tickets').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const CircularProgressIndicator();
//         }
//
//         final docs = snapshot.data!.docs;
//
//         return DataTable(
//           columns: const [
//             DataColumn(label: Text('Ticket')),
//             DataColumn(label: Text('User')),
//             DataColumn(label: Text('Topic')),
//             DataColumn(label: Text('Status')),
//           ],
//           rows: docs.map((doc) {
//             return DataRow(cells: [
//               DataCell(Text(doc['ticketNo'].toString())),
//               DataCell(Text(doc['userName'] ?? '')),
//               DataCell(Text(doc['topic'] ?? '')),
//               DataCell(Text(doc['status'] ?? '')),
//             ]);
//           }).toList(),
//         );
//       },
//     );
//   }
// }
