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
  List<CheckEntry> _spamHistory = [];
  List<ReportHistoryEntry> _reportHistory = [];

  List<Map<String, dynamic>> _checkActivity = [];

  Map<String, dynamic> _insights = {};

  bool _isLoading = true;
  bool _showRecentActivity = false;
  bool _showInsights = true;

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
      final activity = await _service.getCheckActivity(widget.ownerId);
      final insights = await _service.getProtectionInsights(widget.ownerId);

      final spamHistory = await _service.getSpamHistory(widget.ownerId);
      final reportHistory = await _service.getReportHistory(widget.ownerId);

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
        _checkActivity = activity;
        _insights = insights;

        _spamHistory = spamHistory;
        _reportHistory = reportHistory;

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

          _buildNumbersCheckedCard(),

          const SizedBox(height: 12),

          _buildInsightsCard(),

          const SizedBox(height: 12),

          _buildExpandableStatCard(
            icon: Icons.shield_outlined,
            color: Colors.red,
            label: 'Spam Avoided',
            value: _stats.spamAvoided,
            description:
                'Numbers flagged as spam before you had to find out yourself.',
            children: _spamHistory.map((item) {
              return _buildHistoryRow(
                icon: Icons.shield_outlined,
                color: Colors.red,
                title: item.name,
                subtitle:
                    '${item.phoneNumber} • ${_formatRelativeTime(item.checkedAt)}',
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          _buildExpandableStatCard(
            icon: Icons.flag_outlined,
            color: Colors.orange,
            label: 'Reports Given',
            value: _stats.reportsGiven,
            description: 'Reports you contributed to help protect other users.',
            children: _reportHistory.map((item) {
              return _buildHistoryRow(
                icon: Icons.flag_outlined,
                color: Colors.orange,
                title: item.contactName,
                subtitle:
                    '${item.reason} • ${_formatRelativeTime(item.createdAt)}',
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Text(
      'Here is how you have been protected and how you have helped '
      'protect others.',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
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

  Widget _buildInsightsCard() {
    final activeDays = _insights['activeDays'] ?? 0;
    final busiestDay = _insights['busiestDay'];
    final busiestDayCount = _insights['busiestDayCount'] ?? 0;
    final average = (_insights['averagePerDay'] ?? 0.0) as double;
    final mostCheckedNumber = _insights['mostCheckedNumber'];
    final mostCheckedName = _insights['mostCheckedName'];
    final mostCheckedCount = _insights['mostCheckedCount'] ?? 0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _showInsights = !_showInsights;
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.purple.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.insights_outlined,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Protection Insights',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'See your checking activity and patterns.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _showInsights
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
            ),
          ),

          if (_showInsights) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCheckChart(),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInsightItem(
                          icon: Icons.calendar_today_outlined,
                          title: 'Active Days',
                          value: '$activeDays',
                          subtitle: 'days',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInsightItem(
                          icon: Icons.speed_outlined,
                          title: 'Average',
                          value: average.toStringAsFixed(1),
                          subtitle: 'checks/day',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInsightItem(
                          icon: Icons.local_fire_department_outlined,
                          title: 'Busiest Day',
                          value: busiestDay == null
                              ? '-'
                              : _formatShortDate(DateTime.parse(busiestDay)),
                          subtitle: '$busiestDayCount checks',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInsightItem(
                          icon: Icons.repeat_outlined,
                          title: 'Most Checked',
                          value: mostCheckedNumber ?? '-',
                          subtitle: mostCheckedNumber == null
                              ? 'No data'
                              : '$mostCheckedCount checks',
                        ),
                      ),
                    ],
                  ),

                  if (mostCheckedName != null) ...[
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 20,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mostCheckedName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Most frequently checked number',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckChart() {
    if (_checkActivity.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No checking activity in the last 7 days.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    final counts = _checkActivity.map((item) => item['count'] as int).toList();
    final maxCount = counts.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Check Activity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              'Last 7 days',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _checkActivity.map((item) {
              final count = item['count'] as int;
              final date = item['date'] as DateTime;

              final double height = maxCount == 0
                  ? 4
                  : 100 * (count / maxCount);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: height.clamp(4.0, 100.0),
                        width: 22,
                        decoration: BoxDecoration(
                          color: Colors.tealAccent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        _dayLabel(date),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blue.shade700),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: colors.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
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

  Widget _buildExpandableStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required int value,
    required String description,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      color: Theme.of(context).cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          '$value',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
        children: children.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No activity yet',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              ]
            : children,
      ),
    );
  }

  Widget _buildHistoryRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 18, color: color),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
        return Icons.manage_search;
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
        return Colors.indigo;
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

  String _dayLabel(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return days[date.weekday - 1];
  }

  String _formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}';
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
