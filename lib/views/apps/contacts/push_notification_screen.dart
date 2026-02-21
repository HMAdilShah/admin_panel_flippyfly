import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final _customTopicController = TextEditingController();

  String selectedTarget = "all_users";
  bool isSending = false;

  // 🔐 YOUR FCM SERVER KEY
  static const String serverKey = "YOUR_SERVER_KEY_HERE";

  // ================= SEND NOTIFICATION =================
  Future<void> sendNotification() async {

    if (_titleController.text.trim().isEmpty ||
        _bodyController.text.trim().isEmpty) {
      Get.snackbar(
        "Required",
        "Title and Body are required",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    String topic = selectedTarget == "custom"
        ? _customTopicController.text.trim()
        : selectedTarget;

    if (topic.isEmpty) {
      Get.snackbar("Topic Required", "Please enter custom topic");
      return;
    }

    setState(() => isSending = true);

    try {
      final response = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "key=$serverKey",
        },
        body: jsonEncode({
          "to": "/topics/$topic",
          "notification": {
            "title": _titleController.text.trim(),
            "body": _bodyController.text.trim(),
          },
          "priority": "high",
        }),
      );

      if (response.statusCode == 200) {

        await FirebaseFirestore.instance
            .collection("admin_notifications")
            .add({
          "title": _titleController.text.trim(),
          "body": _bodyController.text.trim(),
          "targetTopic": topic,
          "sentAt": FieldValue.serverTimestamp(),
        });

        Get.snackbar(
          "Success",
          "Notification sent successfully",
          snackPosition: SnackPosition.TOP,
        );

        _titleController.clear();
        _bodyController.clear();
        _customTopicController.clear();

      } else {
        Get.snackbar("Error", response.body);
      }

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      setState(() => isSending = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Push Notification Management",
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          // ================= SEND CARD =================
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Send Notification",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _bodyController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Body",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedTarget,
                    decoration: InputDecoration(
                      labelText: "Target Audience",
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white, // ✅ makes background white
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    dropdownColor: Colors.white, // ✅ dropdown menu background
                    style: const TextStyle(color: Colors.black),
                    items: const [
                      DropdownMenuItem(
                          value: "all_users",
                          child: Text("All Users")),
                      DropdownMenuItem(
                          value: "premium_users",
                          child: Text("Premium Users")),
                      DropdownMenuItem(
                          value: "free_users",
                          child: Text("Free Users")),
                      DropdownMenuItem(
                          value: "custom",
                          child: Text("Custom Topic")),
                    ],
                    onChanged: (value) {
                      setState(() => selectedTarget = value!);
                    },
                  ),

                  if (selectedTarget == "custom") ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _customTopicController,
                      decoration: const InputDecoration(
                        labelText: "Custom Topic Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  SizedBox(
                    width: 200,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: isSending ? null : sendNotification,
                      child: isSending
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                          : const Text("Send Notification"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            "Notification History",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("admin_notifications")
                  .orderBy("sentAt", descending: true)
                  .limit(30)
                  .snapshots(),
              builder: (_, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("Title")),
                        DataColumn(label: Text("Topic")),
                        DataColumn(label: Text("Date")),
                      ],
                      rows: docs.map((doc) {
                        final data =
                        doc.data() as Map<String, dynamic>;

                        return DataRow(cells: [
                          DataCell(Text(data["title"] ?? "")),
                          DataCell(Text(data["targetTopic"] ?? "")),
                          DataCell(Text(
                            data["sentAt"] != null
                                ? (data["sentAt"] as Timestamp)
                                .toDate()
                                .toString()
                                : "-",
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
    );
  }
}
