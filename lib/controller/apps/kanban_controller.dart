import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webkit/controller/my_controller.dart';
import 'package:appflowy_board/appflowy_board.dart';
import 'package:webkit/images.dart';
import 'package:webkit/models/support_ticket.dart';

class KanBanController extends MyController {
  final AppFlowyBoardController boardData = AppFlowyBoardController(
    onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
      debugPrint('Move item from $fromIndex to $toIndex');
    },
    onMoveGroupItem: (groupId, fromIndex, toIndex) {
      debugPrint('Move $groupId:$fromIndex to $groupId:$toIndex');
    },
    onMoveGroupItemToGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
      debugPrint('Move $fromGroupId:$fromIndex to $toGroupId:$toIndex');
    },
  );
  late AppFlowyBoardScrollController boardController;

  @override
  void onInit() {
    super.onInit();
    fetchSupportTickets();
  }

  Future<List<SupportTicket>> fetchSupportTickets() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('support_tickets').get();
      final users = snapshot.docs.map((doc) {
        return SupportTicket.fromMap(doc.data());
      }).toList();
      return users.sublist(0, users.length);
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<void> fetchAndPopulateTickets() async {
    try {
      final tickets = await fetchSupportTickets();

      // Group tickets by their status (To Do, In Progress, Done, etc.)
      final Map<String, List<SupportTicket>> groupedTickets = {};

      for (var ticket in tickets) {
        final status = ticket.status.isNotEmpty ? ticket.status : 'To Do';
        groupedTickets.putIfAbsent(status, () => []).add(ticket);
      }

      // Clear existing groups if needed

      // Add groups to board
      groupedTickets.forEach((status, ticketList) {
        final items = ticketList.map((ticket) {
          return TextItem(
            ticket.topic, // Default priority, or you could derive from logic
            Colors.brown, // Based on priority if needed
            _formatDate(ticket.timestamp),
            ticket.description,
            ticket.name,
            ticket.avatarUrl,
            ticket.email, // jobType placeholder
          );
        }).toList();

        boardData.addGroup(AppFlowyGroupData(
          id: status,
          name: status,
          items: items,
        ));
      });
    } catch (e) {
      debugPrint('Error fetching and displaying tickets: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

}

class TextItem extends AppFlowyGroupItem {
  final String kanbanLevel;
  final Color color;
  final String date, title, name, image, jobTypeName;

  TextItem(
      this.kanbanLevel,
      this.color,
      this.date,
      this.title,
      this.name,
      this.image,
      this.jobTypeName,
      );

  @override
  String get id => title;
}
