import 'package:flutter/material.dart';

class TagBadge extends StatelessWidget {
  final String tag;
  const TagBadge({super.key, required this.tag});

  Color _color() {
    switch (tag) {
      case "Spam Likely":
        return Colors.red;
      case "Trusted":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color().withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color()),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: _color(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
