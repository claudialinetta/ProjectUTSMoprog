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
    }
  }

  String _time() {
    final hour = item.happenedAt.hour.toString().padLeft(2, '0');
    final minute = item.happenedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final statusColor = _statusColor();
    final isSpam = item.status == CallStatus.spam;

    final typeColor = item.type == CallType.missed
        ? (isDark ? Colors.red.shade400 : Colors.red)
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600);

    final Color? cardColor = isDark
        ? (isSpam ? Colors.red.withValues(alpha: 0.1) : const Color(0xFF1E1E1E))
        : null;

    final Color borderColor = isSpam
        ? (isDark ? Colors.red.shade800 : Colors.red.shade200)
        : (isDark ? const Color(0xFF2C2C2C) : Colors.transparent);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: isDark ? 0 : 1,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor),
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
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.phoneNumber,
              style: TextStyle(color: isDark ? Colors.grey.shade400 : null),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(_typeIcon(), size: 14, color: typeColor),
                const SizedBox(width: 4),
                Text(
                  item.durationSeconds > 0
                      ? '${item.type.label} • ${_time()} • ${item.formattedDuration}'
                      : '${item.type.label} • ${_time()}',
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
