import 'contact_tag.dart';

class ContactModel {
  final String id;
  final String name;
  final String phoneNumber;
  String tag;
  int reportCount;
  final String avatarInitial;
  final List<ContactTag> tags;
  final String? ownerId;

  ContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.tag,
    required this.reportCount,
    required this.avatarInitial,
    List<ContactTag>? tags,
    this.ownerId,
  }) : tags = tags ?? [];

  void refreshHeadlineTag() {
    if (reportCount >= 10) {
      tag = 'Spam Likely';
    } else if (tags.isNotEmpty) {
      tag = tags.first.label;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'tag': tag,
    'reportCount': reportCount,
    'avatarInitial': avatarInitial,
    'tags': tags.map((t) => t.toJson()).toList(),
    'ownerId': ownerId,
  };

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
    id: json['id'].toString(),
    name: json['name'] as String,
    phoneNumber: json['phoneNumber'] as String,
    tag: json['tag'] as String,
    reportCount: json['reportCount'] as int,
    avatarInitial: json['avatarInitial'] as String,
    tags: (json['tags'] as List<dynamic>? ?? [])
        .map((t) => ContactTag.fromJson(t as Map<String, dynamic>))
        .toList(),
    ownerId: json['ownerId'],
  );
}
