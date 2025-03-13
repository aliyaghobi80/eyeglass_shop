class User {
  final String username;
  final String phoneNumber;
  final String address;
  final bool isCustomer;
  final String token;

  User({
    required this.username,
    required this.phoneNumber,
    required this.address,
    required this.isCustomer,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['user']['username'],
      phoneNumber: json['user']['phone_number'] ?? '',
      address: json['user']['address'] ?? '',
      isCustomer: json['user']['is_customer'] ?? true,
      token: json['token'],
    );
  }
}