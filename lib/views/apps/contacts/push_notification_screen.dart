// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:googleapis_auth/auth_io.dart';
//
// class PushNotificationAdminScreen extends StatefulWidget {
//   const PushNotificationAdminScreen({super.key});
//
//   @override
//   State<PushNotificationAdminScreen> createState() =>
//       _PushNotificationAdminScreenState();
// }
//
// class _PushNotificationAdminScreenState
//     extends State<PushNotificationAdminScreen> {
//   final _titleController = TextEditingController();
//   final _bodyController = TextEditingController();
//
//   String selectedTarget = "all_users";
//   bool isSending = false;
//
//   // ✅ PASTE YOUR 3 VALUES FROM YOUR JSON FILE — DO NOT SHARE THIS FILE WITH ANYONE
//   static const _serviceAccountJson = {
//     "type": "service_account",
//     "project_id": "flipifly-9df88",
//     "private_key_id": "0dc680ef925d5ee5b29fe5e8881946dfbdd082bb",
//     "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDYDHiIK3KZWIHZ\nlhrx0315v39VIAZ6ojdDq31aOY6AAfQnfsEakiC9QPvsYhIs2I7LT0xap4SCPibh\nS9LFLNTX1Mtwx0RzdV3IxtsGgiQI+4AjLrQs0D3/tBktZMx47WvVonFvi6u/mbnO\ngSSuVObKHUmAr8os22dwkZBo3/65BAQsCTe8WSnXv/GjQh3AcW9li6TPegOF6NX4\neBioOkDlGGro839MIvOQzxIxVvEwtiM68qE8FHWPBnIH7dihxu69QpRI374FcEwa\n8K4zOK1GHGTeeOlgNAeSo1pkzZSS5bhvkNgqoA5dv9JrA3ztWbzPiQ96U/fGe7Hz\nx0OoyU3rAgMBAAECggEALGgfzClWBEPnaLBMOIF2bHRaeUY8Xq+B+XRBry5eZlxA\ncW/BxDLd7NhzD4q23qXib9KMSKPe/iBFQJCjsWh+FSDFchhbLvokPTT2ZveP7ZK4\nK0MZwI5K+AhuFmD+ECsIu6AIfdtxAVBZGyN7RSPpTgjIB13aie7M65vX2V6VDjTu\n8tiURO9ywwPju0jOJF/rwRArq7KFzJ5tLq5UA8mUEIrUmeakyYWGnF3Zh5sgqMUI\nsvmwEa96Q6QUKZwlYt2ashkIgS9rmvmA6e03xxg92eAZZKyRwk/us7Bpm3Unqe3d\nHYuIj+QohzGY5m1POOqW7rYAsRM4Ldm+4pvsJdJSJQKBgQDrvCvzOBLz4XO2/+nj\nHrbIpJzKtdmtZJakEA4erjFBkb1HOYqvD12DRooixciI2R740VnlKYfQJXEEBy3s\nabm4UZJ5qzw7p7awUBHIfrdIDXWFQ0WmoAvNLM0/ihvplL2c7oLfQqiP5CQHehXW\n6CX9T3jAkUffADy6ASnwzTBrBwKBgQDqnw+7XGru564xSNg06HGRMX+ADMGwe/y5\n3SwwbCB4gWV5oOxgwP+gvA82JW09XY3h8E13bj7ERgKiHBKBvv5BP9cW+OZS0aGg\nhDMyg+uLx3i3SHSUmIApYIDfpfOaCgixMdm8hVHcp5P66HLFqwKpjclDBYSF/evK\neQSZQ8o4/QKBgQC9dqqYO6w36S64mSyhBzF/R5Zg8hF2486TI/hFPlmGSp0nHp9R\nHfdZqBsj4XTQUDktYA1xOpTWfRE9XIvTZBIJiz4/nZm2lJAnWuNAEmA6f97BcZUM\nW7vAds6rz9OpQ4u2EpiK2idiJsmyXLQq2sCVvAbgNqPeHnGwSXks+a19hwKBgEam\npV8fQlg0zgCrVegAwwoc5K8TqFPT0lPJ5V+jf9ep53vL2MJ9+7xURSRh+tZK0Mnj\nygAX47DJAEv+thf6Aqh1Z/jT9M+lrs0eYihpD0olRBW1LN3+WkGbfNNcLtIJCXsK\nbu3VG8SddfNNghpCF+gk+SFEjRaoUxPCg37/qeqlAoGAESqEATAgeKsPI3B7jnVO\ntxmKthW7ydnL1eeNX6wijMSznmbvN0V7imDjMRVDbzY98et6icO4ZZH61G29ZUUd\nR+4sk6TlqiutXblCGquTAwF0D2oQun6g9VNooxWElytTb/4hkC+P2KGADfsBYHsi\nuKvuAByKjzWMOaD+vxOPF5Y=\n-----END PRIVATE KEY-----\n",
//     "client_email": "firebase-adminsdk-fbsvc@flipifly-9df88.iam.gserviceaccount.com",
//     "client_id": "117688223934909600208",
//     "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//     "token_uri": "https://oauth2.googleapis.com/token",
//   };
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _bodyController.dispose();
//     super.dispose();
//   }
//
//   Future<void> sendNotification() async {
//     final title = _titleController.text.trim();
//     final body = _bodyController.text.trim();
//
//     if (title.isEmpty || body.isEmpty) {
//       Get.snackbar("Required Fields", "Title and Body cannot be empty",
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.red.shade100,
//           colorText: Colors.red.shade900,
//           icon: const Icon(Icons.warning_amber_rounded, color: Colors.red));
//       return;
//     }
//
//     setState(() => isSending = true);
//
//     try {
//       // 1. Get all FCM tokens from Firestore
//       final snapshot = await FirebaseFirestore.instance
//           .collection("user_fcm_tokens")
//           .get();
//
//       if (snapshot.docs.isEmpty) {
//         Get.snackbar("No Users", "No FCM tokens found in database",
//             snackPosition: SnackPosition.TOP,
//             backgroundColor: Colors.orange.shade100);
//         setState(() => isSending = false);
//         return;
//       }
//
//       final tokens = snapshot.docs
//           .map((d) => d.data()['token'] as String?)
//           .where((t) => t != null && t.isNotEmpty)
//           .cast<String>()
//           .toList();
//
//       // 2. Get OAuth2 token using service account
//       final credentials =
//       ServiceAccountCredentials.fromJson(_serviceAccountJson);
//       final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
//       final authClient = await clientViaServiceAccount(credentials, scopes);
//
//       int successCount = 0;
//       int failCount = 0;
//
//       // 3. Send to each token
//       for (final token in tokens) {
//         try {
//           final response = await authClient.post(
//             Uri.parse(
//                 'https://fcm.googleapis.com/v1/projects/flipifly-9df88/messages:send'),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode({
//               "message": {
//                 "token": token,
//                 "notification": {
//                   "title": title,
//                   "body": body,
//                 },
//                 "android": {
//                   "priority": "high",          // ✅ correct place
//                   "notification": {
//                     "sound": "default",
//                   }
//                 },
//                 "apns": {
//                   "payload": {
//                     "aps": {"sound": "default"}
//                   }
//                 }
//               }
//             }),          );
//
//           if (response.statusCode == 200) {
//             successCount++;
//           } else {
//             failCount++;
//             debugPrint('FCM error: ${response.body}');
//           }
//         } catch (e) {
//           failCount++;
//           debugPrint('Token send error: $e');
//         }
//       }
//
//       authClient.close();
//
//       // 4. Save to history
//       await FirebaseFirestore.instance
//           .collection("admin_notifications")
//           .add({
//         "title": title,
//         "body": body,
//         "imageUrl": "",
//         "targetTopic": selectedTarget,
//         "sentAt": FieldValue.serverTimestamp(),
//         "status": successCount > 0 ? "sent" : "failed",
//         "fcmMessageId": "sent_to_${successCount}_devices",
//       });
//
//       Get.snackbar(
//           "✅ Sent Successfully",
//           "Delivered to $successCount devices${failCount > 0 ? ' ($failCount failed)' : ''}",
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.green.shade100,
//           colorText: Colors.green.shade900,
//           duration: const Duration(seconds: 3));
//
//       _titleController.clear();
//       _bodyController.clear();
//     } catch (e) {
//       debugPrint('Send error: $e');
//       Get.snackbar("Error", e.toString(),
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.red.shade100);
//     } finally {
//       setState(() => isSending = false);
//     }
//   }
//
//   Future<void> _deleteNotification(String docId) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Delete"),
//         content: const Text("Remove this notification from history?"),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text("Cancel")),
//           TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child:
//               const Text("Delete", style: TextStyle(color: Colors.red))),
//         ],
//       ),
//     );
//     if (confirm == true) {
//       await FirebaseFirestore.instance
//           .collection("admin_notifications")
//           .doc(docId)
//           .delete();
//       Get.snackbar("Deleted", "Notification removed from history",
//           snackPosition: SnackPosition.TOP);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(children: [
//               const Icon(Icons.notifications_active_rounded,
//                   size: 32, color: Color(0xFF6C63FF)),
//               const SizedBox(width: 12),
//               const Text("Push Notification Management",
//                   style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1A1A2E))),
//               const Spacer(),
//               Container(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   border: Border.all(color: Colors.green.shade200),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(mainAxisSize: MainAxisSize.min, children: [
//                   Container(
//                       width: 7,
//                       height: 7,
//                       decoration: const BoxDecoration(
//                           color: Colors.green, shape: BoxShape.circle)),
//                   const SizedBox(width: 6),
//                   const Text("FCM Connected",
//                       style: TextStyle(fontSize: 12, color: Colors.green)),
//                 ]),
//               ),
//             ]),
//
//             const SizedBox(height: 24),
//
//             Expanded(
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     flex: 5,
//                     child: Card(
//                       elevation: 4,
//                       shadowColor: Colors.black12,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20)),
//                       color: Colors.white,
//                       child: SingleChildScrollView(
//                         padding: const EdgeInsets.all(28),
//                         child: _buildComposeContent(),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 24),
//                   Expanded(flex: 7, child: _buildHistoryCard()),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildComposeContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: const Color(0xFF6C63FF).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.send_rounded,
//                 color: Color(0xFF6C63FF), size: 20),
//           ),
//           const SizedBox(width: 12),
//           const Text("Send Notification",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
//         ]),
//         const Divider(height: 32),
//         _buildLabel("Notification Title *"),
//         TextField(
//             controller: _titleController,
//             maxLength: 65,
//             decoration:
//             _inputDecoration(hint: "e.g. New feature available!")),
//         const SizedBox(height: 16),
//         _buildLabel("Message Body *"),
//         TextField(
//             controller: _bodyController,
//             maxLines: 4,
//             maxLength: 240,
//             decoration: _inputDecoration(
//                 hint: "Write your notification message here...")),
//         const SizedBox(height: 16),
//         _buildLabel("Target Audience"),
//         DropdownButtonFormField<String>(
//           value: selectedTarget,
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: const Color(0xFFF8F8FF),
//             prefixIcon: const Icon(Icons.group_outlined,
//                 color: Color(0xFF6C63FF)),
//             contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//             enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//             focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide:
//                 const BorderSide(color: Color(0xFF6C63FF), width: 2)),
//           ),
//           dropdownColor: Colors.white,
//           style: const TextStyle(color: Colors.black87, fontSize: 14),
//           items: const [
//             DropdownMenuItem(value: "all_users", child: Text("All Users")),
//           ],
//           onChanged: (v) => setState(() => selectedTarget = v!),
//         ),
//         const SizedBox(height: 28),
//         SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: ElevatedButton.icon(
//             onPressed: isSending ? null : sendNotification,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF6C63FF),
//               foregroundColor: Colors.white,
//               disabledBackgroundColor: Colors.grey.shade300,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14)),
//               elevation: 3,
//             ),
//             icon: isSending
//                 ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                     color: Colors.white, strokeWidth: 2))
//                 : const Icon(Icons.send_rounded),
//             label: Text(isSending ? "Sending..." : "Send to All Users",
//                 style: const TextStyle(
//                     fontSize: 16, fontWeight: FontWeight.w700)),
//           ),
//         ),
//         const SizedBox(height: 8),
//       ],
//     );
//   }
//
//   Widget _buildHistoryCard() {
//     return Card(
//       elevation: 4,
//       shadowColor: Colors.black12,
//       shape:
//       RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(Icons.history_rounded,
//                     color: Colors.orange, size: 20),
//               ),
//               const SizedBox(width: 12),
//               const Text("Notification History",
//                   style: TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.w700)),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                     color: Colors.green.shade50,
//                     borderRadius: BorderRadius.circular(20)),
//                 child: const Text("● Live",
//                     style: TextStyle(fontSize: 11, color: Colors.green)),
//               ),
//             ]),
//             const Divider(height: 28),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection("admin_notifications")
//                     .orderBy("sentAt", descending: true)
//                     .limit(50)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState ==
//                       ConnectionState.waiting) {
//                     return const Center(
//                         child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData ||
//                       snapshot.data!.docs.isEmpty) {
//                     return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.notifications_none_rounded,
//                                 size: 64, color: Colors.grey.shade300),
//                             const SizedBox(height: 12),
//                             Text("No notifications sent yet",
//                                 style: TextStyle(
//                                     color: Colors.grey.shade400,
//                                     fontSize: 16)),
//                           ],
//                         ));
//                   }
//                   final docs = snapshot.data!.docs;
//                   return SingleChildScrollView(
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//                         headingRowColor: WidgetStateProperty.all(
//                             const Color(0xFFF8F8FF)),
//                         dataRowMinHeight: 56,
//                         dataRowMaxHeight: 72,
//                         columnSpacing: 20,
//                         columns: const [
//                           DataColumn(
//                               label: Text("Title",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w700))),
//                           DataColumn(
//                               label: Text("Body",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w700))),
//                           DataColumn(
//                               label: Text("Topic",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w700))),
//                           DataColumn(
//                               label: Text("Date & Time",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w700))),
//                           DataColumn(
//                               label: Text("Status",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w700))),
//                           DataColumn(
//                               label: Text("Action",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w700))),
//                         ],
//                         rows: docs.map((doc) {
//                           final data =
//                           doc.data() as Map<String, dynamic>;
//                           DateTime? sentAtDate;
//                           try {
//                             final sentAt = data["sentAt"];
//                             if (sentAt is Timestamp) {
//                               sentAtDate = sentAt.toDate();
//                             }
//                           } catch (_) {}
//                           final dateStr = sentAtDate != null
//                               ? _formatDate(sentAtDate)
//                               : "-";
//                           return DataRow(cells: [
//                             DataCell(SizedBox(
//                                 width: 150,
//                                 child: Text(data["title"] ?? "",
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 13),
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 2))),
//                             DataCell(SizedBox(
//                                 width: 190,
//                                 child: Text(data["body"] ?? "",
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.black54),
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 2))),
//                             DataCell(Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF6C63FF)
//                                     .withOpacity(0.1),
//                                 borderRadius:
//                                 BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                   data["targetTopic"] ?? "",
//                                   style: const TextStyle(
//                                       fontSize: 11,
//                                       color: Color(0xFF6C63FF),
//                                       fontWeight: FontWeight.w600)),
//                             )),
//                             DataCell(Text(dateStr,
//                                 style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black54))),
//                             DataCell(_statusBadge(
//                                 data["status"] ?? "sent")),
//                             DataCell(IconButton(
//                               icon: const Icon(
//                                   Icons.delete_outline_rounded,
//                                   color: Colors.red,
//                                   size: 20),
//                               tooltip: "Delete",
//                               onPressed: () =>
//                                   _deleteNotification(doc.id),
//                             )),
//                           ]);
//                         }).toList(),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLabel(String text) => Padding(
//     padding: const EdgeInsets.only(bottom: 8),
//     child: Text(text,
//         style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF444466))),
//   );
//
//   InputDecoration _inputDecoration({required String hint}) =>
//       InputDecoration(
//         hintText: hint,
//         hintStyle:
//         const TextStyle(color: Colors.black38, fontSize: 13),
//         filled: true,
//         fillColor: const Color(0xFFF8F8FF),
//         contentPadding:
//         const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//         focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(
//                 color: Color(0xFF6C63FF), width: 2)),
//       );
//
//   Widget _statusBadge(String status) {
//     Color bg, fg;
//     IconData icon;
//     switch (status) {
//       case "sent":
//         bg = Colors.green.shade50;
//         fg = Colors.green.shade700;
//         icon = Icons.check_circle_outline;
//         break;
//       case "failed":
//         bg = Colors.red.shade50;
//         fg = Colors.red.shade700;
//         icon = Icons.error_outline;
//         break;
//       default:
//         bg = Colors.grey.shade100;
//         fg = Colors.grey.shade600;
//         icon = Icons.circle_outlined;
//     }
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//           color: bg, borderRadius: BorderRadius.circular(20)),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         Icon(icon, size: 12, color: fg),
//         const SizedBox(width: 4),
//         Text(status.toUpperCase(),
//             style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w700,
//                 color: fg)),
//       ]),
//     );
//   }
//
//   String _formatDate(DateTime dt) {
//     const months = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//     ];
//     return "${dt.day} ${months[dt.month - 1]} ${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';

// ⚠️  SECURITY WARNING ─────────────────────────────────────────────────────────
// The service-account private key below must NOT live in client-side Flutter
// code. Anyone who decompiles your APK/IPA can extract it and send unlimited
// notifications (or worse) as your Firebase project.
//
// RECOMMENDED FIX → move sendNotification() logic into a Firebase Cloud
// Function (HTTPS callable). The function holds the key server-side; the
// admin app simply calls it. See:
// https://firebase.google.com/docs/functions/callable
// ─────────────────────────────────────────────────────────────────────────────

class PushNotificationAdminScreen extends StatefulWidget {
  const PushNotificationAdminScreen({super.key});

  @override
  State<PushNotificationAdminScreen> createState() =>
      _PushNotificationAdminScreenState();
}

class _PushNotificationAdminScreenState
    extends State<PushNotificationAdminScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  // ── NEW: emoji & route fields ─────────────────────────────────────────────
  String _selectedEmoji = '🔔';
  String _selectedRoute = '';

  // Predefined emoji options shown in the picker
  static const _emojiOptions = [
    '🔔', '🎉', '💳', '🛒', '📣', '⚠️', '✅', '🎁', '🚀', '💬',
  ];

  // Route options mapped to their label (extend to match your app's Routes)
  static const _routeOptions = <String, String>{
    '': 'None / Home',
    '/payment-complete': 'Payment Complete',
    '/profile': 'Profile',
    '/profile-settings': 'Profile Settings',
    '/change-profile': 'Change Profile',
    '/support-tickets': 'Support Tickets',
    '/login': 'Login',
  };

  String selectedTarget = "all_users";
  bool isSending = false;

  // ⚠️  Move this to a Cloud Function — see warning at top of file
  static const _serviceAccountJson = {
    "type": "service_account",
    "project_id": "flipifly-9df88",
    "private_key_id": "0dc680ef925d5ee5b29fe5e8881946dfbdd082bb",
    "private_key":
    "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDYDHiIK3KZWIHZ\nlhrx0315v39VIAZ6ojdDq31aOY6AAfQnfsEakiC9QPvsYhIs2I7LT0xap4SCPibh\nS9LFLNTX1Mtwx0RzdV3IxtsGgiQI+4AjLrQs0D3/tBktZMx47WvVonFvi6u/mbnO\ngSSuVObKHUmAr8os22dwkZBo3/65BAQsCTe8WSnXv/GjQh3AcW9li6TPegOF6NX4\neBioOkDlGGro839MIvOQzxIxVvEwtiM68qE8FHWPBnIH7dihxu69QpRI374FcEwa\n8K4zOK1GHGTeeOlgNAeSo1pkzZSS5bhvkNgqoA5dv9JrA3ztWbzPiQ96U/fGe7Hz\nx0OoyU3rAgMBAAECggEALGgfzClWBEPnaLBMOIF2bHRaeUY8Xq+B+XRBry5eZlxA\ncW/BxDLd7NhzD4q23qXib9KMSKPe/iBFQJCjsWh+FSDFchhbLvokPTT2ZveP7ZK4\nK0MZwI5K+AhuFmD+ECsIu6AIfdtxAVBZGyN7RSPpTgjIB13aie7M65vX2V6VDjTu\n8tiURO9ywwPju0jOJF/rwRArq7KFzJ5tLq5UA8mUEIrUmeakyYWGnF3Zh5sgqMUI\nsvmwEa96Q6QUKZwlYt2ashkIgS9rmvmA6e03xxg92eAZZKyRwk/us7Bpm3Unqe3d\nHYuIj+QohzGY5m1POOqW7rYAsRM4Ldm+4pvsJdJSJQKBgQDrvCvzOBLz4XO2/+nj\nHrbIpJzKtdmtZJakEA4erjFBkb1HOYqvD12DRooixciI2R740VnlKYfQJXEEBy3s\nabm4UZJ5qzw7p7awUBHIfrdIDXWFQ0WmoAvNLM0/ihvplL2c7oLfQqiP5CQHehXW\n6CX9T3jAkUffADy6ASnwzTBrBwKBgQDqnw+7XGru564xSNg06HGRMX+ADMGwe/y5\n3SwwbCB4gWV5oOxgwP+gvA82JW09XY3h8E13bj7ERgKiHBKBvv5BP9cW+OZS0aGg\nhDMyg+uLx3i3SHSUmIApYIDfpfOaCgixMdm8hVHcp5P66HLFqwKpjclDBYSF/evK\neQSZQ8o4/QKBgQC9dqqYO6w36S64mSyhBzF/R5Zg8hF2486TI/hFPlmGSp0nHp9R\nHfdZqBsj4XTQUDktYA1xOpTWfRE9XIvTZBIJiz4/nZm2lJAnWuNAEmA6f97BcZUM\nW7vAds6rz9OpQ4u2EpiK2idiJsmyXLQq2sCVvAbgNqPeHnGwSXks+a19hwKBgEam\npV8fQlg0zgCrVegAwwoc5K8TqFPT0lPJ5V+jf9ep53vL2MJ9+7xURSRh+tZK0Mnj\nygAX47DJAEv+thf6Aqh1Z/jT9M+lrs0eYihpD0olRBW1LN3+WkGbfNNcLtIJCXsK\nbu3VG8SddfNNghpCF+gk+SFEjRaoUxPCg37/qeqlAoGAESqEATAgeKsPI3B7jnVO\ntxmKthW7ydnL1eeNX6wijMSznmbvN0V7imDjMRVDbzY98et6icO4ZZH61G29ZUUd\nR+4sk6TlqiutXblCGquTAwF0D2oQun6g9VNooxWElytTb/4hkC+P2KGADfsBYHsi\nuKvuAByKjzWMOaD+vxOPF5Y=\n-----END PRIVATE KEY-----\n",
    "client_email":
    "firebase-adminsdk-fbsvc@flipifly-9df88.iam.gserviceaccount.com",
    "client_id": "117688223934909600208",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
  };

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> sendNotification() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      Get.snackbar(
        "Required Fields", "Title and Body cannot be empty",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
      );
      return;
    }

    setState(() => isSending = true);

    try {
      // 1. Get all FCM tokens from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection("user_fcm_tokens")
          .get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar("No Users", "No FCM tokens found in database",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.shade100);
        setState(() => isSending = false);
        return;
      }

      final tokens = snapshot.docs
          .map((d) => d.data()['token'] as String?)
          .where((t) => t != null && t.isNotEmpty)
          .cast<String>()
          .toList();

      // 2. Get OAuth2 token
      final credentials =
      ServiceAccountCredentials.fromJson(_serviceAccountJson);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final authClient = await clientViaServiceAccount(credentials, scopes);

      int successCount = 0;
      int failCount = 0;

      // 3. Send to each token
      for (final token in tokens) {
        try {
          final response = await authClient.post(
            Uri.parse(
                'https://fcm.googleapis.com/v1/projects/flipifly-9df88/messages:send'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "message": {
                "token": token,
                "notification": {
                  "title": title,
                  "body": body,
                },
                // ✅ FIX: data block so mobile app can store emoji + route
                //    in NotificationController.addNotification()
                "data": {
                  "emoji": _selectedEmoji,
                  "route": _selectedRoute,
                },
                "android": {
                  "priority": "high",
                  "notification": {
                    "sound": "default",
                  },
                },
                "apns": {
                  "payload": {
                    "aps": {"sound": "default"},
                  },
                },
              },
            }),
          );

          if (response.statusCode == 200) {
            successCount++;
          } else {
            failCount++;
            debugPrint('FCM error [${response.statusCode}]: ${response.body}');
          }
        } catch (e) {
          failCount++;
          debugPrint('Token send error: $e');
        }
      }

      authClient.close();

      // 4. Save to history (now includes emoji + route)
      await FirebaseFirestore.instance.collection("admin_notifications").add({
        "title": title,
        "body": body,
        "emoji": _selectedEmoji,
        "route": _selectedRoute,
        "imageUrl": "",
        "targetTopic": selectedTarget,
        "sentAt": FieldValue.serverTimestamp(),
        "status": successCount > 0 ? "sent" : "failed",
        "fcmMessageId": "sent_to_${successCount}_devices",
      });

      Get.snackbar(
        "✅ Sent Successfully",
        "Delivered to $successCount devices"
            "${failCount > 0 ? ' ($failCount failed)' : ''}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 3),
      );

      _titleController.clear();
      _bodyController.clear();
      setState(() {
        _selectedEmoji = '🔔';
        _selectedRoute = '';
      });
    } catch (e) {
      debugPrint('Send error: $e');
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100);
    } finally {
      setState(() => isSending = false);
    }
  }

  Future<void> _deleteNotification(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete"),
        content: const Text("Remove this notification from history?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
              const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection("admin_notifications")
          .doc(docId)
          .delete();
      Get.snackbar("Deleted", "Notification removed from history",
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Row(children: [
              const Icon(Icons.notifications_active_rounded,
                  size: 32, color: Color(0xFF6C63FF)),
              const SizedBox(width: 12),
              const Text("Push Notification Management",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text("FCM Connected",
                      style: TextStyle(fontSize: 12, color: Colors.green)),
                ]),
              ),
            ]),

            const SizedBox(height: 24),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.white,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(28),
                        child: _buildComposeContent(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(flex: 7, child: _buildHistoryCard()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.send_rounded,
                color: Color(0xFF6C63FF), size: 20),
          ),
          const SizedBox(width: 12),
          const Text("Send Notification",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
        const Divider(height: 32),

        // Title
        _buildLabel("Notification Title *"),
        TextField(
            controller: _titleController,
            maxLength: 65,
            decoration:
            _inputDecoration(hint: "e.g. New feature available!")),
        const SizedBox(height: 16),

        // Body
        _buildLabel("Message Body *"),
        TextField(
            controller: _bodyController,
            maxLines: 4,
            maxLength: 240,
            decoration: _inputDecoration(
                hint: "Write your notification message here...")),
        const SizedBox(height: 16),

        // ── NEW: Emoji picker ───────────────────────────────────────────
        _buildLabel("Emoji"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _emojiOptions.map((emoji) {
            final isSelected = emoji == _selectedEmoji;
            return GestureDetector(
              onTap: () => setState(() => _selectedEmoji = emoji),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6C63FF).withOpacity(0.12)
                      : const Color(0xFFF8F8FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFFE0E0E0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // ── NEW: Route dropdown ─────────────────────────────────────────
        _buildLabel("Navigate to (on tap)"),
        DropdownButtonFormField<String>(
          value: _selectedRoute,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F8FF),
            prefixIcon: const Icon(Icons.navigation_outlined,
                color: Color(0xFF6C63FF)),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                const BorderSide(color: Color(0xFF6C63FF), width: 2)),
          ),
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          items: _routeOptions.entries
              .map((e) => DropdownMenuItem(
            value: e.key,
            child: Text(e.value),
          ))
              .toList(),
          onChanged: (v) => setState(() => _selectedRoute = v ?? ''),
        ),
        const SizedBox(height: 16),

        // Target audience
        _buildLabel("Target Audience"),
        DropdownButtonFormField<String>(
          value: selectedTarget,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F8FF),
            prefixIcon: const Icon(Icons.group_outlined,
                color: Color(0xFF6C63FF)),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                const BorderSide(color: Color(0xFF6C63FF), width: 2)),
          ),
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          items: const [
            DropdownMenuItem(value: "all_users", child: Text("All Users")),
          ],
          onChanged: (v) => setState(() => selectedTarget = v!),
        ),
        const SizedBox(height: 28),

        // ── Preview chip ────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
          ),
          child: Row(children: [
            Text(_selectedEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleController.text.isEmpty
                        ? 'Notification Title'
                        : _titleController.text,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _bodyController.text.isEmpty
                        ? 'Message body will appear here…'
                        : _bodyController.text,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Send button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: isSending ? null : sendNotification,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 3,
            ),
            icon: isSending
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send_rounded),
            label: Text(isSending ? "Sending..." : "Send to All Users",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.history_rounded,
                    color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              const Text("Notification History",
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text("● Live",
                    style: TextStyle(fontSize: 11, color: Colors.green)),
              ),
            ]),
            const Divider(height: 28),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("admin_notifications")
                    .orderBy("sentAt", descending: true)
                    .limit(50)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none_rounded,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text("No notifications sent yet",
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 16)),
                          ],
                        ));
                  }
                  final docs = snapshot.data!.docs;
                  return SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                            const Color(0xFFF8F8FF)),
                        dataRowMinHeight: 56,
                        dataRowMaxHeight: 72,
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(
                              label: Text("Title",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700))),
                          DataColumn(
                              label: Text("Body",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700))),
                          // ✅ NEW column
                          DataColumn(
                              label: Text("Emoji",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700))),
                          DataColumn(
                              label: Text("Route",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700))),
                          DataColumn(
                              label: Text("Topic",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700))),
                          DataColumn(
                              label: Text("Date & Time",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700))),
                          DataColumn(
                              label: Text("Status",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700))),
                          DataColumn(
                              label: Text("Action",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700))),
                        ],
                        rows: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          DateTime? sentAtDate;
                          try {
                            final sentAt = data["sentAt"];
                            if (sentAt is Timestamp) {
                              sentAtDate = sentAt.toDate();
                            }
                          } catch (_) {}
                          final dateStr =
                          sentAtDate != null ? _formatDate(sentAtDate) : "-";
                          return DataRow(cells: [
                            DataCell(SizedBox(
                                width: 150,
                                child: Text(data["title"] ?? "",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2))),
                            DataCell(SizedBox(
                                width: 190,
                                child: Text(data["body"] ?? "",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2))),
                            // ✅ NEW: emoji cell
                            DataCell(Text(data["emoji"] ?? "🔔",
                                style: const TextStyle(fontSize: 18))),
                            // ✅ NEW: route cell
                            DataCell(SizedBox(
                                width: 120,
                                child: Text(
                                  data["route"]?.toString().isEmpty ?? true
                                      ? 'None'
                                      : data["route"],
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.black54),
                                  overflow: TextOverflow.ellipsis,
                                ))),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(data["targetTopic"] ?? "",
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6C63FF),
                                      fontWeight: FontWeight.w600)),
                            )),
                            DataCell(Text(dateStr,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54))),
                            DataCell(
                                _statusBadge(data["status"] ?? "sent")),
                            DataCell(IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.red, size: 20),
                              tooltip: "Delete",
                              onPressed: () => _deleteNotification(doc.id),
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF444466))),
  );

  InputDecoration _inputDecoration({required String hint}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
    filled: true,
    fillColor: const Color(0xFFF8F8FF),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: Color(0xFF6C63FF), width: 2)),
  );

  Widget _statusBadge(String status) {
    Color bg, fg;
    IconData icon;
    switch (status) {
      case "sent":
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        icon = Icons.check_circle_outline;
        break;
      case "failed":
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        icon = Icons.error_outline;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade600;
        icon = Icons.circle_outlined;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: fg),
        const SizedBox(width: 4),
        Text(status.toUpperCase(),
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
      ]),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}  "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}