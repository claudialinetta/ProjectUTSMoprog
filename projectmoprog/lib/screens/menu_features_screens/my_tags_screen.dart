import 'package:flutter/material.dart';
import '../../services/contact_service.dart';

class MyTagsScreen extends StatefulWidget {
  final String currentUserPhoneNumber;

  const MyTagsScreen({super.key, required this.currentUserPhoneNumber});

  @override
  State<MyTagsScreen> createState() => _MyTagsScreenState();
}

class _MyTagsScreenState extends State<MyTagsScreen> {
  final ContactService _service = ContactService();
  List<String> _mySavedNames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTags();
  }

  Future<void> _fetchTags() async {
    try {
      final savedNames = await _service.getMySavedNames(widget.currentUserPhoneNumber);
      setState(() {
        _mySavedNames = savedNames;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "My Tags",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : null,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _mySavedNames.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              "Tags not found!",
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade500 : Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 12.0,
                          runSpacing: 12.0,
                          children: _mySavedNames.map((savedNames) {
                            return Chip(
                              label: Text(
                                "#$savedNames",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.blue.shade100 : null, 
                                ),
                              ),
                              backgroundColor: isDark 
                                ? Colors.blue.withValues(alpha: 0.15)
                                : Colors.blue.shade100,
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
    );
  }
}
