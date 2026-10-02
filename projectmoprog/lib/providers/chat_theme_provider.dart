import 'package:flutter/material.dart';

class ChatThemeProvider extends ChangeNotifier {
  Color _chatColor = Colors.blue.shade600;

  Color get chatColor => _chatColor;

  void setChatColor(Color color) {
    _chatColor = color;
    notifyListeners();
  }
}