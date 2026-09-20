import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'chat_list_screen.dart';
import 'menu_screen.dart';

class NavScreen extends StatefulWidget {
  final String currentUserId;

  const NavScreen({super.key, required this.currentUserId});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    HomeScreen(currentUserId: widget.currentUserId),
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
            label: 'Kontak',
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