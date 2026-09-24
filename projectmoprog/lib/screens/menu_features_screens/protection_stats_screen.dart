import 'package:flutter/material.dart';
import 'package:projectmoprog/services/protection_stats_service.dart';

import '../../models/protection_stats.dart';

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
      final stats = await _service.getStats(widget.ownerId);

      if (!mounted) return;
      setState(() {
        _stats = stats;
        _activity = [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load your stats.\nCheck your internet connection.';
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _buildError();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildIntro(),
          const SizedBox(height: 20),
          _buildStatCard(
            icon: Icons.search,
            color: Colors.blue,
            label: 'Numbers Checked',
            value: _stats.numbersChecked,
            description:
                'Numbers you have searched or called through this app.',
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            icon: Icons.shield_outlined,
            color: Colors.red,
            label: 'Spam Avoided',
            value: _stats.spamAvoided,
            description:
                'Numbers flagged as spam before you had to find out yourself.',
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            icon: Icons.flag_outlined,
            color: Colors.orange,
            label: 'Reports Given',
            value: _stats.reportsGiven,
            description: 'Reports you contributed to help protect other users.',
          ),
          if (_activity.isNotEmpty) _buildActivitySection(),
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

  Widget _buildActivitySection() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: _activity
                  .map(
                    (a) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.notifications_none, size: 20),
                      title: Text(
                        a.message,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
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
