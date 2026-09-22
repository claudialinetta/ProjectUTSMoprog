import 'contact_tag.dart';

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
  incoming('Masuk'),
  outgoing('Keluar'),
  missed('Tak terjawab'),
  searched('Dicari');

  final String label;
  const CallType(this.label);

  static CallType fromString(String? value) {
    return CallType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => CallType.searched,
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

  bool get isUnknownCaller => name == 'Unknown Caller' || name == phoneNumber;

  const CallHistoryModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.phoneNumber,
    required this.status,
    required this.type,
    required this.happenedAt,
    this.tags = const [],
  });

  String get initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
  }

  factory CallHistoryModel.fromMap(Map<String, dynamic> map) {
    final tagsData = map['tags'] as List<dynamic>? ?? [];
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
      tags: parsedTags,
    );
  }
}
