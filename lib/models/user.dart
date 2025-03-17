class User {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isStaff;
  final bool isSuperuser;
  final bool isActive;
  final DateTime? dateJoined;
  final DateTime? lastLogin;
  final String accessToken; // تغییر نام از token به accessToken
  final String refreshToken; // اضافه کردن refresh token

  User({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isStaff,
    required this.isSuperuser,
    required this.isActive,
    this.dateJoined,
    this.lastLogin,
    required this.accessToken,
    required this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isStaff: json['is_staff'] ?? false,
      isSuperuser: json['is_superuser'] ?? false,
      isActive: json['is_active'] ?? true,
      dateJoined: json['date_joined'] != null ? DateTime.parse(json['date_joined']) : null,
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      accessToken: json['access_token'] ?? '', // تغییر نام از token به accessToken
      refreshToken: json['refresh_token'] ?? '', // اضافه کردن refresh token
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'is_active': isActive,
      'date_joined': dateJoined?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'access_token': accessToken, // تغییر نام
      'refresh_token': refreshToken, // اضافه کردن refresh token
    };
  }
}
