class AppUserModel {
  final String avatarUrl;
  final String country;
  final String email;
  final String name;
  final String phone;
  final String planName;
  final String userStatus;

  AppUserModel({
    required this.avatarUrl,
    required this.country,
    required this.email,
    required this.name,
    required this.phone,
    required this.planName,
    required this.userStatus,
  });

  factory AppUserModel.fromMap(Map<String, dynamic> data) {
    return AppUserModel(
      avatarUrl: data['avatar_url'] ?? '',
      country: data['country'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      planName: data['plan_name'] ?? '',
      userStatus: data['user_status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar_url': avatarUrl,
      'country': country,
      'email': email,
      'name': name,
      'phone': phone,
      'plan_name': planName,
      'user_status': userStatus,
    };
  }

  AppUserModel copyWith({
    String? avatarUrl,
    String? country,
    String? email,
    String? name,
    String? phone,
    String? planName,
    String? userStatus,
  }) {
    return AppUserModel(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      country: country ?? this.country,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      planName: planName ?? this.planName,
      userStatus: userStatus ?? this.userStatus,
    );
  }
}
