import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/contact_model.dart';
import 'home_screen.dart';
import 'chat_screens/chat_list_screen.dart';
import 'menu_screen.dart';
import 'menu_features_screens/call_screen.dart';

class NavScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserPhoneNumber;

  const NavScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserPhoneNumber,
  });

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  int _selectedIndex = 0;

  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription<List<Map<String, dynamic>>>? _callSubscription;

  bool _incomingCallOpen = false;
  String? _activeIncomingCallId;

  List<Widget> get _pages => [
    HomeScreen(
      currentUserId: widget.currentUserId,
      currentUserPhoneNumber: widget.currentUserPhoneNumber,
    ),
    ChatListScreen(currentUserId: widget.currentUserId),
    MenuScreen(currentUserId: widget.currentUserId),
  ];

  @override
  void initState() {
    super.initState();

    debugPrint(
      'CALL LISTENER STARTED - currentUserId: ${widget.currentUserId}',
    );

    _listenForIncomingCalls();
  }

  void _listenForIncomingCalls() {
    debugPrint('Listening for calls received by: ${widget.currentUserId}');

    _callSubscription = _supabase
        .from('call_events')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', widget.currentUserId)
        .listen(
          (rows) {
            debugPrint('CALL EVENTS UPDATE - receiver ${widget.currentUserId}');

            debugPrint('Total events: ${rows.length}');

            if (rows.isEmpty) {
              debugPrint('No call events found.');
              return;
            }

            for (final row in rows) {
              debugPrint(
                'CALL EVENT: '
                'id=${row['id']} | '
                'caller=${row['caller_id']} | '
                'receiver=${row['receiver_id']} | '
                'status=${row['status']}',
              );
            }

            final ringingCalls = rows.where((row) {
              return row['status']?.toString() == 'ringing';
            }).toList();

            if (ringingCalls.isEmpty) {
              debugPrint('No ringing calls.');
              return;
            }

            final event = Map<String, dynamic>.from(ringingCalls.last);

            debugPrint('RINGING CALL FOUND: ${event['id']}');

            _showIncomingCall(event);
          },
          onError: (error) {
            debugPrint('CALL LISTENER ERROR: $error');
          },
        );
  }

  Future<void> _showIncomingCall(Map<String, dynamic> event) async {
    if (!mounted) return;

    final callId = event['id']?.toString();

    if (callId == null || callId.isEmpty) {
      debugPrint('Incoming call has no call ID.');
      return;
    }

    if (_incomingCallOpen) {
      debugPrint('Incoming call screen already open.');
      return;
    }

    if (_activeIncomingCallId == callId) {
      debugPrint('This call is already being handled: $callId');
      return;
    }

    _incomingCallOpen = true;
    _activeIncomingCallId = callId;

    final callerId = event['caller_id']?.toString() ?? '';

    final callerName = event['caller_name']?.toString() ?? 'Unknown Caller';

    final callerPhone = event['caller_phone']?.toString() ?? '-';

    debugPrint(
      'SHOWING INCOMING CALL\n'
      'Call ID: $callId\n'
      'Caller ID: $callerId\n'
      'Caller Name: $callerName\n'
      'Caller Phone: $callerPhone\n'
      'Receiver ID: ${widget.currentUserId}',
    );

    final callerInitial = _getInitial(callerName);

    final contact = ContactModel(
      id: callerId,
      name: callerName,
      phoneNumber: callerPhone,
      tag: 'Unknown',
      reportCount: 0,
      avatarInitial: callerInitial,
      tags: const [],
      ownerId: widget.currentUserId,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          contact: contact,
          currentUserId: widget.currentUserId,
          callId: callId,
          isCaller: false,
        ),
      ),
    );

    if (!mounted) return;

    _incomingCallOpen = false;
    _activeIncomingCallId = null;

    debugPrint('Incoming call screen closed: $callId');
  }

  String _getInitial(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return '?';
    }

    final words = trimmed.split(RegExp(r'\s+'));

    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }

    return (words.first.substring(0, 1) + words[1].substring(0, 1))
        .toUpperCase();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    debugPrint('CALL LISTENER DISPOSED - ${widget.currentUserId}');

    _callSubscription?.cancel();

    super.dispose();
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
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}
