import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  final CollectionReference ticketsCollection =
  FirebaseFirestore.instance.collection('support_tickets');

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  void _createDummyTicket() async {
    final ticketId = (Random().nextInt(90000) + 10000).toString(); // 5-digit ID
    await ticketsCollection.doc(ticketId).set({
      'topic': 'Sample Issue',
      'details':
      'User cannot login to the app. Please assist as soon as possible.',
      'userEmail': 'user@example.com',
      'userName': 'John Doe',
      'userId': 'user123',
      'status': 'in process',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return const Color(0xFF22C55E); // green
      case 'in process':
        return const Color(0xFFFACC15); // amber
      case 'not applicable':
        return const Color(0xFF9CA3AF); // gray
      default:
        return const Color(0xFF835FFF); // primary
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1FE),
      appBar: AppBar(
        title: const Text('Support Tickets'),
        backgroundColor: const Color(0xFF835FFF),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFF835FFF)),
                hintText: 'Search tickets...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => searchQuery = val.trim()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ticketsCollection
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child:
                      CircularProgressIndicator(color: Color(0xFF835FFF)));
                }
                final tickets = snapshot.data!.docs.where((ticket) {
                  final data = ticket.data() as Map<String, dynamic>;
                  final topic = data['topic'] ?? '';
                  final email = data['userEmail'] ?? '';
                  return topic.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      email.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      ticket.id.contains(searchQuery);
                }).toList();

                if (tickets.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tickets found.',
                      style: TextStyle(fontSize: 16, color: Color(0xFF222222)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    final data = ticket.data() as Map<String, dynamic>;
                    final status = (data['status'] ?? 'in process').toString();

                    return GestureDetector(
                      onTap: () {
                        Get.to(() =>
                            TicketDetailScreen(ticketId: ticket.id));
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEFF1FE), Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      data['topic'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF222222)),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                          color: _getStatusColor(status),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('User: ${data['userName']}',
                                  style: const TextStyle(
                                      color: Color(0xFF222222))),
                              Text('Email: ${data['userEmail']}',
                                  style: const TextStyle(
                                      color: Color(0xFF222222))),
                              Text('Ticket ID: ${ticket.id}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF835FFF))),
                              const SizedBox(height: 8),
                              Text(
                                data['details'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Color(0xFF222222)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createDummyTicket,
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
        backgroundColor: const Color(0xFF835FFF),
      ),
    );
  }
}

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _replyController = TextEditingController();
  String _status = 'in process';

  Future<DocumentSnapshot> _loadTicket() {
    return _db.collection('support_tickets').doc(widget.ticketId).get();
  }

  Future<void> _updateTicket() async {
    await _db.collection('support_tickets').doc(widget.ticketId).update({
      'status': _status,
      'adminReply': _replyController.text.trim(),
    });
    Get.back();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return const Color(0xFF22C55E);
      case 'in process':
        return const Color(0xFFFACC15);
      case 'not applicable':
        return const Color(0xFF9CA3AF);
      default:
        return const Color(0xFF835FFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1FE),
      appBar: AppBar(
        title: const Text('Ticket Detail'),
        backgroundColor: const Color(0xFF835FFF),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _loadTicket(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child:
                CircularProgressIndicator(color: Color(0xFF835FFF)));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          _status = data['status'] ?? _status;
          _replyController.text = data['adminReply'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF835FFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(data['topic'] ?? '',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222))),
                ),
                const SizedBox(height: 16),
                Text('Details:',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                const SizedBox(height: 6),
                Text(data['details'] ?? '', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Text('User Information',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                const SizedBox(height: 6),
                Text('Name: ${data['userName']}'),
                Text('Email: ${data['userEmail']}'),
                Text('User ID: ${data['userId']}'),
                const SizedBox(height: 16),
                Text('Ticket ID: ${widget.ticketId}'),
                const SizedBox(height: 16),
                TextField(
                  controller: _replyController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Admin Reply',
                    labelStyle: const TextStyle(color: Color(0xFF835FFF)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF835FFF))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF835FFF))),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: const TextStyle(color: Color(0xFF835FFF)),
                    filled: true,
                    fillColor: Colors.white, // solid background for the field
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF835FFF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF835FFF)),
                    ),
                  ),
                  dropdownColor: Colors.white, // solid background for dropdown menu
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF835FFF)),
                  style: const TextStyle(color: Colors.black, fontSize: 16), // menu text style
                  items: const [
                    DropdownMenuItem(
                      value: 'resolved',
                      child: Text('Resolved'),
                    ),
                    DropdownMenuItem(
                      value: 'in process',
                      child: Text('In Process'),
                    ),
                    DropdownMenuItem(
                      value: 'not applicable',
                      child: Text('Not Applicable'),
                    ),
                  ],
                  onChanged: (val) => setState(() => _status = val ?? 'in process'),
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _updateTicket,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF835FFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text('Update Ticket',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
