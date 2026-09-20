import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'chat_screens/chat_list_screen.dart';
import 'menu_screen.dart';

class NavScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserPhoneNumber;

  const NavScreen({super.key, required this.currentUserId, required this.currentUserPhoneNumber});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    HomeScreen(
      currentUserId: widget.currentUserId,
      currentUserPhoneNumber: widget.currentUserPhoneNumber,
    ),
    ChatListScreen(currentUserId: widget.currentUserId),
    const MenuScreen(), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu), 
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}