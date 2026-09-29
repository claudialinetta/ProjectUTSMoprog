import 'package:flutter/material.dart';

import '../../models/protection_stats.dart';
import '../../services/protection_stats_service.dart';

class ProtectionStatsScreen extends StatefulWidget {
  final String ownerId;
  const ProtectionStatsScreen({super.key, required this.ownerId});

  @override
  State<ProtectionStatsScreen> createState() => _ProtectionStatsScreenState();
}

class _ProtectionStatsScreenState extends State<ProtectionStatsScreen> {
  final ProtectionStatsService _service = ProtectionStatsService();

  ProtectionStats _stats = const ProtectionStats.empty();
  List<CheckEntry> _checkedHistory = [];
  List<CheckEntry> _spamHistory = [];
  List<ReportHistoryEntry> _reportHistory = [];
  List<DailyActivity> _weeklyActivity = [];
  bool _isLoading = true;
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
      final results = await Future.wait([
        _service.getStats(widget.ownerId),
        _service.getCheckedHistory(widget.ownerId),
        _service.getSpamHistory(widget.ownerId),
        _service.getReportHistory(widget.ownerId),
        _service.getWeeklyActivity(widget.ownerId),
      ]);

      if (!mounted) return;
      setState(() {
        _stats = results[0] as ProtectionStats;
        _checkedHistory = results[1] as List<CheckEntry>;
        _spamHistory = results[2] as List<CheckEntry>;
        _reportHistory = results[3] as List<ReportHistoryEntry>;
        _weeklyActivity = results[4] as List<DailyActivity>;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Protection stats load failed: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load your stats.\nCheck your internet connection.';
      });
    }
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protection Stats')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _buildError();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Here is how you have been protected and how you have helped '
            'protect others.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          _buildExpandableCard(
            icon: Icons.search,
            color: Colors.blue,
            label: 'Numbers Checked',
            value: _stats.numbersChecked,
            description:
                'Numbers you have searched or called through this app.',
            children: _checkedHistory
                .map(
                  (item) => _buildHistoryRow(
                    icon: Icons.search,
                    color: Colors.blue,
                    title: item.name,
                    subtitle:
                        '${item.phoneNumber} • ${_relativeTime(item.checkedAt)}',
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _buildWeeklyChart(),
          const SizedBox(height: 12),
          _buildExpandableCard(
            icon: Icons.shield_outlined,
            color: Colors.red,
            label: 'Spam Avoided',
            value: _stats.spamAvoided,
            description:
                'Spam numbers you were warned about when checking a contact.',
            children: _spamHistory
                .map(
                  (item) => _buildHistoryRow(
                    icon: Icons.shield_outlined,
                    color: Colors.red,
                    title: item.name,
                    subtitle:
                        '${item.phoneNumber} • ${_relativeTime(item.checkedAt)}',
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _buildExpandableCard(
            icon: Icons.flag_outlined,
            color: Colors.orange,
            label: 'Reports Given',
            value: _stats.reportsGiven,
            description: 'Reports you contributed to help protect other users.',
            children: _reportHistory
                .map(
                  (item) => _buildHistoryRow(
                    icon: Icons.flag_outlined,
                    color: Colors.orange,
                    title: item.contactName,
                    subtitle:
                        '${item.reason} • ${_relativeTime(item.createdAt)}',
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableCard({
    required IconData icon,
    required Color color,
    required String label,
    required int value,
    required String description,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
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
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

  Widget _buildWeeklyChart() {
    if (_weeklyActivity.isEmpty) return const SizedBox.shrink();

    final maxCount = _weeklyActivity
        .map((d) => d.count)
        .fold(0, (a, b) => a > b ? a : b);
    final activeDays = _weeklyActivity.where((d) => d.count > 0).length;
    final total = _weeklyActivity.fold(0, (sum, d) => sum + d.count);
    const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Check Activity',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              'Last 7 days',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 72,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _weeklyActivity.map((d) {
                  final ratio = maxCount == 0 ? 0.0 : d.count / maxCount;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 40 * ratio + 4,
                            decoration: BoxDecoration(
                              color: d.count > 0
                                  ? Colors.blue
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weekdayLabels[d.day.weekday - 1],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('Total checks', '$total'),
                _buildMiniStat('Active days', '$activeDays'),
                _buildMiniStat('Busiest day', '$maxCount'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
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
