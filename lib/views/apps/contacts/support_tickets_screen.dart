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
  final ticketsCollection =
  FirebaseFirestore.instance.collection('support_tickets');

  final TextEditingController _searchController = TextEditingController();

  String searchQuery = '';
  String statusFilter = 'all';
  bool sortDescending = true;

  void _createDummyTicket() async {
    final ticketId = (Random().nextInt(90000) + 10000).toString();
    await ticketsCollection.doc(ticketId).set({
      'topic': 'Sample Issue',
      'details': 'User cannot login to the app.',
      'userEmail': 'user@example.com',
      'userName': 'John Doe',
      'userId': 'user123',
      'status': 'in process',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '--';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return '--';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1FE),
      appBar: AppBar(
        title: const Text('Support Tickets'),
        backgroundColor: const Color(0xFF835FFF),
      ),
      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => searchQuery = v.trim()),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFF835FFF)),
                hintText: 'Search tickets...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // FILTER BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                StatusFilterPopup(
                  value: statusFilter,
                  onChanged: (v) => setState(() => statusFilter = v),
                ),
                const SizedBox(width: 12),
                SortButton(
                  descending: sortDescending,
                  onToggle: () =>
                      setState(() => sortDescending = !sortDescending),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ticketsCollection.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tickets = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final topic = (data['topic'] ?? '').toString().toLowerCase();
                  final email =
                  (data['userEmail'] ?? '').toString().toLowerCase();
                  final status = (data['status'] ?? '').toString();

                  final matchesSearch =
                      topic.contains(searchQuery.toLowerCase()) ||
                          email.contains(searchQuery.toLowerCase()) ||
                          doc.id.contains(searchQuery);

                  final matchesStatus =
                      statusFilter == 'all' || status == statusFilter;

                  return matchesSearch && matchesStatus;
                }).toList();

                tickets.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>?;
                  final bData = b.data() as Map<String, dynamic>?;

                  final aTime = aData?['createdAt'] is Timestamp
                      ? (aData!['createdAt'] as Timestamp).toDate()
                      : DateTime.fromMillisecondsSinceEpoch(0);

                  final bTime = bData?['createdAt'] is Timestamp
                      ? (bData!['createdAt'] as Timestamp).toDate()
                      : DateTime.fromMillisecondsSinceEpoch(0);

                  return sortDescending
                      ? bTime.compareTo(aTime)
                      : aTime.compareTo(bTime);
                });

                if (tickets.isEmpty) {
                  return const Center(child: Text('No tickets found'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tickets.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 140,
                  ),
                  itemBuilder: (context, index) {
                    final doc = tickets[index];
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    final status = data['status'] ?? 'in process';
                    final ticketNo = data['ticketNo'];

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () =>
                          Get.to(() => TicketDetailScreen(ticketId: doc.id)),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8), // ← tighter padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Ticket ID + Status
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ticketNo != null
                                        ? '#$ticketNo'
                                        : '#----', // ← shorter label
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        color: _getStatusColor(status),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // Topic
                              Text(
                                data['topic'] ?? 'No topic',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),

                              const SizedBox(height: 3),

                              // Preview
                              Text(
                                data['details'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 11.5,
                                  height: 1.2,
                                ),
                              ),

                              const Spacer(),

                              // User + Date
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 12),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      data['userName'] ?? 'Unknown',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatDate(data['createdAt']),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
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
        backgroundColor: const Color(0xFF835FFF),
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
    );
  }
}

class StatusFilterPopup extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const StatusFilterPopup({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.white,
      onSelected: onChanged,
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'all', child: Text('All Statuses')),
        PopupMenuItem(value: 'resolved', child: Text('Resolved')),
        PopupMenuItem(value: 'in process', child: Text('In Process')),
        PopupMenuItem(value: 'not applicable', child: Text('Not Applicable')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              value == 'all' ? 'All Statuses' : value.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class SortButton extends StatelessWidget {
  final bool descending;
  final VoidCallback onToggle;

  const SortButton({
    super.key,
    required this.descending,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        descending ? Icons.arrow_downward : Icons.arrow_upward,
        color: const Color(0xFF835FFF),
      ),
      tooltip: 'Sort by date',
    );
  }
}

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

String _statusFilter = 'all';

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
                child: CircularProgressIndicator(color: Color(0xFF835FFF)));
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
                Text(data['details'] ?? '',
                    style: const TextStyle(fontSize: 16)),
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
                StatusFilterDropdown(
                  value: _statusFilter,
                  onChanged: (val) {
                    setState(() => _statusFilter = val);
                  },
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

class StatusFilterDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const StatusFilterDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'all',
          child: Text('All Statuses'),
        ),
        PopupMenuItem(
          value: 'resolved',
          child: Text('Resolved'),
        ),
        PopupMenuItem(
          value: 'in process',
          child: Text('In Process'),
        ),
        PopupMenuItem(
          value: 'not applicable',
          child: Text('Not Applicable'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value == 'all' ? 'All Statuses' : value.toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF835FFF)),
          ],
        ),
      ),
    );
  }
}