class UserModel {
  final String id;
  final String name;
  final String phoneNumber;
  bool isPremium;
  bool isProfilePublic;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.isPremium = false,
    this.isProfilePublic = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'isPremium': isPremium,
    'isProfilePublic': isProfilePublic,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    phoneNumber: json['phoneNumber'] as String,
    isPremium: json['isPremium'] as bool? ?? false,
    isProfilePublic: json['isProfilePublic'] as bool? ?? true,
  );
}
