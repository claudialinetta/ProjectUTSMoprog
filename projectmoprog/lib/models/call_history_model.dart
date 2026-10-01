import 'contact_tag.dart';

import 'dart:convert';

enum CallStatus {
  trusted('Trusted'),
  spam('Spam'),
  unknown('Unknown');

  final String label;
  const CallStatus(this.label);

  static CallStatus fromString(String? value) {
    return CallStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => CallStatus.unknown,
    );
  }

  static CallStatus fromTag(String? tag) {
    final text = (tag ?? '').toLowerCase();
    if (text.contains('spam')) return CallStatus.spam;
    if (text.contains('trusted')) return CallStatus.trusted;
    return CallStatus.unknown;
  }
}

enum CallType {
  incoming('Incoming'),
  outgoing('Outgoing'),
  missed('Missed');

  final String label;
  const CallType(this.label);

  static CallType fromString(String? value) {
    return CallType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => CallType.missed,
    );
  }
}

class CallHistoryModel {
  final String id;
  final String ownerId;
  final String name;
  final String phoneNumber;
  final CallStatus status;
  final CallType type;
  final DateTime happenedAt;
  final List<ContactTag> tags;
  final int durationSeconds;

  bool get isUnknownCaller => name == 'Unknown Caller' || name == phoneNumber;

  const CallHistoryModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.phoneNumber,
    required this.status,
    required this.type,
    required this.happenedAt,
    this.durationSeconds = 0,
    this.tags = const [],
  });

  String get initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
  }

  String get formattedDuration {
    if (durationSeconds <= 0) return '';
    final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  factory CallHistoryModel.fromMap(Map<String, dynamic> map) {
    List<dynamic> tagsData = [];
    if (map['tags'] != null) {
      if (map['tags'] is List) {
        tagsData = map['tags'] as List<dynamic>;
      } else if (map['tags'] is String && map['tags'].toString().isNotEmpty) {
        try {
          tagsData = jsonDecode(map['tags']);
        } catch (_) {}
      }
    }

    final parsedTags = tagsData
        .map((e) => ContactTag.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return CallHistoryModel(
      id: map['id'].toString(),
      ownerId: map['owner_id'].toString(),
      name: (map['name'] as String?) ?? 'Unknown Caller',
      phoneNumber: (map['phone_number'] as String?) ?? '-',
      status: CallStatus.fromString(map['status'] as String?),
      type: CallType.fromString(map['call_type'] as String?),
      happenedAt:
          DateTime.tryParse(map['happened_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      durationSeconds: (map['duration_seconds'] as int?) ?? 0,
      tags: parsedTags,
    );
  }
}
