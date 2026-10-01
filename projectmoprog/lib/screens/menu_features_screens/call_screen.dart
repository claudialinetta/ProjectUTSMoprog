import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/contact_model.dart';
import '../../models/call_history_model.dart';
import '../../services/call_history_service.dart';
import '../../services/call_event_service.dart';

class CallScreen extends StatefulWidget {
  final ContactModel contact;
  final String currentUserId;
  final String callId;
  final bool isCaller;

  const CallScreen({
    super.key,
    required this.contact,
    required this.currentUserId,
    required this.callId,
    required this.isCaller,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallEventService _callService = CallEventService();
  final CallHistoryService _historyService = CallHistoryService();

  Timer? _timer;
  StreamSubscription<List<Map<String, dynamic>>>? _callSubscription;

  int _seconds = 0;

  bool _isConnected = false;
  bool _isEnded = false;
  bool _historyRecorded = false;

  @override
  void initState() {
    super.initState();
    _listenToCall();
  }

  void _listenToCall() {
    _callSubscription = Supabase.instance.client
        .from('call_events')
        .stream(primaryKey: ['id'])
        .eq('id', widget.callId)
        .listen((rows) {
          if (rows.isEmpty || !mounted) return;

          final event = Map<String, dynamic>.from(rows.first);
          final status = event['status']?.toString();

          if (status == 'accepted' && !_isConnected) {
            _connect();
          }

          if (status == 'cancelled' ||
              status == 'declined' ||
              status == 'ended') {
            _handleRemoteEnd(event, status!);
          }
        });
  }

  void _connect() {
    if (!mounted || _isConnected || _isEnded) return;

    setState(() {
      _isConnected = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isEnded) return;

      setState(() {
        _seconds++;
      });
    });
  }

  Future<void> _acceptCall() async {
    if (_isConnected || _isEnded) return;

    try {
      await _callService.acceptCall(widget.callId);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to accept call.')));
    }
  }

  Future<void> _declineCall() async {
    if (_isEnded) return;

    try {
      await _callService.declineCall(widget.callId);

      await _recordHistory(type: CallType.missed, duration: 0);

      _finishScreen();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to decline call.')));
    }
  }

  Future<void> _cancelCall() async {
    if (_isEnded) return;

    try {
      await _callService.cancelCall(widget.callId);

      await _recordHistory(type: CallType.outgoing, duration: 0);

      _finishScreen();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to cancel call.')));
    }
  }

  Future<void> _endCall() async {
    if (_isEnded) return;

    _timer?.cancel();

    try {
      await _callService.endCall(
        callId: widget.callId,
        durationSeconds: _seconds,
      );

      await _recordHistory(
        type: widget.isCaller ? CallType.outgoing : CallType.incoming,
        duration: _seconds,
      );

      _finishScreen();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to end call.')));
    }
  }

  Future<void> _handleRemoteEnd(
    Map<String, dynamic> event,
    String status,
  ) async {
    if (_isEnded) return;

    _timer?.cancel();

    if (status == 'ended') {
      final duration = (event['duration_seconds'] as num?)?.toInt() ?? _seconds;

      await _recordHistory(
        type: widget.isCaller ? CallType.outgoing : CallType.incoming,
        duration: duration,
      );
    } else if (status == 'cancelled') {
      if (!widget.isCaller) {
        await _recordHistory(type: CallType.missed, duration: 0);
      }
    } else if (status == 'declined') {
      if (widget.isCaller) {
        await _recordHistory(type: CallType.outgoing, duration: 0);
      }
    }

    _finishScreen();
  }

  Future<void> _recordHistory({
    required CallType type,
    required int duration,
  }) async {
    if (_historyRecorded) return;

    _historyRecorded = true;

    final isSpam =
        widget.contact.reportCount >= 10 || widget.contact.tag == 'Spam Likely';

    await _historyService.record(
      ownerId: widget.currentUserId,
      name: widget.contact.name,
      phoneNumber: widget.contact.phoneNumber,
      status: isSpam ? CallStatus.spam : CallStatus.fromTag(widget.contact.tag),
      type: type,
      durationSeconds: duration,
    );
  }

  void _finishScreen() {
    if (!mounted) return;

    setState(() {
      _isEnded = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  String get _timerText {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  String get _statusText {
    if (_isEnded) return 'Call ended';

    if (!_isConnected) {
      return widget.isCaller ? 'Calling...' : 'Incoming call';
    }

    return _timerText;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _callSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showIncomingButtons =
        !widget.isCaller && !_isConnected && !_isEnded;

    final bool showCancelButton = widget.isCaller && !_isConnected && !_isEnded;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              CircleAvatar(
                radius: 56,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  widget.contact.avatarInitial,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                widget.contact.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                widget.contact.phoneNumber,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                _statusText,
                style: const TextStyle(color: Colors.greenAccent, fontSize: 18),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              if (showIncomingButtons)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _roundButton(
                      icon: Icons.call_end,
                      color: Colors.red,
                      onTap: _declineCall,
                    ),
                    _roundButton(
                      icon: Icons.call,
                      color: Colors.green,
                      onTap: _acceptCall,
                    ),
                  ],
                )
              else if (showCancelButton)
                _roundButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: _cancelCall,
                )
              else if (_isConnected && !_isEnded)
                _roundButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: _endCall,
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: CircleAvatar(
        radius: 32,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
