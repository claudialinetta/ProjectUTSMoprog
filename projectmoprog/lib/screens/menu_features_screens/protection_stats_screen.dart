import 'package:flutter/material.dart';
import 'package:projectmoprog/services/protection_stats_service.dart';

import '../../models/protection_stats.dart';
import '../../models/call_history_model.dart';

class ProtectionStatsScreen extends StatefulWidget {
  final String ownerId;

  const ProtectionStatsScreen({super.key, required this.ownerId});

  @override
  State<ProtectionStatsScreen> createState() => _ProtectionStatsScreenState();
}

class _ProtectionStatsScreenState extends State<ProtectionStatsScreen> {
  final ProtectionStatsService _service = ProtectionStatsService();

  ProtectionStats _stats = const ProtectionStats.empty();

  List<ProtectionActivity> _activity = [];
  List<CallHistoryModel> _recentCalls = [];

  bool _isLoading = true;
  bool _showRecentActivity = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _service.getStats(widget.ownerId);
      final recentChecks = await _service.getRecentChecks(widget.ownerId);
      final recentCalls = await _service.getRecentCalls(widget.ownerId);

      if (!mounted) return;

      setState(() {
        _stats = stats;

        _activity = recentChecks.map((item) {
          final checkedAt = DateTime.parse(item['checked_at'].toString());

          return ProtectionActivity(
            message: '${item['name']} (${item['phone_number']})',
            createdAt: checkedAt,
          );
        }).toList();

        _recentCalls = recentCalls;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      debugPrint('Failed to load protection stats: $e');

      setState(() {
        _isLoading = false;
        _error =
            'Failed to load your stats.\n'
            'Check your internet connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protection Stats')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildError();
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildIntro(),

          const SizedBox(height: 20),

          // Numbers Checked
          _buildNumbersCheckedCard(),

          const SizedBox(height: 12),

          // Spam Avoided
          _buildStatCard(
            icon: Icons.shield_outlined,
            color: Colors.red,
            label: 'Spam Avoided',
            value: _stats.spamAvoided,
            description:
                'Numbers flagged as spam before you had to find out yourself.',
          ),

          const SizedBox(height: 12),

          // Reports Given
          _buildStatCard(
            icon: Icons.flag_outlined,
            color: Colors.orange,
            label: 'Reports Given',
            value: _stats.reportsGiven,
            description: 'Reports you contributed to help protect other users.',
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return const Text(
      'Here is how you have been protected and how you have helped '
      'protect others.',
      style: TextStyle(color: Colors.black54),
    );
  }

  Widget _buildNumbersCheckedCard() {
    final activities = _buildCombinedActivities();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.withValues(alpha: 0.15),
                  child: const Icon(Icons.search, color: Colors.blue),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_stats.numbersChecked}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Numbers Checked',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Numbers you have searched or checked through this app.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (activities.isNotEmpty) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),

            InkWell(
              onTap: () {
                setState(() {
                  _showRecentActivity = !_showRecentActivity;
                });
              },
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.history, size: 20, color: Colors.grey.shade700),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Text(
                        'Recent Activity',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),

                    Icon(
                      _showRecentActivity
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ),

            if (_showRecentActivity) _buildActivityList(activities),
          ],
        ],
      ),
    );
  }

  List<_ActivityItem> _buildCombinedActivities() {
    final List<_ActivityItem> activities = [];

    for (final activity in _activity) {
      activities.add(
        _ActivityItem(
          name: activity.message,
          subtitle: 'Number checked',
          date: activity.createdAt,
          icon: Icons.search,
          iconColor: Colors.blue,
        ),
      );
    }

    for (final call in _recentCalls) {
      activities.add(
        _ActivityItem(
          name: '${call.name} (${call.phoneNumber})',
          subtitle: _getCallTypeLabel(call.type),
          date: call.happenedAt,
          icon: _getCallIcon(call.type),
          iconColor: _getCallIconColor(call.type),
        ),
      );
    }

    activities.sort((a, b) => b.date.compareTo(a.date));

    return activities.take(10).toList();
  }

  Widget _buildActivityList(List<_ActivityItem> activities) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Column(
        children: activities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;

          return _buildActivityItem(
            activity,
            isLast: index == activities.length - 1,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityItem(_ActivityItem activity, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
          child: Column(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: activity.iconColor.withValues(alpha: 0.12),
                child: Icon(activity.icon, size: 17, color: activity.iconColor),
              ),

              if (!isLast)
                Container(width: 1, height: 34, color: Colors.grey.shade300),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        activity.subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  _formatRelativeTime(activity.date),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required int value,
    required String description,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCallIcon(CallType type) {
    switch (type) {
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

  Color _getCallIconColor(CallType type) {
    switch (type) {
      case CallType.incoming:
        return Colors.green;

      case CallType.outgoing:
        return Colors.blue;

      case CallType.missed:
        return Colors.red;

      case CallType.searched:
        return Colors.blue;
    }
  }

  String _getCallTypeLabel(CallType type) {
    switch (type) {
      case CallType.incoming:
        return 'Incoming call';

      case CallType.outgoing:
        return 'Outgoing call';

      case CallType.missed:
        return 'Missed call';

      case CallType.searched:
        return 'Searched';
    }
  }

  String _formatRelativeTime(DateTime date) {
    final difference = DateTime.now().difference(date.toLocal());

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}';
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Colors.grey.shade500),

            const SizedBox(height: 12),

            Text(_error!, textAlign: TextAlign.center),

            const SizedBox(height: 16),

            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem {
  final String name;
  final String subtitle;
  final DateTime date;
  final IconData icon;
  final Color iconColor;

  const _ActivityItem({
    required this.name,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.iconColor,
  });
}
