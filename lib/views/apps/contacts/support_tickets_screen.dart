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

                /*return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final doc = tickets[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'in process';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Get.to(
                            () => TicketDetailScreen(ticketId: doc.id)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TOP ROW: Ticket ID + Status
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ticket #${doc.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status)
                                          .withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        color: _getStatusColor(status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // TOPIC
                              Text(
                                data['topic'] ?? 'No topic',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // DETAILS PREVIEW
                              Text(
                                data['details'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // USER + DATE
                              Row(
                                children: [
                                  const Icon(Icons.person_outline,
                                      size: 16),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${data['userName'] ?? 'Unknown'} • ${data['userEmail'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDate(data['createdAt']),
                                    style: const TextStyle(
                                      fontSize: 12,
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
                );*/

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tickets.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 🔥 2 tickets per row
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.25, // balanced card height
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ticket ID + Status
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Text(
                                    ticketNo != null ? 'Ticket #$ticketNo' : 'Ticket #----',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        color: _getStatusColor(status),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Topic
                              Text(
                                data['topic'] ?? 'No topic',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Preview
                              Expanded(
                                child: Text(
                                  data['details'] ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              // User + Date
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      data['userName'] ?? 'Unknown',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatDate(data['createdAt']),
                                    style: const TextStyle(
                                      fontSize: 11,
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
      // ✅ REAL background color
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
