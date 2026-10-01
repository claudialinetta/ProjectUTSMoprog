import 'package:flutter/material.dart';

import '../../models/call_history_model.dart';
import '../../services/call_history_service.dart';
import '../../widgets/call_history_tile.dart';

class CallHistoryScreen extends StatefulWidget {
  final String ownerId;
  const CallHistoryScreen({super.key, required this.ownerId});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  final CallHistoryService _service = CallHistoryService();
  final TextEditingController _searchController = TextEditingController();

  List<CallHistoryModel> _all = [];
  CallStatus? _filter;
  String _query = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(showSpinner: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final data = await _service.getHistory(widget.ownerId);
      if (!mounted) return;
      setState(() {
        _all = data;
        _error = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (_all.isEmpty) {
        setState(
          () => _error =
              'Failed to load history.\nCheck your internet connection.',
        );
      } else {
        _showMessage('Failed to update history.');
      }
    }
  }

  List<CallHistoryModel> get _visibleItems {
    final query = _query.trim().toLowerCase();
    final queryKey = CallHistoryService.toPhoneKey(query);

    return _all.where((item) {
      if (_filter != null && item.status != _filter) return false;
      if (query.isEmpty) return true;

      final nameMatch = item.name.toLowerCase().contains(query);
      final phoneMatch =
          queryKey.isNotEmpty &&
          CallHistoryService.toPhoneKey(item.phoneNumber).contains(queryKey);
      return nameMatch || phoneMatch;
    }).toList();
  }

  Future<void> _deleteItem(CallHistoryModel item) async {
    setState(() {
      _all.remove(item);
    });

    try {
      await _service.delete(item.id);
      _showMessage('${item.name} deleted');
    } catch (e) {
      _showMessage('Failed to delete. Try again.');
      _load(showSpinner: false);
    }
  }

  Future<void> _confirmClearAll() async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : null,
        title: Text(
          'Clear all history?',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          'All your history will be deleted and cannot be restored.',
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.blue,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _service.clearAll(widget.ownerId);
      if (!mounted) return;
      setState(() => _all = []);
    } catch (e) {
      _showMessage('Failed to clear history. Try again.');
    }
  }

  Future<void> _markAsSpam(CallHistoryModel item) async {
    try {
      _showMessage('Marked as spam.');
      _load(showSpinner: false);
    } catch (e) {
      _showMessage('Failed to change status.');
    }
  }

  Future<void> _markAsUnknown(CallHistoryModel item) async {
    try {
      _showMessage('Delete mark');
      _load(showSpinner: false);
    } catch (e) {
      _showMessage('Failed to change status.');
    }
  }

  void _showMessage(String text, {SnackBarAction? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), action: action));
  }

  void _showOptions(CallHistoryModel item) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Calling Option',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Divider(color: isDark ? const Color(0xFF2C2C2C) : null),
              if (item.isUnknownCaller)
                if (item.status == CallStatus.spam)
                  ListTile(
                    leading: const Icon(Icons.restore, color: Colors.blue),
                    title: const Text(
                      'Unmarked contact',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _markAsUnknown(item);
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.block, color: Colors.red),
                    title: const Text(
                      'Marked as spam',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _markAsSpam(item);
                    },
                  )
              else
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'This contact is already been saved by you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.black87,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : null,
      appBar: AppBar(
        title: Text(
          'Call History',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        backgroundColor: isDark ? const Color(0xFF121212) : null,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        actionsIconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
        actions: [
          IconButton(
            tooltip: 'Delete all',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _confirmClearAll,
          ),
        ],
      ),
      body: Center(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _buildError();

    return Column(
      children: [
        _buildSearchField(),
        _buildFilterChips(),
        const SizedBox(height: 4),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildSearchField() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Search name or number in history...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF262626) : Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final options = <CallStatus?>[null, ...CallStatus.values];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final count = option == null
              ? _all.length
              : _all.where((item) => item.status == option).length;
          final label = option == null ? 'All' : option.label;
          final isSelected = _filter == option;

          return ChoiceChip(
            label: Text('$label ($count)'),
            labelStyle: TextStyle(
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black87)
                  : (isDark ? Colors.grey.shade300 : Colors.black87),
            ),
            selected: isSelected,
            onSelected: (_) => setState(() => _filter = option),
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : null,
            selectedColor: isDark ? Colors.blue.shade700 : null,
          );
        },
      ),
    );
  }

  Widget _buildList() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _visibleItems;

    if (items.isEmpty) {
      return Center(
        child: Text(
          _all.isEmpty ? 'No history yet' : 'History not found',
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      );
    }

    final rows = _buildRows(items);

    return RefreshIndicator(
      onRefresh: () => _load(showSpinner: false),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final row = rows[index];

          if (row is String) return _buildDateHeader(row);

          final item = row as CallHistoryModel;
          return Dismissible(
            key: ValueKey(item.id),
            direction: DismissDirection.endToStart,
            background: _buildSwipeBackground(),
            onDismissed: (_) => _deleteItem(item),
            child: GestureDetector(
              onLongPress: () => _showOptions(item),
              child: CallHistoryTile(item: item),
            ),
          );
        },
      ),
    );
  }

  List<Object> _buildRows(List<CallHistoryModel> items) {
    final rows = <Object>[];
    String? lastLabel;

    for (final item in items) {
      final label = _dateLabel(item.happenedAt);
      if (label != lastLabel) {
        rows.add(label);
        lastLabel = label;
      }
      rows.add(item);
    }
    return rows;
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final day = DateTime.utc(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildDateHeader(String label) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.only(right: 24),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }

  Widget _buildError() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
