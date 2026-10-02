import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_theme_provider.dart';
import '../../theme/chat_theme.dart';

class ChatSettingsScreen extends StatelessWidget {
  const ChatSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentColor = context.watch<ChatThemeProvider>().chatColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final themeColors = ChatTheme.availableColors;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Chat Theme'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: themeColors.length,
        itemBuilder: (context, index) {
          final colorData = themeColors[index];
          final color = colorData['color'] as Color;
          final name = colorData['name'] as String;
          
          final isSelected = currentColor == color;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? color 
                    : (isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Material(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  radius: 16,
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected 
                    ? Icon(Icons.check_circle, color: color) 
                    : null,
                onTap: () {
                  context.read<ChatThemeProvider>().setChatColor(color);
                },
              ),
            )
          );
        },
      ),
    );
  }
}