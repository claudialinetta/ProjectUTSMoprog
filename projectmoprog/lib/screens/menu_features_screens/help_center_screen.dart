import 'package:flutter/material.dart';

import '../../models/faq_item.dart';
import '../../services/faq_service.dart';
import '../../services/support_service.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final FaqService _service = FaqService();
  final TextEditingController _searchController = TextEditingController();

  List<FaqItem> _allItems = [];
  String _query = '';
  FaqCategory? _selectedCategory;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.getFaqs();
      if (!mounted) return;
      setState(() {
        _allItems = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load FAQ.\nCheck your internet connection.';
      });
    }
  }

  List<FaqItem> get _visibleItems {
    final query = _query.trim().toLowerCase();

    return _allItems.where((item) {
      final matchesCategory =
          _selectedCategory == null || item.category == _selectedCategory;
      if (!matchesCategory) return false;

      if (query.isEmpty) return true;
      return item.question.toLowerCase().contains(query) ||
          item.answer.toLowerCase().contains(query) ||
          item.category.label.toLowerCase().contains(query);
    }).toList();
  }

  Map<FaqCategory, List<FaqItem>> get _groupedItems {
    final grouped = <FaqCategory, List<FaqItem>>{};
    for (final category in FaqCategory.values) {
      final items = _visibleItems
          .where((item) => item.category == category)
          .toList();
      if (items.isNotEmpty) grouped[category] = items;
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : null,
      appBar: AppBar(
        title: Text(
          'Help Center',
          style: TextStyle(color: isDark ? Colors.white : null),
        ),
        backgroundColor: isDark ? const Color(0xFF121212) : null,
        iconTheme: IconThemeData(color: isDark ? Colors.white : null),
        scrolledUnderElevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _buildError();

    final grouped = _groupedItems;

    return Column(
      children: [
        _buildSearchField(),
        _buildCategoryChips(),
        Expanded(
          child: grouped.isEmpty ? _buildEmptyState() : _buildList(grouped),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Search a question...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade500 : null,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey.shade400 : null,
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

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          _buildChip(
            label: 'All',
            selected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          ...FaqCategory.values.map((category) {
            final selected = _selectedCategory == category;
            return _buildChip(
              label: category.label,
              selected: selected,
              onTap: () => setState(
                () => _selectedCategory = selected ? null : category,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        labelStyle: TextStyle(
          color: selected 
              ? (isDark ? Colors.white : Colors.black87)
              : (isDark ? Colors.grey.shade300 : Colors.black87),
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : null,
        selectedColor: isDark ? Colors.blue.shade700 : null,
      ),
    );
  }

  Widget _buildList(Map<FaqCategory, List<FaqItem>> grouped) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        ...grouped.entries.map(
          (entry) => _buildCategorySection(entry.key, entry.value),
        ),
        _buildContactSupportSection(),
      ],
    );
  }

  Widget _buildCategorySection(FaqCategory category, List<FaqItem> items) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            category.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
        ...items.map(_buildFaqTile),
      ],
    );
  }

  Widget _buildFaqTile(FaqItem item) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: isDark ? 0 : 0.5,
      clipBehavior: Clip.antiAlias,
      color: isDark ? const Color(0xFF1E1E1E) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.transparent,
        ),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        collapsedIconColor: isDark ? Colors.grey.shade400 : null,
        iconColor: isDark ? Colors.white : null,
        title: Text(
          item.question,
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 14,
            color: isDark ? Colors.white : null,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.answer,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, 
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.help_outline, 
              size: 48, 
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No matching questions found',
              style: TextStyle(color: isDark ? Colors.grey.shade300 : null),
            ),
            const SizedBox(height: 16),
            _buildContactSupportSection(),
          ],
        ),
      ),
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
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
            ),
            const SizedBox(height: 12),
            Text(
              _error!, 
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey.shade300 : null),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSupportSection() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        children: [
          Text(
            "Can't find what you're looking for?",
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openContactSupportSheet(context),
            icon: const Icon(Icons.support_agent),
            label: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  void _openContactSupportSheet(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _ContactSupportSheet(),
    );
  }
}

class _ContactSupportSheet extends StatefulWidget {
  const _ContactSupportSheet();

  @override
  State<_ContactSupportSheet> createState() => _ContactSupportSheetState();
}

class _ContactSupportSheetState extends State<_ContactSupportSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final SupportService _supportService = SupportService();

  FaqCategory _category = FaqCategory.account;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await _supportService.submitTicket(
        subject: _subjectController.text.trim(),
        category: _category.name,
        description: _descriptionController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your message has been sent.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Subject',
                labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : null),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<FaqCategory>(
              initialValue: _category,
              dropdownColor: isDark ? const Color(0xFF262626) : null,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : null),
              ),
              items: FaqCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : null),
              ),
              maxLines: 4,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
