import 'package:flutter/material.dart';

import '../models/call_history_model.dart';

class CallHistoryTile extends StatelessWidget {
  final CallHistoryModel item;
  const CallHistoryTile({super.key, required this.item});

  Color _statusColor() {
    switch (item.status) {
      case CallStatus.trusted:
        return Colors.green;
      case CallStatus.spam:
        return Colors.red;
      case CallStatus.unknown:
        return Colors.grey;
    }
  }

  IconData _typeIcon() {
    switch (item.type) {
      case CallType.incoming:
        return Icons.call_received;
      case CallType.outgoing:
        return Icons.call_made;
      case CallType.missed:
        return Icons.call_missed;
      case CallType.searched:
        return Icons.search;
    }
  }

  String _time() {
    final hour = item.happenedAt.hour.toString().padLeft(2, '0');
    final minute = item.happenedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final isSpam = item.status == CallStatus.spam;
    final typeColor = item.type == CallType.missed
        ? Colors.red
        : Colors.grey.shade600;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSpam ? Colors.red.shade200 : Colors.transparent,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Text(
            item.initial,
            style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.phoneNumber),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(_typeIcon(), size: 14, color: typeColor),
                const SizedBox(width: 4),
                Text(
                  '${item.type.label} • ${_time()}',
                  style: TextStyle(fontSize: 12, color: typeColor),
                ),
              ],
            ),
          ],
        ),
        trailing: _buildBadge(statusColor),
      ),
    );
  }

  Widget _buildBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        item.status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
